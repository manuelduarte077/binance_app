import 'dart:async';

import 'package:binance_app/presentation/screens/home/home_screen.dart';
import 'package:binance_app/presentation/screens/sign_in/provider/sign_in_provider.dart';
import 'package:binance_app/presentation/shared/widgets/flutter_rich_text.dart';
import 'package:flutter/material.dart';

import '../../shared/extensions/build_context.dart';
import '../../shared/validators/form_validator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sign_up/sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const String route = '/sign_in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final formKey = GlobalKey<FormState>();

  var email = TextEditingController();
  var password = TextEditingController();

  @override
  void initState() {
    super.initState();

    email.addListener(() {
      ref.read(signInProvider.notifier).setEmail(email.text);
    });

    password.addListener(() {
      ref.read(signInProvider.notifier).setPassword(password.text);
    });
  }

  Future<void> signIn() async {
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
                      'Sign In',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    ///  Email field
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

                    /// Password field
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

                    ///  Button to sign in
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: signIn,
                      child: const Text('Sign In'),
                    ),

                    ///  Button to sign up
                    const SizedBox(height: 56),
                    FlutterRichText(
                      text: 'Don’t have an Account?',
                      secondaryText: 'Sign Up',
                      onTap: () => context.pushNamed(SignUpScreen.route),
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
