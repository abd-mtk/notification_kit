final class ServiceException implements Exception {
  const ServiceException({required this.statusCode, required this.body});

  final int statusCode;

  final Object? body;

  @override
  String toString() => 'ServiceException($statusCode): $body';
}

final class NetworkException implements Exception {
  const NetworkException(this.message, {this.timedOut = false});

  final String message;

  final bool timedOut;

  @override
  String toString() => 'NetworkException: $message';
}

final class DecodeException implements Exception {
  const DecodeException(this.message);

  final String message;

  @override
  String toString() => 'DecodeException: $message';
}

final class PushException implements Exception {
  const PushException(this.message);

  final String message;

  @override
  String toString() => 'PushException: $message';
}
