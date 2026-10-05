class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? positiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final numValue = int.tryParse(value.trim());
    if (numValue == null || numValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final numValue = int.tryParse(value.trim());
    if (numValue == null || numValue < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }

  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both start and end dates are required';
    }
    if (endDate.isBefore(startDate)) {
      return 'End date must be on or after start date';
    }
    return null;
  }

  static String? validateReminderTimes(List<dynamic> times) {
    if (times.isEmpty) {
      return 'At least one reminder time is required';
    }
    return null;
  }
}
