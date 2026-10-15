import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../core/utils/logger.dart';
import 'client/api_config.dart';
import 'client/api_http_client.dart';
import 'data/data_sources/remote/catalog_remote_data_source.dart';
import 'data/data_sources/remote/installations_remote_data_source.dart';
import 'data/data_sources/remote/notifications_remote_data_source.dart';
import 'data/data_sources/remote/preferences_remote_data_source.dart';
import 'data/data_sources/remote/topics_remote_data_source.dart';
import 'data/repositories/catalog_repository_implement.dart';
import 'data/repositories/installations_repository_implement.dart';
import 'data/repositories/notifications_repository_implement.dart';
import 'data/repositories/preferences_repository_implement.dart';
import 'data/repositories/topics_repository_implement.dart';
import 'domain/entities/enums.dart';
import 'domain/repositories/catalog_repository.dart';
import 'domain/repositories/installations_repository.dart';
import 'domain/repositories/notifications_repository.dart';
import 'domain/repositories/preferences_repository.dart';
import 'domain/repositories/topics_repository.dart';

final class SignalPlusClient {
  const SignalPlusClient({
    required this.installations,
    required this.preferences,
    required this.topics,
    required this.catalog,
    required this.notifications,
    required this.close,
    required this.useLocale,
  });

  factory SignalPlusClient.create(
    final ApiConfig config, {
    final Option<http.Client> client = const None(),
    final KitLogger logger = const KitLogger(sink: KitLogger.silentSink, tag: 'SignalPlus'),
  }) {
    final bool ownsClient = client.isNone();
    final http.Client transport = client.getOrElse(http.Client.new);
    final ApiHttpClient api = ApiHttpClient(config: config, client: transport);
    return SignalPlusClient(
      installations: InstallationsRepositoryImplement(remote: InstallationsRemoteDataSource(api), logger: logger),
      preferences: PreferencesRepositoryImplement(remote: PreferencesRemoteDataSource(api), logger: logger),
      topics: TopicsRepositoryImplement(remote: TopicsRemoteDataSource(api), logger: logger),
      catalog: CatalogRepositoryImplement(remote: CatalogRemoteDataSource(api), logger: logger),
      notifications: NotificationsRepositoryImplement(remote: NotificationsRemoteDataSource(api), logger: logger),
      close: ownsClient ? transport.close : noClose,
      useLocale: (final ServiceLocale locale) => api.locale = locale,
    );
  }

  final InstallationsRepository installations;

  final PreferencesRepository preferences;

  final TopicsRepository topics;

  final CatalogRepository catalog;

  final NotificationsRepository notifications;

  final void Function() close;

  final void Function(ServiceLocale locale) useLocale;

  static void noClose() {}
}
