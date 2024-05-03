import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health_fitness/model/water_model.dart';
import 'package:health_fitness/features/home/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationLogic {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'Water Reminder',
        'Don\'t forget to drink water',
        importance: Importance.max,
        priority: Priority.max,
      ),
    );
  }

  static Future init(BuildContext context, String uid) async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('time_workout');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      try {
        WaterModel waterModel = WaterModel();
        waterModel.time = Timestamp.fromDate(DateTime.now());
        waterModel.millLiters = 200;
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('water-model')
            .doc()
            .set(waterModel.toMap());
        Fluttertoast.showToast(msg: 'Addition Successful');
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        print(e);
      }
      onNotifications.add(payload as String?);
    });
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime dateTime,
  }) async {
    print('yes 2');
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(const Duration(days: 1));
    }
    print('yes 3');
    print(tz.TZDateTime.now(tz.local));
    print(
      tz.TZDateTime.from(dateTime, tz.local),
    );
    _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      await _notificationDetails(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
