class BusinessDashboardDto {
  final int pointsGenerated;
  final double growthPercentage;
  final int scansToday;

  BusinessDashboardDto({
    required this.pointsGenerated,
    required this.growthPercentage,
    required this.scansToday,
  });

  factory BusinessDashboardDto.fromJson(Map<String, dynamic> json) {
    return BusinessDashboardDto(
      pointsGenerated: json['pointsGenerated'] ?? 0,
      growthPercentage: (json['growthPercentage'] ?? 0).toDouble(),
      scansToday: json['scansToday'] ?? 0,
    );
  }
}
