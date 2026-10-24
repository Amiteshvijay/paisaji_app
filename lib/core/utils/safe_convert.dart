import 'dart:developer' as developer;

/// Comprehensive safe parsing utility class for resilient JSON parsing across Flutter models.
class SafeConvert {
  /// Safely parses a dynamic [value] into an [int].
  /// Handles int, num, numeric Strings, floating Strings, null, empty strings, and unexpected types.
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is num && value.isFinite) {
      return value.toInt();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      final parsed = num.tryParse(trimmed);
      if (parsed != null && parsed.isFinite) {
        return parsed.toInt();
      }
    }

    return defaultValue;
  }

  /// Safely parses a dynamic [value] into an optional nullable [int].
  static int? parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num && value.isFinite) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final parsed = num.tryParse(trimmed);
      if (parsed != null && parsed.isFinite) return parsed.toInt();
    }
    return null;
  }

  /// Safely parses a dynamic [value] into a [double].
  /// Handles double, int, num, numeric Strings, null, empty strings, and unexpected types.
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;

    if (value is double) {
      return value.isFinite ? value : defaultValue;
    }

    if (value is num) {
      return value.isFinite ? value.toDouble() : defaultValue;
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;
      final parsed = double.tryParse(trimmed);
      if (parsed != null && parsed.isFinite) {
        return parsed;
      }
    }

    return defaultValue;
  }

  /// Safely parses a dynamic [value] into a [String].
  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely parses a dynamic [value] into a [bool].
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
    }
    return defaultValue;
  }

  /// Strictly validates and parses a required financial amount (e.g. coin balance, wallet balance).
  /// Rejects null, empty or corrupt data and throws a FormatException instead of silently zeroing it.
  static double parseRequiredFinancialAmount(dynamic value, {required String fieldName}) {
    if (value == null) {
      developer.log(
        'Validation error: Required financial field "" is null.',
        name: 'SafeConvert',
        level: 1000,
      );
      throw FormatException('Required financial field "" cannot be null.');
    }

    if (value is num && value.isFinite) {
      return value.toDouble();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        final parsed = double.tryParse(trimmed);
        if (parsed != null && parsed.isFinite) {
          return parsed;
        }
      }
    }

    developer.log(
      'Validation error: Required financial field "" contains invalid value: ',
      name: 'SafeConvert',
      level: 1000,
    );
    throw FormatException('Required financial field "" contains invalid value: ');
  }
}
