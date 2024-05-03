import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_fitness/common_widgets/add_alert_dialogue.dart';
import 'package:health_fitness/common_widgets/reminder_delete_dialogue.dart';
import 'package:health_fitness/common_widgets/switch.dart';
import 'package:health_fitness/services/notification_logic.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/activity_tracker/activity_tracker_screen.dart';
import 'package:intl/intl.dart';

class ReminderScheduler extends StatefulWidget {
  final DateTime sleepTime;
  final DateTime wakeTime;

  ReminderScheduler(this.wakeTime, this.sleepTime);

  @override
  State<ReminderScheduler> createState() => _ReminderSchedulerState();
}

class _ReminderSchedulerState extends State<ReminderScheduler> {
  User? user;
  bool on = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    NotificationLogic.init(context, user!.uid);
    listenNotifications();
  }

  void listenNotifications() {
    NotificationLogic.onNotifications.listen((value) {});
  }

  void onClickedNotification(String? payload) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ActivityTrackerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/icons/back_icon.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          "Schedule Reminder",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () async {
          addAlertDialogue(
              context, widget.sleepTime, widget.wakeTime, user!.uid);
        },
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))
              ]),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('reminder')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4FA8C5)),
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text("Nothing to show"));
            }
            final data = snapshot.data;
            return ListView.builder(
                itemCount: data?.docs.length,
                itemBuilder: (context, index) {
                  Timestamp t = data?.docs[index].get('time');
                  DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                      t.microsecondsSinceEpoch);

                  String formattedTime = DateFormat.jm().format(date);
                  on = data!.docs[index].get('onOff');
                  if (on) {
                    NotificationLogic.showNotification(
                        dateTime: date,
                        id: 0,
                        title: 'Water Reminder',
                        body: "Don\'t forget to drink water");
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                formattedTime,
                                style: TextStyle(fontSize: 30),
                              ),
                              subtitle: Text(
                                "Everyday",
                              ),
                              trailing: Container(
                                width: 110,
                                child: Row(
                                  children: [
                                    Switcher(on, user!.uid, data.docs[index].id,
                                        data.docs[index].get('time')),
                                    IconButton(
                                        onPressed: () {
                                          reminderDeleteAlertDialogue(context,
                                              data.docs[index].id, user!.uid);
                                        },
                                        icon: FaIcon(
                                            FontAwesomeIcons.circleXmark))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                });
          }),
    );
  }
}
