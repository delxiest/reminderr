// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget createTextArea(
  String text,
  String fallbackName,
  void Function(String text) setter
) => TextField(
  controller: TextEditingController()..text = text,
  maxLines: null,
  decoration: InputDecoration.collapsed(hintText: "Enter your $fallbackName here"),
  onChanged: setter,
);

void route(
    BuildContext context,
    Widget Function(BuildContext) builder
) {
  Navigator.push(context, MaterialPageRoute(builder: builder));
}

void handleDateTime(BuildContext context, void Function(DateTime) handler) {
  showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730))
  ).then((date) {
    if(date != null) {
      showTimePicker(
          context: context,
          initialTime: TimeOfDay.now()
      ).then((time) {
        if(time != null) {
          final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute, 0);

          handler(dateTime);
        }
      });
    }
  });
}

int bytesToInt(Uint8List bytes) => bytes.buffer.asByteData().getInt64(0);

Uint8List intToBytes(int value) => (ByteData(8)..setInt64(0, value)).buffer.asUint8List(0);