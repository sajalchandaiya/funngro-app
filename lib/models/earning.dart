import 'package:intl/intl.dart';

class Earning {
  // Creating a NumberFormat parses locale data (the slow ~3ms part),
  // so we create one per currency, once, and share it across all earnings.
  // To support a new currency, add one line here.
  static final Map<String, NumberFormat> _formats = {
    'INR': NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0),
    'USD': NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2),
  };

  final String id;
  final String title;
  final int amount; // whole units of [currency], e.g. rupees or dollars
  final String currency; // 'INR' or 'USD', sent by the API
  final DateTime date;

  // Formatted once when the object is created, never inside build().
  final String formattedAmount;
  final String formattedDate;

  Earning({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.currency = 'INR',
  }) : formattedAmount = (_formats[currency] ?? _formats['INR']!).format(amount),
       formattedDate = '${date.day}/${date.month}/${date.year}';

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toInt(),
      // Older data without a currency is treated as INR.
      currency: json['currency'] as String? ?? 'INR',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
