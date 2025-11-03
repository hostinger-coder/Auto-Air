class HourlyRecord {
  final DateTime timestamp;
  final double current1;
  final double current2;
  final double current3;
  final double current4;

  HourlyRecord({
    required this.timestamp,
    required this.current1,
    required this.current2,
    required this.current3,
    required this.current4,
  });

  double get total => current1 + current2 + current3 + current4;

  double getValue(int index) {
    switch (index) {
      case 0:
        return current1;
      case 1:
        return current2;
      case 2:
        return current3;
      case 3:
        return current4;
      default:
        return 0.0;
    }
  }
}