import 'dart:io';
import 'package:signalplus/src/setup/ios_service_extension_setup.dart';

Future<void> main() async {
  final result = await IosServiceExtensionSetup(appRoot: Directory.current).setUp();
  (result.succeeded ? stdout : stderr).writeln(result.message);
  exitCode = result.succeeded ? 0 : 1;
}
