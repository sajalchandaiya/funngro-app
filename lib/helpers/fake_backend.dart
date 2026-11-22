import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// DEMO ONLY: pretends to be our backend so the Earnings screen runs without a server.
/// Remove this file and the line in main.dart once a real API is available.
http.Client fakeBackendClient() {
  final rng = Random();

  return MockClient((request) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final path = request.url.pathSegments;

    // GET /users/{userId}/earnings  -> 3,000 earnings (worst-case user)
    if (path.length == 3 && path[0] == 'users' && path[2] == 'earnings') {
      final now = DateTime.now();
      final earnings = List.generate(3000, (i) {
        return {
          'id': 'e$i',
          'title': 'Project payout #${3000 - i}',
          'amount': 100 + rng.nextInt(4900),
          'date': now.subtract(Duration(hours: i * 6)).toIso8601String(),
        };
      });
      return http.Response(jsonEncode(earnings), 200);
    }

    // GET /earnings/{earningId}  -> one earning's detail (fails 1 in 5 to show error handling)
    if (path.length == 2 && path[0] == 'earnings') {
      if (rng.nextInt(5) == 0) return http.Response('error', 500);
      return http.Response(
        jsonEncode({
          'id': path[1],
          'description': 'Payout for completing a project task.',
          'status': 'Paid',
        }),
        200,
      );
    }

    return http.Response('Not found', 404);
  });
}
