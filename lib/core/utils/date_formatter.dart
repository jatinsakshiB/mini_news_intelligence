import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatRelative(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';

    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        return '$m ${m == 1 ? 'min' : 'mins'} ago';
      } else if (difference.inHours < 24) {
        final h = difference.inHours;
        return '$h ${h == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 7) {
        final d = difference.inDays;
        return '$d ${d == 1 ? 'day' : 'days'} ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (_) {
      return '';
    }
  }

  static String formatFull(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';

    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('EEEE, MMM d, yyyy • h:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  static String estimateReadTime(String? content, String? description) {
    final text = '${description ?? ''} ${content ?? ''}'.trim();
    if (text.isEmpty) return '2 min read';
    final words = text.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil().clamp(1, 10);
    return '$minutes min read';
  }
}
