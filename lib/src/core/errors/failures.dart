import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../utils/option_extensions.dart';
import 'error_envelope.dart';
import 'types.dart';

final class ServiceFailure extends Equatable {
  const ServiceFailure({
    required this.type,
    required this.operation,
    this.statusCode = -1,
    this.serverMessage = const None(),
    this.errorCode = const None(),
    this.fieldErrors = const <FieldError>[],
    this.correlationId = const None(),
    this.details = '',
  });

  final FailureType type;

  final String operation;

  final int statusCode;

  final Option<String> serverMessage;

  final Option<String> errorCode;

  final List<FieldError> fieldErrors;

  final Option<String> correlationId;

  final String details;

  String get message => serverMessage.getOrElse(() => errorCode.getOrElse(() => type.code));

  bool hasCode(final String value) =>
      errorCode.exists((final String code) => code == value) ||
      fieldErrors.any((final FieldError error) => error.code == value);

  Option<FieldError> fieldError(final String property) =>
      fieldErrors.firstWhereOption((final FieldError error) => error.property.toLowerCase() == property.toLowerCase());

  Map<String, Object> toJson() => <String, Object>{
    'Operation': operation,
    'Type': type.code,
    'StatusCode': statusCode,
    ...serverMessage.match(() => const <String, Object>{}, (final String text) => <String, Object>{'Message': text}),
    ...errorCode.match(() => const <String, Object>{}, (final String code) => <String, Object>{'ErrorCode': code}),
    if (fieldErrors.isNotEmpty) 'FieldErrors': fieldErrors.map((final FieldError error) => error.toJson()).toList(),
    ...correlationId.match(() => const <String, Object>{}, (final String id) => <String, Object>{'CorrelationId': id}),
    if (details.isNotEmpty) 'Details': details,
  };

  @override
  String toString() => 'ServiceFailure(${toJson()})';

  @override
  List<Object> get props => <Object>[
    type,
    operation,
    statusCode,
    serverMessage,
    errorCode,
    fieldErrors,
    correlationId,
    details,
  ];
}
