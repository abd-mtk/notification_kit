import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../utils/option_extensions.dart';

final class FieldError extends Equatable {
  const FieldError({required this.property, required this.code, required this.message});

  final String property;

  final String code;

  final String message;

  Map<String, String> toJson() => <String, String>{'Property': property, 'Code': code, 'Message': message};

  @override
  List<Object> get props => <Object>[property, code, message];
}

abstract final class ErrorEnvelope {
  static const String correlationPrefix = 'CorrelationId=';

  static Option<String> message(final Object? body) {
    if (body is! Map) return const None();
    final Object? message = body['Message'];
    return message is String && message.trim().isNotEmpty ? some(message.trim()) : const None();
  }

  static List<String> errorLines(final Object? body) {
    if (body is! Map) return const <String>[];
    final Object? lines = body['Error'];
    if (lines is! List) return const <String>[];
    return <String>[
      for (final Object? line in lines)
        if (line is String && line.trim().isNotEmpty) line.trim(),
    ];
  }

  static Option<String> code(final Object? body) => errorLines(body).firstOption;

  static List<FieldError> fieldErrors(final Object? body) {
    if (body is! Map) return const <FieldError>[];
    final Object? data = body['Data'];
    if (data is! Map) return const <FieldError>[];
    final Object? errors = data['Errors'];
    if (errors is! List) return const <FieldError>[];
    return <FieldError>[
      for (final Object? error in errors)
        if (error is Map)
          FieldError(
            property: '${error['Property'] ?? ''}',
            code: '${error['Code'] ?? ''}',
            message: '${error['Message'] ?? ''}',
          ),
    ];
  }

  static Option<String> correlationId(final Object? body) => errorLines(body)
      .firstWhereOption((final String line) => line.startsWith(correlationPrefix))
      .map((final String line) => line.substring(correlationPrefix.length))
      .filter((final String id) => id.isNotEmpty);
}
