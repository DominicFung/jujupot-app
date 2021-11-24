class TypeLogo {
  static String facebook = 'assets/login/facebook.png';
  static String google = 'assets/login/google.png';
  static String apple = 'assets/login/apple.png';
  static String userPassword = 'assets/login/user_password.png';
}

class TypeLoginModel {
  Function callFunction;
  String logo;

  TypeLoginModel({required this.logo, required this.callFunction});
}
