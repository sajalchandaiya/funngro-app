import 'package:flutter/material.dart';

import '../models/earning_detail.dart';

class EarningDetailScreen extends StatelessWidget {
  const EarningDetailScreen({super.key, required this.detail});

  final EarningDetail detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earning detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${detail.status}'),
            const SizedBox(height: 8),
            Text(detail.description),
          ],
        ),
      ),
    );
  }
}
