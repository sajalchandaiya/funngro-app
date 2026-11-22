import 'earning.dart';

class WalletUpdate {
  final String id;
  final String title;
  final int amount;
  final DateTime date;

  WalletUpdate({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  Earning toEarning() {
    return Earning(id: id, title: title, amount: amount, date: date);
  }
}
