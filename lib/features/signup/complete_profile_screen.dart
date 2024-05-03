import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/features/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String routeName = '/CompleteProfileScreen';

  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const CompleteProfileScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  late String firstName;
  late String lastName;
  late String email;
  late String password;

  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;

  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  bool buttonClicked = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _signUp() async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Get the user UID
      String uid = userCredential.user!.uid;
      // Create user document in Firestore
      await _users.doc(uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'gender': _selectedGender, // Add the selected gender
        'dateOfBirth': _dateOfBirthController.text,
        'weight': _weightController.text,
        'height': _heightController.text,
        'age': _ageController.text,
        'stepsTarget': '4000',
        'waterTarget': '2000',
        'sleeptime': '12:00 AM',
        'waketime': '8:00 AM',

        // Add other fields as needed
      });

      Future<User?> signIn(String email, String password) async {
        try {
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          User? user = userCredential.user;
          return user;
        } catch (e) {
          print('Error signing in: $e');
          return null;
        }
      }

      signIn(email, password);

      // Navigate to the home page or do any other post-signup logic
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      // Handle signup errors
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    email = widget.email;
    password = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/complete_profile.png',
                      width: media.width),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Let’s complete your profile',
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'It will help us to know more about you!',
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Gender Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightGrayColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                'assets/icons/gender_icon.png',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: AppColors.grayColor,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: const Text('Choose Gender',
                                      style: TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 12)),
                                  value: _selectedGender,
                                  isDense: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                  items: ['Male', 'Female'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        if (buttonClicked &&
                            (_selectedGender == null ||
                                _selectedGender!.isEmpty))
                          const Column(
                            children: [
                              Divider(
                                color: Color(0xFFB01B13),
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15, top: 4),
                                  child: Text(
                                    'Please choose a gender',
                                    style: TextStyle(
                                      color: Color(0xFFB01B13),
                                      fontSize: 12.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  // Date of Birth
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: RoundTextField(
                        textEditingController: _dateOfBirthController,
                        hintText: 'Date of Birth',
                        icon: 'assets/icons/calendar_icon.png',
                        textInputType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  const SizedBox(height: 15),
                  RoundTextField(
                    textEditingController: _weightController,
                    hintText: 'Your Weight',
                    icon: 'assets/icons/weight_icon.png',
                    textInputType: TextInputType.text,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  RoundTextField(
                    textEditingController: _heightController,
                    hintText: 'Your Height',
                    icon: 'assets/icons/swap_icon.png',
                    textInputType: TextInputType.text,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  RoundTextField(
                    textEditingController: _ageController,
                    hintText: 'Your Age',
                    icon: 'assets/icons/profile_icon.png',
                    textInputType: TextInputType.text,
                    // onChanged: (value) {
                    //   _formKey.currentState!.validate();
                    // },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  RoundGradientButton(
                    title: 'Register',
                    onPressed: () {
                      setState(() {
                        buttonClicked = true;
                      });
                      if (_formKey.currentState!.validate()) {
                        _signUp();
                        Navigator.pushNamed(context, WelcomeScreen.routeName);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
