import 'package:health_fitness/features/activity_tracker/activity_tracker_screen.dart';
import 'package:health_fitness/features/dashboard/dashboard_screen.dart';
import 'package:health_fitness/features/login/login_screen.dart';
import 'package:health_fitness/features/signup/signup_screen.dart';
import 'package:health_fitness/features/welcome/welcome_screen.dart';
import 'package:flutter/cupertino.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  WelcomeScreen.routeName: (context) => WelcomeScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  ActivityTrackerScreen.routeName: (context) => const ActivityTrackerScreen(),
};
