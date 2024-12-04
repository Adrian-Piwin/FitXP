String formatMinutes(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return hours > 0 
    ? "$hours:${minutes.toString().padLeft(2, '0')} ${hours > 1 ? 'hrs' : 'hr'}" 
    : "${minutes}min";
}
