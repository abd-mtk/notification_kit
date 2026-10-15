import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fpdart/fpdart.dart';

import '../messages/extensions.dart';

final class NotificationImage {
  const NotificationImage(this.bytes, this.extension);

  final Uint8List bytes;

  final String extension;

  ByteArrayAndroidBitmap get androidBitmap => ByteArrayAndroidBitmap(bytes);
}

typedef NotificationImageLoader = Future<Option<NotificationImage>> Function(String url);

abstract final class NotificationImages {
  static const Map<String, String> extensions = <String, String>{'png': 'png', 'gif': 'gif'};

  static Future<Option<NotificationImage>> download(
    final String url, {
    final Duration timeout = const Duration(seconds: 10),
    final int maxBytes = 5 * 1024 * 1024,
  }) async {
    final HttpClient client = HttpClient()..connectionTimeout = timeout;
    try {
      return await fetch(client, Uri.parse(url), maxBytes).timeout(timeout);
    } on Object {
      return const None();
    } finally {
      client.close(force: true);
    }
  }

  static Future<Option<NotificationImage>> none(final String url) async => const None();

  static Future<Option<NotificationImage>> fetch(final HttpClient client, final Uri uri, final int maxBytes) async {
    final HttpClientResponse response = await (await client.getUrl(uri)).close();
    if (!response.isOk) return const None();
    if (response.headers.contentType case ContentType(primaryType: 'image', :final String subType)) {
      final BytesBuilder bytes = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        bytes.add(chunk);
        if (bytes.length > maxBytes) return const None();
      }
      return some(
        NotificationImage(bytes.takeBytes(), Option.fromNullable(extensions[subType]).getOrElse(() => 'jpg')),
      );
    }
    return const None();
  }

  static Future<String> writeAttachment(
    final NotificationImage image, {
    required final int id,
    required final Directory directory,
  }) async {
    final File file = File('${directory.path}/nk_${id}_${DateTime.now().microsecondsSinceEpoch}.${image.extension}');
    await file.writeAsBytes(image.bytes, flush: true);
    return file.path;
  }
}
