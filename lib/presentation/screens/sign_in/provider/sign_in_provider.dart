import 'package:binance_app/data/models/sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInProvider = StateNotifierProvider<SignInNotifier, SignInModel>(
    (ref) => SignInNotifier());

class SignInNotifier extends StateNotifier<SignInModel> {
  SignInNotifier() : super(SignInModel(email: '', password: ''));

  void setEmail(String email) {
    state = SignInModel(email: email, password: state.password);
  }

  void setPassword(String password) {
    state = SignInModel(email: state.email, password: password);
  }
}
