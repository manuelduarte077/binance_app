import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/dashboard/dashboard_screen.dart';
import 'package:health_fitness/view/login/login_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  static String routeName = "/EditProfileScreen";

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isCheck = false;

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  CollectionReference _users = FirebaseFirestore.instance.collection("users");
  String? _selectedGender;

  DateTime? _selectedDate;
  bool buttonClicked = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userSnapshot = await _users.doc(userId).get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      setState(() {
        _firstnameController.text = userData['firstName'] ?? '';
        _lastnameController.text = userData['lastName'] ?? '';
        _selectedGender = userData['gender'];
        _dateOfBirthController.text = userData['dateOfBirth'] ?? '';
        _weightController.text = userData['weight'] ?? '';
        _heightController.text = userData['height'] ?? '';
        _ageController.text = userData['age'] ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

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
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> updateUserProfile() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await _users.doc(userId).update({
        'firstName': _firstnameController.text,
        'lastName': _lastnameController.text,
        'gender': _selectedGender,
        'dateOfBirth': _dateOfBirthController.text,
        'weight': _weightController.text,
        'height': _heightController.text,
        'age': _ageController.text,
      });

      // Optional: Show a success message or navigate to another screen
      // based on your app's flow.
    } catch (error) {
      // Handle errors (e.g., show an error message)
      print('Error updating user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(),
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
                  Text(
                    "Update Your Profile",
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
                                "assets/icons/gender_icon.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: AppColors.grayColor,
                              ),
                            ),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  hint: Text("Choose Gender",
                                      style: const TextStyle(
                                          color: AppColors.grayColor,
                                          fontSize: 12)),
                                  value: _selectedGender,
                                  isDense: true,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue;
                                    });
                                  },
                                  items: ["Male", "Female"].map((String value) {
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
                            SizedBox(width: 8),
                          ],
                        ),
                        if (buttonClicked &&
                            (_selectedGender == null ||
                                _selectedGender!.isEmpty))
                          Column(
                            children: [
                              Divider(
                                color: Color(0xFFB01B13),
                                height: 3,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 15, top: 4),
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

                  SizedBox(height: 15),
                  // Date of Birth
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: RoundTextField(
                        textEditingController: _dateOfBirthController,
                        hintText: "Date of Birth",
                        icon: "assets/icons/calendar_icon.png",
                        textInputType: TextInputType.text,
                        // onChanged: (value) {
                        //   _formKey.currentState!.validate();
                        // },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),

                  SizedBox(height: 15),
                  RoundTextField(
                    textEditingController: _weightController,
                    hintText: "Your Weight",
                    icon: "assets/icons/weight_icon.png",
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
                  SizedBox(height: 15),
                  RoundTextField(
                    textEditingController: _heightController,
                    hintText: "Your Height",
                    icon: "assets/icons/swap_icon.png",
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
                  SizedBox(height: 15),

                  RoundTextField(
                    textEditingController: _ageController,
                    hintText: "Your Age",
                    icon: "assets/icons/profile_icon.png",
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
                  SizedBox(
                    height: media.height * 0.05,
                  ),
                  RoundGradientButton(
                    title: "Update Profile",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        updateUserProfile();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(
                    height: media.height * 0.015,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
