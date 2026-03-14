/// Base exception for data layer errors
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Exception when cache operations fail
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Exception when network operations fail
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Exception when widget operations fail
class WidgetException extends AppException {
  const WidgetException(super.message);
}
