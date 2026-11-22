import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/projects_controller.dart';
import 'widgets/common_widgets.dart';

class ProjectsScreen extends GetView<ProjectsController> {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: ScrollToTopButton(
        visible: controller.showScrollToTop,
        onPressed: controller.scrollToTop,
      ),
      body: Obx(() {
        final projects = controller.projects;

        // First load: nothing on screen yet -> full-screen loader
        if (projects.isEmpty && controller.isPageLoading.value) {
          return const LoadingView(message: 'Finding projects for you...');
        }

        // First load failed -> full-screen error with retry
        if (projects.isEmpty && controller.pageError.value != null) {
          return ErrorView(
            message: controller.pageError.value!,
            onRetry: controller.retry,
          );
        }

        // API returned nothing at all
        if (projects.isEmpty && !controller.hasMore.value) {
          return const Center(child: Text('No projects available right now.'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProjects,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: projects.length + 1, // +1 for the footer row
            itemBuilder: (context, index) {
              if (index == projects.length) {
                // itemBuilder runs outside the outer Obx, so the footer needs its own Obx.
                return Obx(() => _buildFooter(context));
              }
              final project = projects[index];
              return ListTile(
                key: ValueKey(project.id),
                title: Text(project.title),
                subtitle: Text(project.company),
                trailing: Text(
                  '₹${project.payout}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  /// Bottom of the list: page error, page loading, end of list, or nothing.
  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (controller.pageError.value != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: 8),
            Text(controller.pageError.value!),
            TextButton(onPressed: controller.retry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (controller.isPageLoading.value) {
      return const InlineLoader(message: 'Loading more projects...');
    }

    if (!controller.hasMore.value) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: colors.primary),
            const SizedBox(width: 8),
            const Text("You've seen all projects"),
          ],
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}
