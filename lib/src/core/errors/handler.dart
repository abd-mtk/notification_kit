import 'package:flutter/services.dart';

import 'error_envelope.dart';
import 'exceptions.dart';
import 'failures.dart';
import 'types.dart';

abstract final class FailureHandler {
  static ServiceFailure from(final Object error, {required final String operation}) => switch (error) {
    final ServiceException exception => ServiceFailure(
      type: exception.statusCode == 401 ? FailureType.unauthenticated : FailureType.server,
      operation: operation,
      statusCode: exception.statusCode,
      serverMessage: ErrorEnvelope.message(exception.body),
      errorCode: ErrorEnvelope.code(exception.body),
      fieldErrors: ErrorEnvelope.fieldErrors(exception.body),
      correlationId: ErrorEnvelope.correlationId(exception.body),
    ),
    final NetworkException exception => ServiceFailure(
      type: exception.timedOut ? FailureType.timeout : FailureType.connection,
      operation: operation,
      details: exception.message,
    ),
    final DecodeException exception => ServiceFailure(
      type: FailureType.decoding,
      operation: operation,
      details: exception.message,
    ),
    final PlatformException exception => ServiceFailure(
      type: FailureType.platform,
      operation: operation,
      details: '${exception.code}: ${exception.message}',
    ),
    final PushException exception => ServiceFailure(
      type: FailureType.platform,
      operation: operation,
      details: exception.message,
    ),
    _ => ServiceFailure(type: FailureType.unknown, operation: operation, details: '$error'),
  };
}
