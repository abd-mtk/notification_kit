import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/src/device/fresh_install.dart';

import '../support/device_fakes.dart';

void main() {
  test('a new install clears the values the keychain kept from the old one', () async {
    final MemoryStore secure = MemoryStore()..values.addAll(<String, String>{'id': 'old-id', 'user': 'driver:42'});
    final MemoryStore local = MemoryStore();

    final bool fresh = await FreshInstall.resetIfNew(secure: secure, local: local, keys: const <String>['id', 'user']);

    expect(fresh, isTrue);
    expect(secure.values, <String, String>{'id': '', 'user': ''});
    expect(local.values[FreshInstall.markerKey], '1');
  });

  test('later launches of the same install keep the values', () async {
    final MemoryStore secure = MemoryStore()..values['id'] = 'kept';
    final MemoryStore local = MemoryStore()..values[FreshInstall.markerKey] = '1';

    expect(await FreshInstall.resetIfNew(secure: secure, local: local, keys: const <String>['id']), isFalse);
    expect(secure.values['id'], 'kept');
  });
}
