import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_fitness/common_widgets/round_textfield.dart';
import 'package:health_fitness/utils/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void changePassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmNewPassword = confirmNewPasswordController.text;

    // Validation
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        // Use the user's current email and password for reauthentication
        AuthCredential credential = EmailAuthProvider.credential(
          email: user?.email ?? "",
          password: currentPassword,
        );

        // Reauthenticate
        await user?.reauthenticateWithCredential(credential);

        // Change password
        await user?.updatePassword(newPassword);

        showSuccessMessage("Password changed successfully!");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          showErrorMessage("Incorrect current password. Please try again.");
        } else {
          showErrorMessage("Error changing password: $e");
        }
      } catch (error) {
        showErrorMessage("Error changing password: $error");
      }
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RoundTextField(
                textEditingController: currentPasswordController,
                isObscureText: true,
                hintText: "Current Password",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your current password.';
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
              SizedBox(height: 16),
              RoundTextField(
                textEditingController: newPasswordController,
                isObscureText: true,
                hintText: "New Password",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your new password.';
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
              SizedBox(height: 16),
              RoundTextField(
                textEditingController: confirmNewPasswordController,
                isObscureText: true,
                hintText: "Confirm New Password",
                icon: "assets/icons/lock_icon.png",
                textInputType: TextInputType.text,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match.';
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
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  changePassword();
                },
                child: Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
