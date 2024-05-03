import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String userKey = 'user_key';

  static Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(userKey);
    return userId != null ? FirebaseAuth.instance.currentUser : null;
  }

  static Future<void> setUser(User? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user != null) {
      prefs.setString(userKey, user.uid);
    } else {
      prefs.remove(userKey);
    }
  }
}
