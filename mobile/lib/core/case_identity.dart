/// Client-side mirror of the backend's case identity rules, used only for input
/// validation and display. The backend remains the authority; the compact
/// (Lexika) form is never needed on the device.
class CaseIdentity {
  const CaseIdentity(this.caseType, this.number, this.year);

  final String caseType;
  final String number;
  final int year;

  static final _slash = RegExp(r'^\s*([A-Za-z()\-]{1,20})\s*/\s*(\d{1,8})\s*/\s*(\d{4})\s*$');
  static final _spaced = RegExp(r'^\s*([A-Za-z()\-]{1,20})\s+(\d{1,8})\s*/\s*(\d{4})\s*$');

  static CaseIdentity? tryParse(String input) {
    final m = _slash.firstMatch(input) ?? _spaced.firstMatch(input);
    if (m == null) return null;
    final number = m.group(2)!;
    if (number.startsWith('0')) return null; // ambiguous: not merged with the un-padded number
    final year = int.parse(m.group(3)!);
    if (year < 1900 || year > 2100) return null;
    return CaseIdentity(m.group(1)!.toUpperCase(), number, year);
  }

  String get slash => '$caseType/$number/$year';

  @override
  bool operator ==(Object other) =>
      other is CaseIdentity && other.caseType == caseType && other.number == number && other.year == year;

  @override
  int get hashCode => Object.hash(caseType, number, year);

  @override
  String toString() => slash;
}
