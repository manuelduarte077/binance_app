import 'package:health_fitness/view/activity_tracker/activity_tracker_screen.dart';
import 'package:health_fitness/view/dashboard/dashboard_screen.dart';
import 'package:health_fitness/view/login/login_screen.dart';
import 'package:health_fitness/view/signup/complete_profile_screen.dart';
import 'package:health_fitness/view/signup/signup_screen.dart';
import 'package:health_fitness/view/welcome/welcome_screen.dart';
import 'package:flutter/cupertino.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  WelcomeScreen.routeName: (context) =>  WelcomeScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  ActivityTrackerScreen.routeName: (context) => const ActivityTrackerScreen(),
};
