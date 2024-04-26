class SignUpModel {
  SignUpModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  String email;

  String password;

  String confirmPassword;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword
      };
}
