import 'dart:io';
import 'ios_service_extension_templates.dart';

typedef ProcessRunner = Future<ProcessResult> Function(String executable, List<String> arguments);

final class IosSetupResult {
  const IosSetupResult.success(this.message) : succeeded = true;

  const IosSetupResult.failure(this.message) : succeeded = false;

  final bool succeeded;

  final String message;
}

final class IosServiceExtensionSetup {
  const IosServiceExtensionSetup({required this.appRoot, this.run = Process.run});

  static const String targetName = 'NotificationService';

  static const String missingProject =
      'ios/Runner.xcodeproj not found. Run this command from the root of your Flutter app.';

  static const String missingGem = 'The xcodeproj Ruby gem is required. Install it with: gem install xcodeproj';

  final Directory appRoot;

  final ProcessRunner run;

  Directory get iosDirectory => Directory('${appRoot.path}/ios');

  Directory get extensionDirectory => Directory('${iosDirectory.path}/$targetName');

  String get projectPath => '${iosDirectory.path}/Runner.xcodeproj';

  Future<IosSetupResult> setUp() async {
    if (!File('$projectPath/project.pbxproj').existsSync()) return const IosSetupResult.failure(missingProject);

    await writeSources();
    final Directory scripts = await Directory.systemTemp.createTemp('signalplus');
    try {
      final ProcessResult result = await run('ruby', <String>[await writeScript(scripts), projectPath]);
      if (result.exitCode == 0) return IosSetupResult.success('${result.stdout}'.trim());
      final String error = '${result.stderr}'.trim();
      return IosSetupResult.failure(error.contains('cannot load such file -- xcodeproj') ? missingGem : error);
    } finally {
      await scripts.delete(recursive: true);
    }
  }

  Future<void> writeSources() async {
    await extensionDirectory.create(recursive: true);
    final Map<String, String> sources = <String, String>{
      'NotificationService.swift': notificationServiceSwift,
      'Info.plist': notificationServiceInfoPlist,
      'NotificationService.xcconfig': notificationServiceXcconfig,
    };
    for (final MapEntry<String, String> source in sources.entries) {
      final File file = File('${extensionDirectory.path}/${source.key}');
      if (!file.existsSync()) await file.writeAsString(source.value.trimLeft());
    }
  }

  Future<String> writeScript(final Directory directory) async {
    final File script = File('${directory.path}/add_notification_service.rb');
    await script.writeAsString(addTargetRubyScript.trimLeft());
    return script.path;
  }
}
