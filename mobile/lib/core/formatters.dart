import 'package:intl/intl.dart';

/// Dates travel as ISO strings (yyyy-MM-dd or full timestamps) from the backend.
class Fmt {
  const Fmt._();

  static String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static DateTime? parse(String? value) => value == null ? null : DateTime.tryParse(value)?.toLocal();

  static String displayDate(Object? value, {String locale = 'en'}) {
    final d = value is DateTime ? value : parse(value?.toString());
    if (d == null) return value?.toString() ?? '';
    return DateFormat('EEE, d MMM yyyy', locale).format(d);
  }

  static String shortDate(Object? value, {String locale = 'en'}) {
    final d = value is DateTime ? value : parse(value?.toString());
    if (d == null) return value?.toString() ?? '';
    return DateFormat('d MMM yyyy', locale).format(d);
  }

  static String timestamp(Object? value, {String locale = 'en'}) {
    final d = value is DateTime ? value.toLocal() : parse(value?.toString());
    if (d == null) return '';
    return DateFormat('d MMM yyyy, h:mm a', locale).format(d);
  }

  static String time(Object? value, {String locale = 'en'}) {
    final d = value is DateTime ? value.toLocal() : parse(value?.toString());
    if (d == null) return '';
    return DateFormat('h:mm a', locale).format(d);
  }

  /// "5 min ago"-style age for freshness labels.
  static String age(DateTime? at, {DateTime? now}) {
    if (at == null) return '';
    final diff = (now ?? DateTime.now()).difference(at);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  static String humanise(String key) {
    final s = key.replaceAll('_', ' ').trim();
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }
}
