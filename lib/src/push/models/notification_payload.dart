import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../messages/extensions.dart';
import '../messages/message_keys.dart';

final class NotificationPayload extends Equatable {
  const NotificationPayload({
    required this.title,
    required this.body,
    required this.data,
    this.rawPayload = const None(),
  });

  factory NotificationPayload.fromMap(
    final Map<String, dynamic> map, {
    final String defaultTitle = '',
    final String defaultBody = '',
  }) {
    final Map<dynamic, dynamic> nested = map.mapAt(MessageKeys.notification);
    return NotificationPayload(
      title: map
          .nonEmptyTextAt(MessageKeys.title)
          .alt(() => nested.nonEmptyTextAt(MessageKeys.title))
          .getOrElse(() => defaultTitle),
      body: map
          .nonEmptyTextAt(MessageKeys.body)
          .alt(() => nested.nonEmptyTextAt(MessageKeys.body))
          .getOrElse(() => defaultBody),
      data: map,
    );
  }

  final String title;

  final String body;

  final Map<String, dynamic> data;

  final Option<String> rawPayload;

  Option<String> get notifyId => data.nonEmptyTextAt(MessageKeys.notifyId);

  Option<String> get category => data.nonEmptyTextAt(MessageKeys.category);

  @override
  List<Object> get props => <Object>[title, body, data, rawPayload];
}
