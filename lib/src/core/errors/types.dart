enum FailureType {
  connection('NO_CONNECTION'),
  timeout('TIMEOUT'),
  unauthenticated('UNAUTHENTICATED'),
  server('SERVER_ERROR'),
  decoding('DECODING_ERROR'),
  platform('PLATFORM_ERROR'),
  unknown('UNKNOWN_ERROR');

  const FailureType(this.code);

  final String code;

  bool get isNetwork => this == FailureType.connection || this == FailureType.timeout;
}

abstract final class ServiceErrorCodes {
  static const String validationFailed = 'ValidationFailed';
  static const String rateLimited = 'RateLimited';
  static const String internalError = 'InternalError';
  static const String appIdInvalid = 'AppIdInvalid';
  static const String installationNotFound = 'InstallationNotFound';
  static const String tenantSuspended = 'TenantSuspended';
  static const String notSignedIn = 'NotSignedIn';
  static const String topicNotFound = 'TopicNotFound';
  static const String categoryLocked = 'CategoryLocked';
  static const String categoryUnknown = 'CategoryUnknown';
}
