/// Base exception for data layer errors
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception when cache operations fail
class CacheException extends AppException {
  CacheException(super.message);
}

/// Exception when network operations fail
class NetworkException extends AppException {
  NetworkException(super.message);
}

/// Exception when widget operations fail
class WidgetException extends AppException {
  WidgetException(super.message);
}
