class SignUpModel {
  String email;
  String password;
  String repeatPassword;

  String name;
  String surname;

  SignUpModel(
      {required this.email,
      required this.password,
      required this.repeatPassword,
      required this.name,
      required this.surname});
}
