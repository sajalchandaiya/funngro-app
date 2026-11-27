import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/earnings_controller.dart';
import '../models/earning.dart';
import 'widgets/common_widgets.dart';

/// Only draws what the controller says. No API calls, no subscriptions in here.
class EarningsScreen extends GetView<EarningsController> {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Earnings')),
      floatingActionButton: ScrollToTopButton(
        visible: controller.showScrollToTop,
        onPressed: controller.scrollToTop,
      ),
      body: Column(
        children: [
          const _WalletBanner(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // 1. First load
      if (controller.isLoading.value && controller.earnings.isEmpty) {
        return const LoadingView(message: 'Loading your earnings...');
      }

      // 2. First load failed
      if (controller.error.value != null && controller.earnings.isEmpty) {
        return ErrorView(
          message: controller.error.value!,
          onRetry: controller.loadEarnings,
        );
      }

      // 3. Loaded, but nothing yet
      if (controller.earnings.isEmpty) {
        return const Center(
          child: Text(
            'No earnings yet. Finish a project to get your first payout!',
          ),
        );
      }

      // 4. The list. ListView.builder only builds the rows on screen (~10),
      //    not all 3,000. itemExtent tells Flutter every row is 72px tall,
      //    so it doesn't have to measure each row while scrolling.
      return RefreshIndicator(
        onRefresh: controller.loadEarnings,
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.earnings.length,
          itemExtent: EarningsController.rowHeight,
          itemBuilder: (context, index) {
            final earning = controller.earnings[index];
            return _EarningTile(key: ValueKey(earning.id), earning: earning);
          },
        ),
      );
    });
  }
}

class _WalletBanner extends GetView<EarningsController> {
  const _WalletBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Obx(() {
      final attempt = controller.walletRetryAttempt.value;
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: attempt == 0
            ? const SizedBox(width: double.infinity)
            : Container(
                width: double.infinity,
                color: colors.primaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Live updates paused. Reconnecting (attempt $attempt)...',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}

class _EarningTile extends GetView<EarningsController> {
  const _EarningTile({super.key, required this.earning});

  final Earning earning;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(earning.title),
      subtitle: Text(earning.formattedDate),
      // Own small Obx: when a detail starts loading only the trailing widgets rebuild.
      trailing: Obx(() {
        if (controller.openingId.value == earning.id) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
            ),
          );
        }
        return Text(
          earning.formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        );
      }),
      onTap: () => controller.openDetail(earning),
    );
  }
}
