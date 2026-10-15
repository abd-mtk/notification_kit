import '../domain/entities/enums.dart';

final class ApiConfig {
  const ApiConfig({
    required this.appId,
    required this.locale,
    this.baseUrl = defaultBaseUrl,
    this.timeout = const Duration(seconds: 20),
  });

  static const String defaultBaseUrl = 'https://api.signal-plus.kog.technology';

  final String appId;

  final ServiceLocale locale;

  final String baseUrl;

  final Duration timeout;
}
