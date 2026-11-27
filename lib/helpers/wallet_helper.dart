import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/wallet_update.dart';

/// Live wallet updates. In production this would be a websocket or Firestore listener
/// (http can't push). For the demo it emits a fake payout every 20 seconds.
class WalletHelper {
  final _rng = Random();

  Stream<WalletUpdate> walletUpdates(
    String userId, {
    VoidCallback? onConnected,
  }) async* {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_rng.nextInt(3) == 0) throw Exception('Could not connect to wallet');
    onConnected?.call();

    while (true) {
      await Future.delayed(const Duration(seconds: 20));
      if (_rng.nextInt(4) == 0) throw Exception('Wallet connection lost');
      final now = DateTime.now();
      yield WalletUpdate(
        id: 'live_${now.millisecondsSinceEpoch}',
        title: 'New payout',
        amount: 250,
        date: now,
      );
    }
  }
}
