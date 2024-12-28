String formatMinutes(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return hours > 0 
    ? "$hours:${minutes.toString().padLeft(2, '0')} ${hours > 1 ? 'hrs' : 'hr'}" 
    : "${minutes}min";
}

String formatNumber(num number) {
  return number.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},'
  );
}
