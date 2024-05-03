import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/login/login_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import 'complete_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = "/SignupScreen";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isCheck = false;

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  CollectionReference _users = FirebaseFirestore.instance.collection("users");

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: media.height * 0.06,
                  ),
                  Text(
                    "Hey there,",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: media.height * 0.01,
                  ),
                  Text(
                    "Create an Account",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  RoundTextField(
                    textEditingController: _firstnameController,
                    hintText: "First Name",
                    icon: "assets/icons/profile_icon.png",
                    textInputType: TextInputType.name,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  RoundTextField(
                    textEditingController: _lastnameController,
                    hintText: "Last Name",
                    icon: "assets/icons/profile_icon.png",
                    textInputType: TextInputType.name,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  RoundTextField(
                    textEditingController: _emailController,
                    hintText: "Email",
                    icon: "assets/icons/message_icon.png",
                    textInputType: TextInputType.emailAddress,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  RoundTextField(
                    textEditingController: _passwordController,
                    hintText: "Password",
                    icon: "assets/icons/lock_icon.png",
                    textInputType: TextInputType.text,
                    isObscureText: true,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    rightIcon: TextButton(
                        onPressed: () {},
                        child: Container(
                            alignment: Alignment.center,
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              "assets/icons/hide_pwd_icon.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: AppColors.grayColor,
                            ))),
                  ),
                  SizedBox(
                    height: media.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              isCheck = !isCheck;
                            });
                          },
                          icon: Icon(
                            isCheck
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank_outlined,
                            color: AppColors.grayColor,
                          )),
                      Expanded(
                        child: Text(
                            "By continuing you accept our Privacy Policy and\nTerm of Use",
                            style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 10,
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.height * 0.05,
                  ),
                  RoundGradientButton(
                    title: "Next >",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isCheck) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompleteProfileScreen(
                                  firstName: _firstnameController.text,
                                  lastName: _lastnameController.text,
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              ));
                          // Navigator.pushNamed(
                          //   context,
                          //   CompleteProfileScreen.routeName,
                          //   arguments: CompleteProfileScreen(
                          //     firstName: _firstnameController.text,
                          //     lastName: _lastnameController.text,
                          //     email: _emailController.text,
                          //     password: _passwordController.text,
                          //   ),
                          // );
                        }
                      }
                    },
                  ),
                  SizedBox(
                    height: media.height * 0.015,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                      Text("  Or  ",
                          style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400)),
                      Expanded(
                          child: Container(
                        width: double.maxFinite,
                        height: 1,
                        color: AppColors.grayColor.withOpacity(0.5),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: media.height * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "assets/icons/google_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryColor1.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            "assets/icons/facebook_icon.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: media.height * 0.025,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                            children: [
                              const TextSpan(
                                text: "Already have an account? ",
                              ),
                              TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                      color: AppColors.secondaryColor1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                            ]),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
