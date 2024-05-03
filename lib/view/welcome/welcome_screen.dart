import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';

class WelcomeScreen extends StatefulWidget {
  static String routeName = "/WelcomeScreen";

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  late String uid;
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is first created
    fetchUserData();
  }

  Future<void> fetchUserData() async {
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
        firstName = userSnapshot['firstName'] ?? '';
        lastName = userSnapshot['lastName'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset("assets/images/welcome_promo.png",
                  width: media.width * 0.75, fit: BoxFit.fitWidth),
              SizedBox(height: media.width * 0.05),
              Text(
                "Welcome, $firstName $lastName",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: media.width * 0.01),
              const Text(
                "You are all set now, let’s reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: media.width * 0.2),
              RoundGradientButton(
                title: "Go To Home",
                onPressed: () {
                  Navigator.pushNamed(context, DashboardScreen.routeName);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
