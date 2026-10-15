import 'package:firebase_core/firebase_core.dart';

import '../api/client/api_config.dart';
import '../api/domain/entities/enums.dart';
import '../core/kits/domain_kit.dart';
import '../core/utils/logger.dart';
import '../push/models/push_config.dart';

final class SignalPlusConfig {
  const SignalPlusConfig({
    required this.appId,
    required this.locale,
    this.push = const PushConfig(),
    this.baseUrl = ApiConfig.defaultBaseUrl,
    this.timeout = const Duration(seconds: 20),
    this.registerOnStart = true,
    this.firebaseOptions = const None(),
  });

  final String appId;

  final ServiceLocale locale;

  final PushConfig push;

  final String baseUrl;

  final Duration timeout;

  final bool registerOnStart;

  final Option<FirebaseOptions> firebaseOptions;

  SignalPlusConfig withPush(final PushConfig value) => SignalPlusConfig(
    appId: appId,
    locale: locale,
    push: value,
    baseUrl: baseUrl,
    timeout: timeout,
    registerOnStart: registerOnStart,
    firebaseOptions: firebaseOptions,
  );

  ApiConfig get api => ApiConfig(appId: appId, locale: locale, baseUrl: baseUrl, timeout: timeout);

  KitLogger get logger => push.kitLogger.tagged('SignalPlus');
}
