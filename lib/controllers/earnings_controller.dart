import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../helpers/app_life_cycle_helper.dart';
import '../helpers/backoff_helper.dart';
import '../helpers/http_helper.dart';
import '../helpers/wallet_helper.dart';
import '../models/earning.dart';
import '../models/earning_detail.dart';
import '../models/wallet_update.dart';
import '../screens/earning_detail_screen.dart';

class EarningsController extends GetxController {
  EarningsController({required this.userId});

  final String userId;

  static const double rowHeight = 72;

  static const Duration staleAfter = Duration(minutes: 5);

  final HttpHelper _http = HttpHelper();
  final WalletHelper _wallet = WalletHelper();
  late final AppLifecycleHelper _lifecycle;
  StreamSubscription<WalletUpdate>? _walletSubscription;
  final BackoffHelper _walletBackoff = BackoffHelper();
  Timer? _walletRetryTimer;
  RxInt walletRetryAttempt = 0.obs;

  // true from the start, so the first frame shows a loader
  List<Earning> earnings = <Earning>[].obs;
  RxBool isLoading = true.obs;
  final error = RxnString();
  // id of the earning whose detail is loading (blocks double taps)
  final openingId = RxnString();

  final scrollController = ScrollController();
  RxBool showScrollToTop = false.obs; // the "back to top" button is visible

  Future<void>? _currentLoad;
  DateTime? _lastLoadedAt;

  // Runs ONCE when the controller is created - not on every rebuild like build() does.
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _lifecycle = AppLifecycleHelper(
      onBackground: _onAppBackground,
      onForeground: _onAppForeground,
    );
    loadEarnings();
    _connectWallet();
  }

  // Runs when the screen is popped (GetX deletes the controller with its route).
  @override
  void onClose() {
    _lifecycle.dispose();
    _disconnectWallet();
    scrollController.dispose();
    super.onClose();
  }

  void _onAppBackground() {
    print("+++++++++>>> ON APP BACKGROUND CALLED <<<<<+++++++");
    _disconnectWallet();
  }

  void _onAppForeground(Duration timeAway) {
    print("+++++++++>>> ON APP FOREGROUND CALLED <<<<<+++++++");
    _connectWallet();
    final lastLoadedAt = _lastLoadedAt;
    final isStale =
        lastLoadedAt == null ||
        DateTime.now().difference(lastLoadedAt) > staleAfter;
    if (isStale) loadEarnings(quiet: true);
  }

  void _onScroll() {
    // Rx only notifies when the value actually changes, so this is cheap to call on every scroll.
    showScrollToTop.value = scrollController.offset > 600;
  }

  void scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _keepPositionAfterInsertingOnTop(int count) {
    if (count <= 0 || !scrollController.hasClients) return;
    if (scrollController.offset <= 0) return;
    scrollController.position.correctBy(count * rowHeight);
  }

  Future<void> loadEarnings({bool quiet = false}) {
    return _currentLoad ??= _load(quiet: quiet).whenComplete(() {
      _currentLoad = null;
    });
  }

  Future<void> _load({required bool quiet}) async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await _http.get('/users/$userId/earnings') as List<dynamic>;
      if (isClosed) return; // user left while we were waiting
      final fresh = data
          .map((json) => Earning.fromJson(json as Map<String, dynamic>))
          .toList();
      final previousTopId = earnings.isEmpty ? null : earnings.first.id;
      final addedOnTop = previousTopId == null
          ? 0
          : fresh.indexWhere((e) => e.id == previousTopId);

      earnings.assignAll(fresh);
      _lastLoadedAt = DateTime.now();
      _keepPositionAfterInsertingOnTop(addedOnTop);
    } catch (e) {
      if (isClosed) return;
      error.value = 'Could not load your earnings. Please try again.';
      // If old data is already on screen, keep it and just tell the user.
      if (earnings.isNotEmpty && !quiet) {
        Get.snackbar('Refresh failed', error.value!);
      }
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _connectWallet() {
    if (_walletSubscription != null) return;
    _walletRetryTimer?.cancel();
    _walletRetryTimer = null;
    // onError: a dropped live connection shouldn't break the screen
    _walletSubscription = _wallet
        .walletUpdates(userId, onConnected: _onWalletConnected)
        .listen(
          _onWalletUpdate,
          onError: (_) => _onWalletLost(),
          onDone: _onWalletLost,
          cancelOnError: true,
        );
  }

  void _disconnectWallet() {
    _walletRetryTimer?.cancel();
    _walletRetryTimer = null;
    _walletSubscription?.cancel();
    _walletSubscription = null;
    _walletBackoff.reset();
    walletRetryAttempt.value = 0;
    print("+++++++++>>> WALLET DISCONNECT <<<<<+++++++");
  }

  void _onWalletConnected() {
    walletRetryAttempt.value = 0;
  }

  void _onWalletLost() {
    _walletSubscription = null;
    if (isClosed) return;
    final delay = _walletBackoff.next();
    walletRetryAttempt.value = _walletBackoff.attempt;
    _walletRetryTimer = Timer(delay, _connectWallet);
  }

  void _onWalletUpdate(WalletUpdate update) {
    _walletBackoff.reset();
    // Don't add the same earning twice (e.g. it was already in the fetched list).
    if (earnings.any((e) => e.id == update.id)) return;
    earnings.insert(0, update.toEarning());
    _keepPositionAfterInsertingOnTop(1);
  }

  Future<void> openDetail(Earning earning) async {
    // A detail is already loading - ignore extra taps.
    if (openingId.value != null) return;
    openingId.value = earning.id;
    try {
      final json =
          await _http.get('/earnings/${earning.id}') as Map<String, dynamic>;
      if (isClosed) return; // user left the screen - don't navigate
      Get.to(() => EarningDetailScreen(detail: EarningDetail.fromJson(json)));
    } catch (e) {
      if (isClosed) return;
      Get.snackbar('Oops', 'Could not open this earning. Please try again.');
    } finally {
      if (!isClosed) openingId.value = null;
    }
  }
}
