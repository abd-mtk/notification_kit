import 'package:uuid/uuid.dart';

import '../core/kits/domain_kit.dart';
import '../core/storage/key_value_store.dart';

final class InstallationIdStore {
  InstallationIdStore({required this.store, final Option<String Function()> newId = const None()})
    : newId = newId.getOrElse(() => randomId);

  static const String key = 'signalplus.installation_id';

  final KeyValueStore store;

  final String Function() newId;

  Option<Future<String>> cached = const None();

  Future<String> read() => cached.getOrElse(() {
    final Future<String> loaded = load();
    cached = some(loaded);
    return loaded;
  });

  Future<String> load() async {
    final Option<String> stored = (await store.read(key)).filter((final String value) => value.isNotEmpty);
    return stored.match(() async {
      final String created = newId();
      await store.write(key, created);
      return created;
    }, (final String value) async => value);
  }

  static String randomId() => const Uuid().v4();
}

base class StoredValue {
  StoredValue({required this.store, required this.storageKey});

  final KeyValueStore store;

  final String storageKey;

  Option<Future<Option<String>>> cached = const None();

  Future<Option<String>> read() => cached.getOrElse(() {
    final Future<Option<String>> loaded = store
        .read(storageKey)
        .then((final Option<String> value) => value.filter((final String item) => item.isNotEmpty));
    cached = some(loaded);
    return loaded;
  });

  Future<void> save(final String value) async {
    await store.write(storageKey, value);
    cached = some(Future<Option<String>>.value(some(value)));
  }

  Future<void> clear() async {
    await store.write(storageKey, '');
    cached = some(Future<Option<String>>.value(const None()));
  }
}

final class ExternalIdStore extends StoredValue {
  ExternalIdStore({required super.store}) : super(storageKey: key);

  static const String key = 'signalplus.external_id';
}
