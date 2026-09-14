class AdminDashboardDto {
  final int totalUsers;
  final int globalPointsRedeemed;
  final int totalToursCompleted;
  final int activeAlerts;

  AdminDashboardDto({
    required this.totalUsers,
    required this.globalPointsRedeemed,
    required this.totalToursCompleted,
    required this.activeAlerts,
  });

  factory AdminDashboardDto.fromJson(Map<String, dynamic> json) {
    return AdminDashboardDto(
      totalUsers: json['totalUsers'] ?? 0,
      globalPointsRedeemed: json['globalPointsRedeemed'] ?? 0,
      totalToursCompleted: json['totalToursCompleted'] ?? 0,
      activeAlerts: json['activeAlerts'] ?? 0,
    );
  }
}
