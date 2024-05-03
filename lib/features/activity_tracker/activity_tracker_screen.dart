import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/utils/constants.dart';
import 'package:health_fitness/features/activity_tracker/reminder_scheduler.dart';
import 'package:health_fitness/features/activity_tracker/widgets/today_target_cell.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ActivityTrackerScreen extends StatefulWidget {
  static String routeName = "/ActivityTrackerScreen";
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  late String uid;

  final wakeTimeController = TextEditingController();
  final sleepTimeController = TextEditingController();
  final waterIntakeController = TextEditingController();
  final stepsTargetController = TextEditingController();
  TimeOfDay sleepTime = TimeOfDay.now();
  TimeOfDay wakeTime = TimeOfDay.now();

  Future<void> fetchUserData() async {
    int retries = 3;
    while (retries > 0) {
      try {
        // Get the current user
        user = _auth.currentUser;

        if (user != null) {
          // Get user details
          uid = user!.uid;

          // Fetch additional user data from Firestore
          DocumentSnapshot userSnapshot =
              await _firestore.collection('users').doc(uid).get();

          // Update state with fetched data
          setState(() {
            // final format = DateFormat.jm();
            // sleepTime = format.parse(userSnapshot['sleeptime']) as TimeOfDay;
            // wakeTime = format.parse(userSnapshot['waketime']) as TimeOfDay;

            sleepTimeController.text = userSnapshot['sleeptime'].toString();
            wakeTimeController.text = userSnapshot['waketime'].toString();

            waterIntakeController.text = userSnapshot['waterTarget'].toString();
            stepsTargetController.text = userSnapshot['stepsTarget'].toString();

            print(wakeTimeController.text);
            print(sleepTimeController.text);
            print(waterIntakeController.text);
            print(stepsTargetController.text);
          });
        }

        return; // Operation succeeded
      } catch (e) {
        print(e.toString());
        retries--;
        await Future.delayed(Duration(seconds: 5)); // Retry after 5 seconds
      }
    }
    print("Exceeded maximum retries. Unable to fetch data.");
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  final CollectionReference _users =
      FirebaseFirestore.instance.collection("users");
  Future<void> _showInputDialog(BuildContext context) async {
    // TextEditingController waterController = TextEditingController();
    // TextEditingController stepsController = TextEditingController();
    // final wakeTimeController = TextEditingController();
    // final sleepTimeController = TextEditingController();
    // TimeOfDay sleepTime = TimeOfDay.now();
    // TimeOfDay wakeTime = TimeOfDay.now();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Set Targets'),
            content: Container(
              height: 300,
              child: Column(
                children: [
                  TextFormField(
                    controller: waterIntakeController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: 'Water Target'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter water target';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: stepsTargetController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Steps Target',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter steps target';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: sleepTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Sleep Time',
                      suffixIcon: IconButton(
                          onPressed: () async {
                            TimeOfDay? newTime = await showTimePicker(
                                context: context, initialTime: sleepTime);
                            if (newTime == null) return;
                            setState(() {
                              sleepTime = newTime;
                              sleepTimeController.text =
                                  newTime.format(context).toString();
                            });
                          },
                          icon: Icon(Icons.timer)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Sleep Time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: wakeTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Wake Time',
                      suffixIcon: IconButton(
                          onPressed: () async {
                            TimeOfDay? newTime = await showTimePicker(
                                context: context, initialTime: wakeTime);
                            if (newTime == null) return;
                            setState(() {
                              wakeTime = newTime;
                              wakeTimeController.text =
                                  newTime.format(context).toString();
                            });
                          },
                          icon: Icon(Icons.timer)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Wake Time';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (waterIntakeController.text.isNotEmpty &&
                      stepsTargetController.text.isNotEmpty &&
                      sleepTimeController.text.isNotEmpty &&
                      wakeTimeController.text.isNotEmpty) {
                    // Save the targets to Firestore
                    await saveTargetsToFirestore(
                        int.parse(stepsTargetController.text),
                        sleepTime,
                        wakeTime,
                        context,
                        int.parse(waterIntakeController.text));
                  }

                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveTargetsToFirestore(stepsTarget, TimeOfDay sleepTime,
      TimeOfDay wakeTime, BuildContext context, int waterTarget) async {
    try {
      String userId = FirebaseAuth
          .instance.currentUser!.uid; // Replace with the actual user ID

      await _users.doc(userId).update({
        'waterTarget': waterTarget.toString(),
        'stepsTarget': stepsTarget.toString(),
        'sleeptime': sleepTime.format(context).toString(),
        'waketime': wakeTime.format(context).toString(),
      });

      // Optional: Show a success message or perform additional actions
      print('Targets saved successfully!');
    } catch (error) {
      // Handle errors (e.g., show an error message)
      print('Error saving targets: $error');
    }
  }

  int touchedIndex = -1;

  List latestArr = [
    {
      "image": "assets/images/pic_4.png",
      "title": "Drinking 300ml Water",
      "time": "About 1 minutes ago"
    },
    {
      "image": "assets/images/pic_5.png",
      "title": "Eat Snack (Fitbar)",
      "time": "About 3 hours ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
          "Activity Tracker",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReminderScheduler(
                    TimeConverter(wakeTime),
                    TimeConverter(sleepTime),
                  ),
                ),
              );
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
                "assets/icons/time_workout.png",
                width: 25,
                height: 25,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primaryColor2.withOpacity(0.3),
                    AppColors.primaryColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today Target",
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: () {
                                  _showInputDialog(context);
                                },
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: AppColors.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/water_icon.png",
                            value: "${waterIntakeController.text} ML",
                            title: "Water Intake",
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/foot_icon.png",
                            value: "${stepsTargetController.text}",
                            title: "Foot Steps",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/sleep.png",
                            value: "${sleepTimeController.text}",
                            title: "Sleep Time",
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/icons/wakeup.png",
                            value: "${wakeTimeController.text}",
                            title: "Wake Up Time",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Activity Progress",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: ["Weekly", "Monthly"]
                            .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 14),
                                )))
                            .toList(),
                        onChanged: (value) {},
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.whiteColor),
                        hint: const Text("Weekly",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.whiteColor, fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: BarChart(BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                      tooltipMargin: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay;
                        switch (group.x) {
                          case 0:
                            weekDay = 'Sunday';
                            break;
                          case 1:
                            weekDay = 'Monday';
                            break;
                          case 2:
                            weekDay = 'Tuesday';
                            break;
                          case 3:
                            weekDay = 'Wednesday';
                            break;
                          case 4:
                            weekDay = 'Thursday';
                            break;
                          case 5:
                            weekDay = 'Friday';
                            break;
                          case 6:
                            weekDay = 'Saturday';
                            break;
                          default:
                            throw Error();
                        }
                        return BarTooltipItem(
                          '$weekDay\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY - 1).toString(),
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getTitles,
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingGroups(),
                  gridData: FlGridData(show: false),
                )),
              ),
              // SizedBox(
              //   height: media.width * 0.05,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       "Latest Workout",
              //       style: TextStyle(
              //           color: AppColors.blackColor,
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700),
              //     ),
              //     TextButton(
              //       onPressed: () {},
              //       child: const Text(
              //         "See More",
              //         style: TextStyle(
              //             color: AppColors.grayColor,
              //             fontSize: 14,
              //             fontWeight: FontWeight.w700),
              //       ),
              //     )
              //   ],
              // ),
              // ListView.builder(
              //     padding: EdgeInsets.zero,
              //     physics: const NeverScrollableScrollPhysics(),
              //     shrinkWrap: true,
              //     itemCount: latestArr.length,
              //     itemBuilder: (context, index) {
              //       var wObj = latestArr[index] as Map? ?? {};
              //       return LatestActivityRow(wObj: wObj);
              //     }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.grayColor,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('Sun', style: style);
        break;
      case 1:
        text = Text('Mon', style: style);
        break;
      case 2:
        text = Text('Tue', style: style);
        break;
      case 3:
        text = Text('Wed', style: style);
        break;
      case 4:
        text = Text('Thu', style: style);
        break;
      case 5:
        text = Text('Fri', style: style);
        break;
      case 6:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, AppColors.primaryG,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 10.5, AppColors.secondaryG,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, AppColors.primaryG,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, AppColors.secondaryG,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 15, AppColors.primaryG,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 5.5, AppColors.secondaryG,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 8.5, AppColors.primaryG,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(
              colors: barColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: AppColors.lightGrayColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
