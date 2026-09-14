class PromotionDto {
  final String id;
  final String partnerId;
  final String partnerName;
  final String title;
  final String description;
  final String imageUrl;
  final int pointsCost;
  final bool isActive;
  final bool isApproved;
  final DateTime createdAt;

  PromotionDto({
    required this.id,
    required this.partnerId,
    required this.partnerName,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pointsCost,
    required this.isActive,
    required this.isApproved,
    required this.createdAt,
  });

  factory PromotionDto.fromJson(Map<String, dynamic> json, {String id = ''}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      // Assume Firestore Timestamp
      if (val.runtimeType.toString() == 'Timestamp') {
        return val.toDate();
      }
      return DateTime.now();
    }

    return PromotionDto(
      id: json['id'] ?? id,
      partnerId: json['partnerId'] ?? json['businessId'] ?? '',
      partnerName: json['partnerName'] ?? json['businessName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      pointsCost: json['pointsCost'] ?? 0,
      isActive: json['isActive'] ?? false,
      isApproved: json['isApproved'] ?? false,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
