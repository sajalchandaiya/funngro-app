import 'package:intl/intl.dart';

class Earning {
  // Creating a NumberFormat parses locale data (the slow ~3ms part),
  // so we create it once and share it across all earnings.
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final String id;
  final String title;
  final int amount; // in rupees
  final DateTime date;

  // Formatted once when the object is created, never inside build().
  final String formattedAmount;
  final String formattedDate;

  Earning({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
  }) : formattedAmount = _currency.format(amount),
       formattedDate = '${date.day}/${date.month}/${date.year}';

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
