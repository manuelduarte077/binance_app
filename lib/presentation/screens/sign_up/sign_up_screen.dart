import 'package:binance_app/presentation/screens/sign_up/provider/sign_up_provier.dart';
import 'package:binance_app/presentation/shared/widgets/flutter_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/extensions/build_context.dart';
import '../../shared/validators/form_validator.dart';
import '../home/home_screen.dart';
import '../sign_in/sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  static const String route = '/sign_up';

  @override
  ConsumerState<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends ConsumerState<SignUpScreen> {
  late final formKey = GlobalKey<FormState>();

  var userName = TextEditingController();
  var email = TextEditingController();
  var password = TextEditingController();
  final confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();

    email.addListener(() {
      ref.read(signUpProvider.notifier).setEmail(email.text);
    });

    password.addListener(() {
      ref.read(signUpProvider.notifier).setPassword(password.text);
    });

    confirmPassword.addListener(() {
      ref
          .read(signUpProvider.notifier)
          .setConfirmPassword(confirmPassword.text);
    });
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    return context.pushNamedAndRemoveUntil<void>(HomeScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    /// Email field
                    const SizedBox(height: 28),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      validator: FormValidator.email,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Your email here',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      controller: email,
                    ),

                    ///  Password field
                    const SizedBox(height: 28),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      validator: FormValidator.password,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Your password here',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      controller: password,
                    ),

                    ///  Confirm password field
                    const SizedBox(height: 28),
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => FormValidator.confirmPassword(
                        value,
                        password.text,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: const InputDecoration(
                        hintText: 'Confirm password here',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      controller: confirmPassword,
                    ),

                    ///  Button to sign up
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: signUp,
                      child: const Text('Sign Up'),
                    ),

                    ///  Button to sign in
                    const SizedBox(height: 56),
                    FlutterRichText(
                      text: 'Already have an Account?',
                      secondaryText: 'Sign In',
                      onTap: () => context.pushNamed(SignInScreen.route),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
