import 'package:binance_app/data/models/sign_up.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpModel>(
  (ref) => SignUpNotifier(),
);

class SignUpNotifier extends StateNotifier<SignUpModel> {
  SignUpNotifier()
      : super(SignUpModel(
          email: '',
          password: '',
          confirmPassword: '',
        ));

  void setEmail(String email) {
    state = SignUpModel(
      email: email,
      password: state.password,
      confirmPassword: state.confirmPassword,
    );
  }

  void setPassword(String password) {
    state = SignUpModel(
      email: state.email,
      password: password,
      confirmPassword: state.confirmPassword,
    );
  }

  void setConfirmPassword(String confirmPassword) {
    state = SignUpModel(
      email: state.email,
      password: state.password,
      confirmPassword: confirmPassword,
    );
  }
}
