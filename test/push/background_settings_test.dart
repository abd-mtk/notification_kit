import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus/src/signal_plus/background_entry.dart';

import '../support/device_fakes.dart';

void main() {
  test('the display config survives for the background isolate', () async {
    final MemoryStore store = MemoryStore();

    await BackgroundSettings.saveConfig(
      store,
      const PushConfig.resolved(
        appName: 'App',
        channelName: 'General',
        channelDescription: 'D',
        showNotificationImages: false,
        groupNotifications: true,
      ),
    );
    final PushConfig config = (await BackgroundSettings.readConfig(
      store,
    )).getOrElse(() => throw StateError('no config'));

    expect(config.appName, 'App');
    expect(config.channelId, PushConfig.defaultChannelId);
    expect(config.showNotificationImages, isFalse);
    expect(config.groupNotifications, isTrue);
    expect(config.enableLogs, isTrue);
  });

  test('nothing is read when nothing was saved', () async {
    expect(await BackgroundSettings.readConfig(MemoryStore()), const None());
    expect(await BackgroundSettings.readHandler(MemoryStore()), const None());
  });
}
