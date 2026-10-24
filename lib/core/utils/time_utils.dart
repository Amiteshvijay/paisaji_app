class TimeUtils {
  /// Converts any DateTime to Indian Standard Time (IST, UTC +5:30)
  static DateTime toIST(DateTime dateTime) {
    return dateTime.toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  /// Formats a DateTime into a clean readable string in Indian Standard Time (IST)
  static String formatIST(dynamic dateInput, {String fallback = 'N/A'}) {
    if (dateInput == null) return fallback;
    DateTime? dt;
    if (dateInput is DateTime) {
      dt = dateInput;
    } else if (dateInput is String) {
      dt = DateTime.tryParse(dateInput);
    }
    if (dt == null) return fallback;

    final istTime = toIST(dt);
    final hours = istTime.hour;
    final period = hours >= 12 ? 'PM' : 'AM';
    final hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours);
    final minute = istTime.minute.toString().padLeft(2, '0');
    final day = istTime.day.toString().padLeft(2, '0');
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthStr = months[istTime.month - 1];
    final year = istTime.year;

    return '$day $monthStr $year, $hour12:$minute $period IST';
  }
}
