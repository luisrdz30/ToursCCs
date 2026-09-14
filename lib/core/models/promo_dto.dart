class PromoDto {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? adminComments;

  PromoDto({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.adminComments,
  });

  factory PromoDto.fromJson(Map<String, dynamic> json) {
    return PromoDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'Pending',
      adminComments: json['adminComments'],
    );
  }
}
