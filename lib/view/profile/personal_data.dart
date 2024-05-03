import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_fitness/utils/app_colors.dart';
import 'package:health_fitness/view/profile/change_password.dart';
import 'package:health_fitness/view/profile/edit_profile.dart';

class PersonalDataScreen extends StatefulWidget {
  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  late String uid;
  String email = '';
  String firstName = '';
  String lastName = '';
  String dateOfBirth = '';
  String gender = '';
  double weight = 0;
  double height = 0;
  int age = 0;

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
            firstName = userSnapshot['firstName'] ?? '';
            lastName = userSnapshot['lastName'] ?? '';
            email = userSnapshot['email'] ?? '';
            gender = userSnapshot['gender'] ?? '';
            dateOfBirth = userSnapshot['dateOfBirth'] ?? '';
            weight = double.parse(userSnapshot['weight']);
            height = double.parse(userSnapshot['height']);
            age = int.parse(userSnapshot['age']);
          });
        }

        return; // Operation succeeded
      } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    "assets/images/user.png",
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/profile_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      firstName,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/profile_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      lastName,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/message_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/gender_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      gender,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/calendar_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      dateOfBirth,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/weight_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      weight.toString(),
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/swap_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      height.toString(),
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/icons/profile_icon.png",
                        height: 18, width: 18, fit: BoxFit.contain),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      age.toString(),
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen()),
                  );
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: AppColors.secondaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2))
                      ]),
                  child: Center(
                      child: Text("Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ))),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()),
                  );
                },
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: AppColors.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2))
                      ]),
                  child: Center(
                      child: Text("Edit Personal Data",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.whiteColor,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w400,
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
