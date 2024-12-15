import 'dart:convert';
import 'dart:io';

import 'package:byte_util/byte_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_util_code/path_utils.dart';
import 'package:june/june.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:reminder/reminds.dart';
import 'package:reminder/reminds.g.dart';
import 'package:reminder/states.dart';
import 'package:reminder/utility.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() {
  runApp(const MyApp());
  initNotifies();
  loadReminds();
}

void initNotifies() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
  const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsDarwin, macOS: initializationSettingsDarwin, linux: initializationSettingsLinux);
  flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (details) {});

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestExactAlarmsPermission();
}

void refreshNotifies() async {
  final notifies = await flutterLocalNotificationsPlugin.pendingNotificationRequests();

  for(final notify in notifies) {
    await flutterLocalNotificationsPlugin.cancel(notify.id);
    if(reminds.containsKey(notify.id)) {
      final remind = reminds[notify.id]!;

      print("rebuilds ${remind.id}");

      spawnNotify(remind);

    }
  }
}

void loadReminds() async {
  /*final androidReminds = await RemindHostApi().getReminds();
  final flutterReminds = <FlutterRemind>[];
-
  for(final androidRemind in androidReminds) {
    flutterReminds.add(FlutterRemind(androidRemind!.name!, androidRemind.body!, DateTime.fromMillisecondsSinceEpoch(androidRemind.timestamp!)));
  }

  reminds = flutterReminds;

  refreshReminds();*/

  final filesPath = await RemindHostApi().getLocalStorage();
  print(filesPath);

  final files = Directory(filesPath);


  // final localPath = await PathUtils.getAndroidStoragePath();
  // final directory = Directory(localPath);
  // final localPath = await getApplicationDocumentsDirectory();
  var id = 0;

  for(final entity in await files.list().toList()) {
    if(entity.statSync().type == FileSystemEntityType.file) {
      final file = File(entity.absolute.path);
      final bytes = file.readAsBytesSync();

      print(entity.absolute.path);
      print(entity.path);

      try {
        final titleFlag = bytes.sublist(0, 8);
        final titleLength = bytesToInt(titleFlag);
        // final titleData = bytes.sublist(64, 64 + titleLength);
        print("$titleFlag $titleLength ${bytes}");
        final bodyFlag = bytes.sublist(8 + titleLength, 16 + titleLength);
        final bodyLength = bytesToInt(bodyFlag);
        // final bodyData = bytes.sublist(128 + titleLength, 128 + titleLength + bodyLength);

        // final title = ByteUtil.extract(origin: titleData, indexStart: 0, length: titleLength);
        final title = utf8.decode(bytes.sublist(8, 8 + titleLength));
        final body = utf8.decode(bytes.sublist(16 + titleLength, 16 + titleLength + bodyLength));
        final timestamp = bytesToInt(bytes.sublist(16 + titleLength + bodyLength, 24 + titleLength + bodyLength));

        final remind = FlutterRemind(id, title, body, DateTime.fromMillisecondsSinceEpoch(timestamp));

        reminds[id] = remind;

        id++;
      } catch(err, stacktrace) {
        print("error lol");
        print(err);
        print(stacktrace);
      }
    }
  }
}

void syncReminds() async {
  final filesPath = await RemindHostApi().getLocalStorage();
  print(filesPath);

  final files = Directory(filesPath);
  // final localPath = await getApplicationDocumentsDirectory();
  // final localPath = await PathUtils.getAndroidStoragePath();
  final directory = Directory(filesPath);

  for(final entity in await directory.list().toList()) {
    if(entity.statSync().type == FileSystemEntityType.file) {
      entity.deleteSync();
    }
  }

  for(final remind in reminds.values) {
    final titleData = utf8.encode(remind.title);
    final bodyData = utf8.encode(remind.body);
    final bytes = <int>[];//(64 * 3 + titleData.length + bodyData.length);

    bytes.addAll(intToBytes(titleData.length));
    bytes.addAll(titleData);
    bytes.addAll(intToBytes(bodyData.length));
    bytes.addAll(bodyData);
    bytes.addAll(intToBytes(remind.dateTime.millisecond));

    final file = File("${filesPath
    }/remind${remind.id}");

    file.createSync();
    file.writeAsBytes(bytes);

    // bytes.setRange();

    // bytes[0] = intToBytes(titleData.length);
  }

  refreshNotifies();
}

/*class FlutterApi extends RemindFlutterApi {
  @override
}*/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /*@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'reminder'),
    );
  }*/
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      loadReminds();
    } else {
      syncReminds();
    }
    print("changing lifecycle $state");

    // RemindFlutterApi().syncReminds(reminds)
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'reminder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: JuneBuilder(
            () => EmptyState(),
          tag: "Reminds",
          builder: (_) => Column(
            children: getRemindWidgets(context),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => handleDateTime(context, createRemind),
        tooltip: 'Create a remind',
        child: const Icon(Icons.add),
      ),
    );
  }
}
