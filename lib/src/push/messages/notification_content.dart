import 'package:fpdart/fpdart.dart';

final class NotificationContent {
  const NotificationContent({
    required this.id,
    required this.title,
    required this.body,
    this.data = const <String, dynamic>{},
    this.imageUrl = const None(),
    this.channelId = const None(),
  });

  final int id;

  final String title;

  final String body;

  final Map<String, dynamic> data;

  final Option<String> imageUrl;

  final Option<String> channelId;
}
