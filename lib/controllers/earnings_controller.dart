import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../helpers/http_helper.dart';
import '../helpers/wallet_helper.dart';
import '../models/earning.dart';
import '../models/earning_detail.dart';
import '../models/wallet_update.dart';
import '../screens/earning_detail_screen.dart';

class EarningsController extends GetxController {
  EarningsController({required this.userId});

  final String userId;

  final HttpHelper _http = HttpHelper();
  final WalletHelper _wallet = WalletHelper();
  StreamSubscription<WalletUpdate>? _walletSubscription;

  // true from the start, so the first frame shows a loader
  List<Earning> earnings = <Earning>[].obs;
  RxBool isLoading = true.obs;
  final error = RxnString();
  // id of the earning whose detail is loading (blocks double taps)
  final openingId = RxnString();

  final scrollController = ScrollController();
  RxBool showScrollToTop = false.obs; // the "back to top" button is visible

  // Runs ONCE when the controller is created - not on every rebuild like build() does.
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadEarnings();
    // onError: a dropped live connection shouldn't break the screen
    _walletSubscription = _wallet
        .walletUpdates(userId)
        .listen(_onWalletUpdate, onError: (_) {});
  }

  // Runs when the screen is popped (GetX deletes the controller with its route).
  @override
  void onClose() {
    _walletSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
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

  Future<void> loadEarnings() async {
    isLoading.value = true;
    error.value = null;
    try {
      final data = await _http.get('/users/$userId/earnings') as List<dynamic>;
      if (isClosed) return; // user left while we were waiting
      earnings.assignAll(
        data.map((json) => Earning.fromJson(json as Map<String, dynamic>)),
      );
    } catch (e) {
      if (isClosed) return;
      error.value = 'Could not load your earnings. Please try again.';
      // If old data is already on screen, keep it and just tell the user.
      if (earnings.isNotEmpty) Get.snackbar('Refresh failed', error.value!);
    } finally {
      isLoading.value = false;
    }
  }

  void _onWalletUpdate(WalletUpdate update) {
    // Don't add the same earning twice (e.g. it was already in the fetched list).
    if (earnings.any((e) => e.id == update.id)) return;
    earnings.insert(0, update.toEarning());
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
      openingId.value = null;
    }
  }
}
