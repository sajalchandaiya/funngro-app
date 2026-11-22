import '../models/wallet_update.dart';

/// Live wallet updates. In production this would be a websocket or Firestore listener
/// (http can't push). For the demo it emits a fake payout every 20 seconds.
class WalletHelper {
  Stream<WalletUpdate> walletUpdates(String userId) {
    return Stream.periodic(const Duration(seconds: 20), (_) {
      final now = DateTime.now();
      return WalletUpdate(
        id: 'live_${now.millisecondsSinceEpoch}',
        title: 'New payout',
        amount: 250,
        date: now,
      );
    });
  }
}
