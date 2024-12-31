class DataPoint {
  final double value;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime dayOccurred;
  final String? subType;

  DataPoint({
    required this.value,
    required this.dateFrom,
    required this.dateTo,
    required this.dayOccurred,
    this.subType,
  });
}
