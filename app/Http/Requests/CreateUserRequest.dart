class CreateUserRequest {
  final Map<String, dynamic> data;

  CreateUserRequest(this.data);

  /// Validation rules for the request
  Map<String, List<String>> rules() {
    return {
      // Example validation rules:
      // 'name': ['required', 'string', 'min:3'],
      // 'email': ['required', 'email'],
      // 'age': ['required', 'integer', 'min:18'],
    };
  }

  /// Custom validation messages
  Map<String, String> messages() {
    return {
      // Example custom messages:
      // 'name.required': 'The name field is required.',
      // 'email.email': 'Please provide a valid email address.',
    };
  }

  /// Authorize the request
  bool authorize() {
    // Return true to authorize, false to deny
    return true;
  }

  /// Validate the request
  Future<bool> validate() async {
    if (!authorize()) {
      throw Exception('Unauthorized');
    }

    // TODO: Implement validation logic based on rules()
    return true;
  }

  /// Get validated data
  Map<String, dynamic> validated() {
    return data;
  }

  /// Get a specific field from request data
  dynamic get(String key, [dynamic defaultValue]) {
    return data[key] ?? defaultValue;
  }

  /// Check if request has a field
  bool has(String key) {
    return data.containsKey(key);
  }
}
