class ErpNextException implements Exception {
  final String message;
  final int? statusCode;

  ErpNextException(this.message, [this.statusCode]);

  @override
  String toString() => 'ErpNextException: $message (Status: $statusCode)';
}

class AuthException extends ErpNextException {
  AuthException(String message, [int? statusCode]) : super(message, statusCode);

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class ApiException extends ErpNextException {
  final dynamic details;
  ApiException(String message, [int? statusCode, this.details]) : super(message, statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode) Details: $details';
}

class NetworkException extends ErpNextException {
  NetworkException(String message, [int? statusCode]) : super(message, statusCode);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException extends ErpNextException {
  final Map<String, dynamic>? errors;
  ValidationException(String message, [this.errors]) : super(message, 417);

  @override
  String toString() => 'ValidationException: $message Errors: $errors';
}
