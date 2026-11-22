class EarningDetail {
  final String id;
  final String description;
  final String status;

  EarningDetail({
    required this.id,
    required this.description,
    required this.status,
  });

  factory EarningDetail.fromJson(Map<String, dynamic> json) {
    return EarningDetail(
      id: json['id'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
    );
  }
}
