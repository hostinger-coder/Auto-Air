// ===== lib/features/dashboard/models/schedule_model.dart =====

import 'package:intl/intl.dart';

class RelaySchedule {
  final String id;
  final String relayId;
  bool isActive;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> daysOfWeek;

  RelaySchedule({
    required this.id,
    required this.relayId,
    required this.isActive,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
  });

  factory RelaySchedule.fromJson(Map<String, dynamic> json) {
    return RelaySchedule(
      id: json['id']?.toString() ?? '',
      relayId: json['relay_id']?.toString() ?? '',
      isActive: json['is_active'] == true,
      startTime: DateTime.tryParse(json['start_time'].toString())?.toLocal() ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'].toString())?.toLocal() ?? DateTime.now(),
      daysOfWeek: (json['days_of_week'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  String get title {
    final daysCount = daysOfWeek.length;
    if (daysCount == 7) return 'Daily Schedule';
    if (daysCount == 5 &&
        daysOfWeek.contains('monday') &&
        daysOfWeek.contains('friday')) {
      return 'Weekday Schedule';
    }
    if (daysCount == 2 &&
        daysOfWeek.contains('saturday') &&
        daysOfWeek.contains('sunday')) {
      return 'Weekend Schedule';
    }
    return 'Custom Schedule';
  }

  String get timeRange {
    final start = DateFormat('hh:mm a').format(startTime);
    final end = DateFormat('hh:mm a').format(endTime);
    return '$start — $end';
  }

  String get days {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.isEmpty) return 'No days selected';
    return daysOfWeek.map((day) {
      final trimmed = day.trim().toLowerCase();
      if (trimmed.length >= 3) {
        return trimmed.substring(0, 1).toUpperCase() + trimmed.substring(1, 3);
      }
      return day;
    }).join(' • ');
  }
}