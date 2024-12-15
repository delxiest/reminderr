import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/reminds.g.dart',
  dartOptions: DartOptions(),
  // cppOptions: CppOptions(namespace: 'pigeon_example'),
  // cppHeaderOut: 'windows/runner/messages.g.h',
  // cppSourceOut: 'windows/runner/messages.g.cpp',
  // gobjectHeaderOut: 'linux/messages.g.h',
  // gobjectSourceOut: 'linux/messages.g.cc',
  // gobjectOptions: GObjectOptions(),
  kotlinOut: 'android/app/src/main/kotlin/wtf/reminder/reminder/Reminds.g.kt',
  kotlinOptions: KotlinOptions(),
  // javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  // javaOptions: JavaOptions(),
  // swiftOut: 'ios/Runner/Messages.g.swift',
  // swiftOptions: SwiftOptions(),
  // objcHeaderOut: 'macos/Runner/messages.g.h',
  // objcSourceOut: 'macos/Runner/messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  // objcOptions: ObjcOptions(prefix: 'PGN'),
  // copyrightHeader: 'pigeons/copyright.txt',
  // dartPackageName: 'pigeon_example_package',
))

class Remind {
  int? id;
  String? name;
  String? body;
  int? timestamp;
}

@HostApi()
abstract class RemindHostApi {
  List<Remind?> getReminds();
  String getLocalStorage();
}

@FlutterApi()
abstract class RemindFlutterApi {
  void syncReminds(List<Remind?> reminds);
}