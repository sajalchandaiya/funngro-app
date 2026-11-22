import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/earnings_controller.dart';
import '../controllers/projects_controller.dart';
import 'earnings_screen.dart';
import 'projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Text(
              'Funngro',
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Mobile Engineer (Flutter) assessment',
              style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            _HomeCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'My Earnings',
              subtitle: 'Part 1 · 3,000 entries with live wallet updates',
              // The binding creates the controller together with the route, and GetX
              // deletes it (calling onClose) when the route is popped.
              onTap: () => Get.to(
                () => const EarningsScreen(),
                binding: BindingsBuilder(() {
                  Get.put(EarningsController(userId: 'demo_user'));
                }),
              ),
            ),
            const SizedBox(height: 12),
            _HomeCard(
              icon: Icons.work_rounded,
              title: 'Projects',
              subtitle: 'Part 2 · Infinite scroll on a flaky API',
              onTap: () => Get.to(
                () => const ProjectsScreen(),
                binding: BindingsBuilder(() {
                  Get.put(ProjectsController());
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colors.primaryContainer,
                child: Icon(icon, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
