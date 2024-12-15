import 'dart:collection';
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:june/june.dart';
import 'package:reminder/main.dart';
import 'package:reminder/reminds.g.dart';
import 'package:reminder/states.dart';
import 'package:reminder/utility.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class RemindPage extends StatefulWidget {
  final FlutterRemind remind;

  const RemindPage({super.key, required this.remind});

  @override
  State<RemindPage> createState() => _RemindPageState(remind);
}

class _RemindPageState extends State<RemindPage> {
  final FlutterRemind remind;

  _RemindPageState(this.remind);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            refreshReminds();
            Navigator.maybePop(context);
          },
          icon: const Icon(Icons.arrow_back)
        ),
        actions: [
          IconButton(
            onPressed: () => handleDateTime(context, (dateTime) => remind.dateTime = dateTime),
            icon: const Icon(Icons.date_range_rounded)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            createTextArea(remind.title, "Title", (text) => remind.title = text),
            createTextArea(remind.body, "Body", (text) => remind.body = text)
          ],
        )
      )
    );
  }
}

class FlutterRemind {
  int id;
  String title;
  String body;
  DateTime dateTime;
  int lastModified = -1;

  FlutterRemind(this.id, this.title, this.body, this.dateTime);
}

Widget createRemindWidget(BuildContext context, FlutterRemind remind) {
  return Stack(
    children: [
      Card(
        child: InkWell(
            child: ListTile(
                title: Text(remind.title),
                subtitle: Text(remind.body)
            ),
            onTap: () => route(context, (context) => RemindPage(remind: remind))
        )
      )
    ],
  );
}

var reminds = <int, FlutterRemind>{};
// var reminds = HashMap<int, FlutterRemind>();

/*Set<FlutterRemind> getReminds() {
  // await Future.wait(futures)
  final androidReminds = RemindHostApi().getReminds().then((androidReminds) {
    return androidReminds;
  });

  an

  final androidReminds = RemindHostApi().getReminds();
  final flutterReminds = <FlutterRemind>[];

  androidReminds.
  for(final androidRemind in androidReminds) {
    flutterReminds.add(FlutterRemind(androidRemind!.name!, androidRemind.body!, DateTime.fromMillisecondsSinceEpoch(androidRemind.timestamp!)));
  }

  return flutterReminds;

  return {
    FlutterRemind("first", "body1", DateTime.now().add(const Duration(milliseconds: 30000))),
    FlutterRemind("second", "body2", DateTime.now().add(const Duration(milliseconds: 40000))),
    FlutterRemind("third", "body3", DateTime.now().add(const Duration(milliseconds: 70000)))
  };
}*/

void spawnNotify(FlutterRemind remind) async {
  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  print(tz.TZDateTime.from(remind.dateTime, tz.local));
  await flutterLocalNotificationsPlugin.zonedSchedule(remind.id, remind.title, remind.body, tz.TZDateTime.from(remind.dateTime, tz.local), const NotificationDetails(android: AndroidNotificationDetails('zov', 'zov')), uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}

void createRemind(DateTime dateTime) {
  final id = Random().nextInt(1000);
  final remind = FlutterRemind(id, "A remind", "A description", dateTime);

  reminds[id] = remind;
  spawnNotify(remind);
  refreshReminds();
}

List<Widget> getRemindWidgets(BuildContext context) {
  final widgets = <Widget>{};

  for(final remind in reminds.values) {
    final widget = createRemindWidget(context, remind);

    widgets.add(widget);
  }

  return widgets.toList();
}