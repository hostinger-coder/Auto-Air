class RelaySchedule {
  final int id;
  final String title;
  final String timeRange;
  final String days;
  bool isActive;

  RelaySchedule({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.days,
    required this.isActive,
  });
}