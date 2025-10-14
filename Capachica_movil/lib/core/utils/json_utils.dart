// lib/core/utils/json_utils.dart

List<String> asStringList(dynamic v) {
  if (v == null) return <String>[];
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return <String>[];
    if (s.contains(',')) {
      return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return <String>[s];
  }
  return <String>[];
}

String asString(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.replaceAll(',', '.').trim();
    return double.tryParse(s);
  }
  return null;
}

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool? asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes' || s == 'si';
  }
  return null;
}
