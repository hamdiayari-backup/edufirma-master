/// Format course duration for display.
/// [value] is typically in **minutes** from API (e.g. 90 = 1h 30min).
/// If [value] is null or 0, returns empty string.
/// Supports int or double (e.g. 1.5 hours as 90 minutes or 1.5).
String formatCourseDuration(dynamic value) {
  if (value == null) return '';
  int totalMinutes;
  if (value is int) {
    totalMinutes = value;
  } else if (value is double) {
    // Decimal (e.g. 1.5) = hours; whole number could be hours (1.0 = 1h)
    totalMinutes = (value * 60).round();
  } else {
    totalMinutes = int.tryParse(value.toString()) ?? 0;
  }
  if (totalMinutes <= 0) return '';
  if (totalMinutes < 60) return '$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  if (mins == 0) return '${hours}h';
  return '${hours}h ${mins}min';
}
