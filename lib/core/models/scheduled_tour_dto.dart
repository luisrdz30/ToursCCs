import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduledTourDto {
  final String id;
  final String tourId;
  final String tourTitle;
  final DateTime date;
  final String startTime;
  final String status;

  ScheduledTourDto({
    required this.id,
    required this.tourId,
    required this.tourTitle,
    required this.date,
    required this.startTime,
    required this.status,
  });

  factory ScheduledTourDto.fromJson(Map<String, dynamic> json, {String id = ''}) {
    DateTime parsedDate;
    if (json['date'] is Timestamp) {
      parsedDate = (json['date'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now();
    }

    return ScheduledTourDto(
      id: json['id'] ?? id,
      tourId: json['tourId'] ?? '',
      tourTitle: json['tourTitle'] ?? '',
      date: parsedDate,
      startTime: json['startTime'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }
}