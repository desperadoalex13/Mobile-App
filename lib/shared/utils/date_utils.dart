extension AppDateUtils on DateTime {
  DateTime get startOfWeek {
    final diff = weekday - 1;
    return DateTime(year, month, day - diff);
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String toDisplayDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day';
  }
}
