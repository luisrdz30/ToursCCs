class TourDto {
  final String id;
  final String title;
  final String description;
  final double price;
  final int durationMinutes;
  final bool isActive;
  final String? imageUrl;
  final int pointsToEarn;

  TourDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.isActive,
    this.imageUrl,
    this.pointsToEarn = 0,
  });

  factory TourDto.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return TourDto(
      id: json['id'] ?? id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      isActive: json['isActive'] ?? false,
      imageUrl: json['imageUrl'],
      pointsToEarn: json['pointsToEarn'] ?? 0,
    );
  }
}
