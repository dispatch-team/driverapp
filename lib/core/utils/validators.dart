class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? minLength(String? value, int min, [String field = 'This field']) {
    if (value == null || value.trim().length < min) {
      return '$field must be at least $min characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final regex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }
}
