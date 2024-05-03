import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health_fitness/model/water_model.dart';
import 'package:health_fitness/radial_painter.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/activity_tracker/activity_tracker_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../common_widgets/round_button.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  late String uid;
  String firstName = '';
  String lastName = '';
  String sleepTime = '';
  String wakeTime = '';
  double weight = 0;
  double height = 0;
  int stepsTarget = 0;
  int waterTarget = 0;
  String difference = "";

  late Stream<StepCount> _stepCountStream;
  String _steps = '0';

// Function to calculate time difference
  String calculateTimeDifference(String startTime, String endTime) {
    // Parse time strings into DateTime objects
    DateFormat format = DateFormat('hh:mm a');
    DateTime start = format.parse(startTime);
    DateTime end = format.parse(endTime);

    // If the end time is before the start time, add 1 day to end time
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    // Calculate time difference in minutes
    int differenceInMinutes = end.difference(start).inMinutes;

    // Convert minutes to hours and remaining minutes
    int hours = differenceInMinutes ~/ 60;
    int minutes = differenceInMinutes % 60;

    return '$hours h $minutes m';
  }

  postWaterDetails() {
    try {
      WaterModel waterModel = WaterModel();
      waterModel.time = Timestamp.fromDate(DateTime.now());
      waterModel.millLiters = 200;

      FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('water-model')
          .doc()
          .set(waterModel.toMap());
      Fluttertoast.showToast(msg: "Addition Successful");
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      print(e);
    }
  }

  double idealIntake = 0;
  double intakePercentage = 0;
  int length = 0;

  getSizes() {
    intakePercentage = ((length * 200) / waterTarget) * 100;
  }

  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    fetchUserData(_currentDate);
    // _checkForDayChange();
    initPlatformState();
    getSizes();
  }

  // // Function to check for day change and update step count accordingly
  // void _checkForDayChange() {
  //   // Schedule a periodic check every minute
  //   // You can adjust the duration based on your needs
  //   Timer.periodic(Duration(minutes: 1), (timer) {
  //     DateTime now = DateTime.now();
  //     if (_currentDate.day != now.day) {
  //       // Day has changed
  //       _saveStepCountForPreviousDay(_currentDate, _steps);
  //       // Update current date
  //       _currentDate = now;
  //       // Reset step count for the new day
  //       setState(() {
  //         _steps = "0";
  //       });
  //     }
  //   });
  // }

  // Function to save step count for a specific day to Firebase
  void _saveStepCountForPreviousDay(DateTime date, String stepCount) async {
    String previousDate = _getDateFormatted(date);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('step_counts')
        .doc(previousDate)
        .set({
      'date': previousDate,
      'step_count': stepCount,
    });
  }

  // Function to format date in YYYY-MM-DD format
  String _getDateFormatted(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Function to save step count for the current day to Firebase
  void _saveStepCountForCurrentDay(String stepCount) async {
    String currentDate = _getDateFormatted(_currentDate);
    _firestore
        .collection('users')
        .doc(user?.uid)
        .collection('step_counts')
        .doc(currentDate)
        .set({
      'date': currentDate,
      'step_count': stepCount,
    });
  }

  Future<void> fetchUserData(DateTime date) async {
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

          DocumentSnapshot snapshot = await _firestore
              .collection('users')
              .doc(user?.uid)
              .collection('step_counts')
              .doc(_getDateFormatted(date)) // Use the date as the document ID
              .get();

          // Update state with fetched data
          setState(() {
            firstName = userSnapshot['firstName'] ?? '';
            lastName = userSnapshot['lastName'] ?? '';
            sleepTime = userSnapshot['sleeptime'] ?? '';
            wakeTime = userSnapshot['waketime'] ?? '';
            weight = double.parse(userSnapshot['weight']);
            height = double.parse(userSnapshot['height']);
            waterTarget = int.parse(userSnapshot['waterTarget']);
            stepsTarget = int.parse(userSnapshot['stepsTarget']);
            _steps = snapshot['step_count'];
          });

          difference = calculateTimeDifference(sleepTime, wakeTime);
        }

        return; // Operation succeeded
      } catch (e) {
        retries--;
        await Future.delayed(
            const Duration(seconds: 5)); // Retry after 5 seconds
      }
    }
    print("Exceeded maximum retries. Unable to fetch data.");
  }

  void onPedestrianStatusChanged(PedestrianStatus event) async {
    setState(() {
      _status = event.status;
      int tempvale = int.parse(_steps);
      tempvale++;
      _steps = tempvale.toString();
      _saveStepCountForCurrentDay(_steps);
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  Future<void> initPlatformState() async {
    _saveStepCountForCurrentDay(_steps);

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _saveStepCountForCurrentDay(_steps);
  }

  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40),
      ];

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          AppColors.primaryColor2.withOpacity(0.5),
          AppColors.primaryColor1.withOpacity(0.5),
        ]),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: [
          AppColors.secondaryColor2.withOpacity(0.5),
          AppColors.secondaryColor1.withOpacity(0.5),
        ]),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
        ),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  @override
  void dispose() {
    // DO YOUR STUFF
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            AppColors.primaryColor2.withOpacity(0.4),
            AppColors.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: AppColors.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: AppColors.midGrayColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "$firstName $lastName",
                          style: const TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.065)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/bg_dots.png",
                        height: media.width * 0.4,
                        width: double.maxFinite,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "BMI (Body Mass Index)",
                                  style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "You have a normal weight",
                                  style: TextStyle(
                                    color:
                                        AppColors.whiteColor.withOpacity(0.7),
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: media.width * 0.05),
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: SizedBox(
                                    height: 35,
                                    width: 100,
                                    child: RoundButton(
                                      title: "View More",
                                      onPressed: () {},
                                    ),
                                  ),
                                )
                              ],
                            ),
                            AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (FlTouchEvent event,
                                        pieTouchResponse) {},
                                  ),
                                  startDegreeOffset: 250,
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 1,
                                  centerSpaceRadius: 0,
                                  sections: showingSections(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
                  height: 90,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 90,
                        width: 90,
                        child: CustomPaint(
                          foregroundPainter: RadialPainter(
                            bgColor: Colors.grey[200],
                            lineColor: Colors.green,
                            stepsCount: int.parse(_steps),
                            totalTarget: stepsTarget,
                            widget: 7,
                          ),
                          child: Center(
                            child: Icon(
                              _status == 'walking'
                                  ? Icons.directions_walk
                                  : _status == 'stopped'
                                      ? Icons.accessibility_new
                                      : Icons.accessibility_new,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _steps,
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 1),
                          const Text(
                            "steps",
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        "Goal:",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        stepsTarget.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: media.width * 0.05),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today Target",
                        style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        height: 30,
                        child: RoundButton(
                          title: "check",
                          type: RoundButtonType.primaryBG,
                          onPressed: () {
                            Navigator.pushNamed(
                                context, ActivityTrackerScreen.routeName);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                // StepCounter(),
                SizedBox(height: media.width * 0.05),
                const Text(
                  "Activity Status",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: media.width * 0.02),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: media.width * 0.4,
                    width: media.width,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Heart Rate",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: media.width * 0.01),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: AppColors.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: const Text(
                                  "78 BPM",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        LineChart(
                          LineChartData(
                            showingTooltipIndicators:
                                showingTooltipOnSpots.map((index) {
                              return ShowingTooltipIndicators([
                                LineBarSpot(
                                  tooltipsOnBar,
                                  lineBarsData.indexOf(tooltipsOnBar),
                                  tooltipsOnBar.spots[index],
                                ),
                              ]);
                            }).toList(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;
                                  showingTooltipOnSpots.clear();
                                  setState(() {
                                    showingTooltipOnSpots.add(spotIndex);

                                    // if (showingTooltipOnSpots
                                    //     .contains(spotIndex)) {
                                    //   showingTooltipOnSpots.remove(spotIndex);
                                    // } else {
                                    //   showingTooltipOnSpots.add(spotIndex);
                                    // }
                                  });
                                }
                              },
                              mouseCursorResolver: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: Colors.transparent,
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 3,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: AppColors.secondaryColor2,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: AppColors.secondaryColor1,
                                tooltipRoundedRadius: 20,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    return LineTooltipItem(
                                      //lineBarSpot.y.toString(),
                                      "${lineBarSpot.x.toInt()} mins ago",
                                      const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: lineBarsData,
                            minY: 0,
                            maxY: 130,
                            titlesData: FlTitlesData(show: false),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: media.width * 0.05),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .collection('water-model')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center();
                            }
                            length = (snapshot.data!.docs.length);
                            getSizes();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 25, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  const BoxShadow(
                                      color: Colors.black12, blurRadius: 2)
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SimpleAnimationProgressBar(
                                    height: media.width * 1.1,
                                    width: media.width * 0.07,
                                    backgroundColor: Colors.grey.shade100,
                                    foregrondColor: Colors.purple,
                                    ratio: (length * 200) / waterTarget,
                                    direction: Axis.vertical,
                                    curve: Curves.fastLinearToSlowEaseIn,
                                    duration: const Duration(seconds: 3),
                                    borderRadius: BorderRadius.circular(30),
                                    gradientColor: LinearGradient(
                                      colors: AppColors.primaryG,
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Water",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (length * 200 <
                                                      waterTarget) {
                                                    postWaterDetails();
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            'You have completed your goal');
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.add,
                                                  color:
                                                      AppColors.primaryColor2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: media.width * 0.01),
                                          ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) {
                                              return LinearGradient(
                                                colors: AppColors.secondaryG,
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ).createShader(Rect.fromLTRB(
                                                0,
                                                0,
                                                bounds.width,
                                                bounds.height,
                                              ));
                                            },
                                            child: Text(
                                              "${length * 200}/ ${waterTarget} ML",
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: media.width * 0.03),
                                          const Text(
                                            "Real time updates",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SizedBox(height: media.width * 0.01),
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user?.uid)
                                                  .collection('water-model')
                                                  .orderBy('time')
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center();
                                                }
                                                if (snapshot
                                                    .data!.docs.isEmpty) {
                                                  return const Center(
                                                      child: Text(
                                                          "Nothing to show"));
                                                }
                                                final data = snapshot.data;
                                                return Column(
                                                  children: [
                                                    Container(
                                                      height: media.width * 0.9,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          Timestamp t = data
                                                              .docs[index]
                                                              .get('time');
                                                          DateTime date = DateTime
                                                              .fromMicrosecondsSinceEpoch(
                                                                  t.microsecondsSinceEpoch);
                                                          String formattedTime =
                                                              DateFormat.jm()
                                                                  .format(date);

                                                          return Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4),
                                                                    width: 10,
                                                                    height: 10,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColors
                                                                          .secondaryColor1
                                                                          .withOpacity(
                                                                              0.5),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                  ),
                                                                  DottedDashedLine(
                                                                    width: 0,
                                                                    height: media
                                                                            .width *
                                                                        0.068,
                                                                    axis: Axis
                                                                        .vertical,
                                                                    dashColor: AppColors
                                                                        .secondaryColor1
                                                                        .withOpacity(
                                                                            0.5),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.01),
                                                                  Text(
                                                                    formattedTime
                                                                        .toString(),
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          1),
                                                                  ShaderMask(
                                                                    blendMode:
                                                                        BlendMode
                                                                            .srcIn,
                                                                    shaderCallback:
                                                                        (bounds) {
                                                                      return LinearGradient(
                                                                        colors:
                                                                            AppColors.secondaryG,
                                                                        begin: Alignment
                                                                            .centerLeft,
                                                                        end: Alignment
                                                                            .centerRight,
                                                                      ).createShader(
                                                                          Rect.fromLTRB(
                                                                        0,
                                                                        0,
                                                                        bounds
                                                                            .width,
                                                                        bounds
                                                                            .height,
                                                                      ));
                                                                    },
                                                                    child: Text(
                                                                      data.docs[index]
                                                                              .get('millLiters')
                                                                              .toString() +
                                                                          " ML",
                                                                      style:
                                                                          const TextStyle(
                                                                        color: AppColors
                                                                            .blackColor,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                    SizedBox(width: media.width * 0.05),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sleep",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: media.width * 0.01),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: AppColors.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: Text(
                                  difference,
                                  style: const TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Image.asset(
                                "assets/images/sleep_graph.png",
                                width: double.maxFinite,
                                fit: BoxFit.fitWidth,
                              ))
                            ],
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Calories",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: media.width * 0.01),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: AppColors.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: const Text(
                                  "760 kCal",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: media.width * 0.2,
                                  height: media.width * 0.2,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: media.width * 0.16,
                                        height: media.width * 0.16,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: AppColors.primaryG),
                                            borderRadius: BorderRadius.circular(
                                                media.width * 0.075)),
                                        child: const Text("230kCal\nleft",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.whiteColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      SimpleCircularProgressBar(
                                        startAngle: -180,
                                        progressStrokeWidth: 10,
                                        backStrokeWidth: 10,
                                        progressColors: AppColors.primaryG,
                                        backColor: Colors.grey.shade100,
                                        valueNotifier: ValueNotifier(60),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ))
                  ],
                ),
                // SizedBox(height: media.width * 0.1),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "Workout Progress",
                //       style: TextStyle(
                //         color: AppColors.blackColor,
                //         fontSize: 16,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //     Container(
                //       height: 35,
                //       padding: EdgeInsets.symmetric(horizontal: 8),
                //       decoration: BoxDecoration(
                //           gradient: LinearGradient(colors: AppColors.primaryG),
                //           borderRadius: BorderRadius.circular(15)),
                //       child: DropdownButtonHideUnderline(
                //         child: DropdownButton(
                //           items: ["Weekly", "Monthly"]
                //               .map((name) => DropdownMenuItem(
                //                   value: name,
                //                   child: Text(
                //                     name,
                //                     style: const TextStyle(
                //                         color: AppColors.blackColor,
                //                         fontSize: 14),
                //                   )))
                //               .toList(),
                //           onChanged: (value) {},
                //           icon: Icon(Icons.expand_more,
                //               color: AppColors.whiteColor),
                //           hint: Text("Weekly",
                //               textAlign: TextAlign.center,
                //               style: const TextStyle(
                //                   color: AppColors.whiteColor, fontSize: 12)),
                //         ),
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: media.width * 0.05),
                // Container(
                //     padding: const EdgeInsets.only(left: 15),
                //     height: media.width * 0.5,
                //     width: double.maxFinite,
                //     child: LineChart(
                //       LineChartData(
                //         showingTooltipIndicators:
                //             showingTooltipOnSpots.map((index) {
                //           return ShowingTooltipIndicators([
                //             LineBarSpot(
                //               tooltipsOnBar,
                //               lineBarsData.indexOf(tooltipsOnBar),
                //               tooltipsOnBar.spots[index],
                //             ),
                //           ]);
                //         }).toList(),
                //         lineTouchData: LineTouchData(
                //           enabled: true,
                //           handleBuiltInTouches: false,
                //           touchCallback: (FlTouchEvent event,
                //               LineTouchResponse? response) {
                //             if (response == null ||
                //                 response.lineBarSpots == null) {
                //               return;
                //             }
                //             if (event is FlTapUpEvent) {
                //               final spotIndex =
                //                   response.lineBarSpots!.first.spotIndex;
                //               showingTooltipOnSpots.clear();
                //               setState(() {
                //                 showingTooltipOnSpots.add(spotIndex);
                //               });
                //             }
                //           },
                //           mouseCursorResolver: (FlTouchEvent event,
                //               LineTouchResponse? response) {
                //             if (response == null ||
                //                 response.lineBarSpots == null) {
                //               return SystemMouseCursors.basic;
                //             }
                //             return SystemMouseCursors.click;
                //           },
                //           getTouchedSpotIndicator: (LineChartBarData barData,
                //               List<int> spotIndexes) {
                //             return spotIndexes.map((index) {
                //               return TouchedSpotIndicatorData(
                //                 FlLine(
                //                   color: Colors.transparent,
                //                 ),
                //                 FlDotData(
                //                   show: true,
                //                   getDotPainter:
                //                       (spot, percent, barData, index) =>
                //                           FlDotCirclePainter(
                //                     radius: 3,
                //                     color: Colors.white,
                //                     strokeWidth: 3,
                //                     strokeColor: AppColors.secondaryColor1,
                //                   ),
                //                 ),
                //               );
                //             }).toList();
                //           },
                //           touchTooltipData: LineTouchTooltipData(
                //             tooltipBgColor: AppColors.secondaryColor1,
                //             tooltipRoundedRadius: 20,
                //             getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                //               return lineBarsSpot.map((lineBarSpot) {
                //                 return LineTooltipItem(
                //                   "${lineBarSpot.x.toInt()} mins ago",
                //                   const TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 10,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 );
                //               }).toList();
                //             },
                //           ),
                //         ),
                //         lineBarsData: lineBarsData1,
                //         minY: -0.5,
                //         maxY: 110,
                //         titlesData: FlTitlesData(
                //             show: true,
                //             leftTitles: AxisTitles(),
                //             topTitles: AxisTitles(),
                //             bottomTitles: AxisTitles(
                //               sideTitles: bottomTitles,
                //             ),
                //             rightTitles: AxisTitles(
                //               sideTitles: rightTitles,
                //             )),
                //         gridData: FlGridData(
                //           show: true,
                //           drawHorizontalLine: true,
                //           horizontalInterval: 25,
                //           drawVerticalLine: false,
                //           getDrawingHorizontalLine: (value) {
                //             return FlLine(
                //               color: AppColors.grayColor.withOpacity(0.15),
                //               strokeWidth: 2,
                //             );
                //           },
                //         ),
                //         borderData: FlBorderData(
                //           show: true,
                //           border: Border.all(
                //             color: Colors.transparent,
                //           ),
                //         ),
                //       ),
                //     )),
                // SizedBox(
                //   height: media.width * 0.05,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       "Latest Workout",
                //       style: TextStyle(
                //           color: AppColors.blackColor,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w700),
                //     ),
                //     TextButton(
                //       onPressed: () {},
                //       child: Text(
                //         "See More",
                //         style: TextStyle(
                //             color: AppColors.grayColor,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w400),
                //       ),
                //     )
                //   ],
                // ),
                // ListView.builder(
                //     padding: EdgeInsets.zero,
                //     physics: const NeverScrollableScrollPhysics(),
                //     shrinkWrap: true,
                //     itemCount: lastWorkoutArr.length,
                //     itemBuilder: (context, index) {
                //       var wObj = lastWorkoutArr[index] as Map? ?? {};
                //       return InkWell(
                //           onTap: () {
                //             Navigator.pushNamed(context, FinishWorkoutScreen.routeName);
                //           },
                //           child: WorkoutRow(wObj: wObj));
                //     }),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    double calculateBMI(double height, double weight) {
      // Perform BMI calculation here
      // Formula: BMI = weight (kg) / (height (m) * height (m))
      return weight / ((height / 100) * (height / 100));
    }

    double bmi = calculateBMI(height, weight);

    return List.generate(
      2,
      (i) {
        Color color0;
        Color color1 = AppColors.whiteColor;

        // Choose colors based on BMI range
        if (bmi < 18.5) {
          color0 = Colors.blue; // Underweight
        } else if (bmi >= 18.5 && bmi < 24.9) {
          color0 = Colors.green; // Normal weight
        } else if (bmi >= 25.0 && bmi < 29.9) {
          color0 = Colors.yellow; // Overweight
        } else {
          color0 = Colors.red; // Obese
        }

        switch (i) {
          case 0:
            return PieChartSectionData(
                color: color0,
                value: bmi,
                title: '',
                radius: 55,
                titlePositionPercentageOffset: 0.55,
                badgeWidget: Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12),
                ));
          case 1:
            return PieChartSectionData(
              color: Colors.lightBlue[100],
              value: 100 - bmi,
              title: '',
              radius: 42,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: const TextStyle(
          color: AppColors.grayColor,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: AppColors.grayColor,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Sun', style: style);
        break;
      case 2:
        text = Text('Mon', style: style);
        break;
      case 3:
        text = Text('Tue', style: style);
        break;
      case 4:
        text = Text('Wed', style: style);
        break;
      case 5:
        text = Text('Thu', style: style);
        break;
      case 6:
        text = Text('Fri', style: style);
        break;
      case 7:
        text = Text('Sat', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
