import 'package:flutter_test/flutter_test.dart';
import 'package:signalplus/signalplus.dart';
import 'package:signalplus_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a payload without a route opens nothing', () {
    openFromNotification(const NotificationPayload(title: 'T', body: '', data: <String, dynamic>{}));

    expect(navigatorKey.currentState, isNull);
  });
}
