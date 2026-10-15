import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:signalplus/src/push/notification/notification_image.dart';

void main() {
  late HttpServer server;
  late String base;
  final List<int> png = List<int>.generate(64, (final int index) => index);

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = 'http://${server.address.host}:${server.port}';
    server.listen((final HttpRequest request) async {
      final HttpResponse response = request.response;
      switch (request.uri.path) {
        case '/ok.png':
          response.headers.contentType = ContentType('image', 'png');
          response.add(png);
        case '/photo.jpg':
          response.headers.contentType = ContentType('image', 'jpeg');
          response.add(png);
        case '/text':
          response.headers.contentType = ContentType.text;
          response.write('not an image');
        case '/big.png':
          response.headers.contentType = ContentType('image', 'png');
          response.add(List<int>.filled(2048, 0));
        case '/slow.png':
          await Future<void>.delayed(const Duration(milliseconds: 500));
          response.headers.contentType = ContentType('image', 'png');
          response.add(png);
        default:
          response.statusCode = HttpStatus.notFound;
      }
      await response.close();
    });
  });

  tearDown(() => server.close(force: true));

  test('an image returns its bytes and extension', () async {
    final Option<NotificationImage> image = await NotificationImages.download('$base/ok.png');

    expect(image.map((final NotificationImage value) => value.bytes).toNullable(), png);
    expect(image.map((final NotificationImage value) => value.extension), const Some('png'));
  });

  test('image/jpeg maps to jpg', () async {
    expect(
      (await NotificationImages.download('$base/photo.jpg')).map((final NotificationImage value) => value.extension),
      const Some('jpg'),
    );
  });

  test('404, non images, oversized images, timeouts and unreachable hosts give nothing', () async {
    expect(await NotificationImages.download('$base/missing.png'), const None());
    expect(await NotificationImages.download('$base/text'), const None());
    expect(await NotificationImages.download('$base/big.png', maxBytes: 1024), const None());
    expect(
      await NotificationImages.download('$base/slow.png', timeout: const Duration(milliseconds: 100)),
      const None(),
    );
    expect(await NotificationImages.download('http://127.0.0.1:1/x.png'), const None());
  });
}
