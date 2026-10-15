import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../kits/domain_kit.dart';

abstract class KeyValueStore {
  Future<Option<String>> read(final String key);

  Future<void> write(final String key, final String value);
}

/// Encrypted storage: Keystore on Android, Keychain on iOS. The Keychain
/// outlives the app, which is why [PreferencesKeyValueStore] carries the
/// fresh-install marker.
final class SecureKeyValueStore implements KeyValueStore {
  const SecureKeyValueStore([this.storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage storage;

  @override
  Future<Option<String>> read(final String key) async => Option.fromNullable(await storage.read(key: key));

  @override
  Future<void> write(final String key, final String value) => storage.write(key: key, value: value);
}

/// Plain storage that is removed with the app.
final class PreferencesKeyValueStore implements KeyValueStore {
  const PreferencesKeyValueStore();

  @override
  Future<Option<String>> read(final String key) async =>
      Option.fromNullable((await SharedPreferences.getInstance()).getString(key));

  @override
  Future<void> write(final String key, final String value) async {
    await (await SharedPreferences.getInstance()).setString(key, value);
  }
}
