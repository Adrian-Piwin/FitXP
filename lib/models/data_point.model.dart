class DataPoint {
  final double value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? activityType;

  DataPoint({
    required this.value,
    required this.dateFrom,
    required this.dateTo,
    this.activityType,
  });
}
