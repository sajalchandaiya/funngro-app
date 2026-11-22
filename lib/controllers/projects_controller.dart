import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../helpers/projects_api.dart';
import '../models/project.dart';

class ProjectsController extends GetxController {
  final ProjectsApi _api = ProjectsApi();
  final scrollController = ScrollController();

  List<Project> projects = <Project>[].obs;
  RxBool isPageLoading = false.obs; // a page request is in flight
  final pageError = RxnString(); // the last page request failed
  RxBool hasMore = true.obs; // false once the API returns an empty page
  RxBool showScrollToTop = false.obs; // the "back to top" button is visible

  int _nextPage = 0;
  bool _isRefreshing = false;

  // Goes up on every refresh. A page request that started before the refresh
  // sees a different number when it returns, and throws its result away.
  int _generation = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadNextPage();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    // Rx only notifies when the value actually changes, so this is cheap to call on every scroll.
    showScrollToTop.value = scrollController.offset > 600;

    // Start loading when the user is within ~300px of the bottom.
    if (scrollController.position.extentAfter < 300) loadNextPage();
  }

  void scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> loadNextPage() async {
    // Only one request at a time. After an error we wait for the user to tap Retry
    // instead of hitting a failing server again on every scroll event.
    if (isPageLoading.value ||
        _isRefreshing ||
        !hasMore.value ||
        pageError.value != null) {
      return;
    }

    final generation = _generation;
    isPageLoading.value = true;
    try {
      final page = await _api.fetchProjects(_nextPage);
      if (generation != _generation || isClosed) return;
      if (page.isEmpty) {
        hasMore.value = false;
      } else {
        projects.addAll(page); // add to what we already have - never replace
        _nextPage++;
      }
    } catch (e) {
      if (generation != _generation || isClosed) return;
      pageError.value = 'Could not load more projects.';
    } finally {
      if (generation == _generation) isPageLoading.value = false;
    }
  }

  void retry() {
    pageError.value = null;
    loadNextPage();
  }

  /// Pull-to-refresh: fetch page 0 again. The old list stays on screen until the
  /// new page arrives, so a failed refresh doesn't leave the user with nothing.
  Future<void> refreshProjects() async {
    _generation++; // any page request still in flight is now outdated
    final generation = _generation;
    _isRefreshing = true;
    isPageLoading.value = false;
    pageError.value = null;

    try {
      final firstPage = await _api.fetchProjects(0);
      if (generation != _generation || isClosed) return;
      projects.assignAll(firstPage);
      _nextPage = 1;
      hasMore.value = firstPage.isNotEmpty;
    } catch (e) {
      if (generation != _generation || isClosed) return;
      if (projects.isEmpty) {
        pageError.value = 'Could not load projects.';
      } else {
        Get.snackbar(
          'Refresh failed',
          'Showing your previous list. Pull down to try again.',
        );
      }
    } finally {
      if (generation == _generation) _isRefreshing = false;
    }
  }
}
