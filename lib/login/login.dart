import 'package:flutter/material.dart';

import 'package:jujupot_app_v1/login/service/type_login.dart';

class Login extends StatefulWidget {
  var backgroundColor = const Color(0xFFE7004C);
  var cardColor = const Color(0xFFF3F3F5);
  var textColor = const Color(0xFF0F2E48);

  /// url logo main in login
  final String pathLogo;

  /// button when you want to avoid the login and go to the application content\
  /// function when you want to avoid the login and go to the application content
  bool isExploreApp = false;
  Function? functionExploreApp;

  /// widget to put a footer in your login
  /// custom widget footer
  bool isFooter = false;
  Widget? widgetFooter;

  /// list type login import in login
  List<TypeLoginModel> typeLoginModel;

  /// is signUp in login
  bool isSignUp = false;
  Widget? widgetSignUp;

  //model of key words used in login
  Words keyWord = Words();

  Login(
      {Key? key,
      Color? backgroundColor,
      Color? cardColor,
      Color? textColor,
      required this.pathLogo,
      required this.typeLoginModel,
      bool? isExploreApp,
      Function? functionExploreApp,
      bool? isSignUp,
      Widget? widgetSignUp,
      bool? isFooter,
      Widget? widgetFooter,
      Words? keyWord})
      : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    widget.keyWord = widget.keyWord;

    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width * 0.60,
              child: Center(
                child: Image.asset(
                  widget.pathLogo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: Color(0xFFF3F3F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(),
                  Column(
                    children: [
                      buildLoginWith(),
                      buildTypeLogin(context),
                      (widget.isExploreApp == null ||
                              widget.isExploreApp == false)
                          ? const SizedBox()
                          : const SizedBox(
                              height: 20,
                            ),
                      buildExploreApp(context),
                      (widget.isSignUp == null || widget.isSignUp == false)
                          ? const SizedBox()
                          : buildSignUp(),
                    ],
                  ),
                  // (widget.widgetFooter == null || widget.isFooter) ? const SizedBox() : widget.widgetFooter
                ],
              ),
            ))
      ],
    );
  }

  GestureDetector buildSignUp() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
                text: widget.keyWord.notAccount + '\n',
                style: TextStyle(
                    color: widget.textColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 15)),
            TextSpan(
                text: widget.keyWord.signUp,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: widget.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ]),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_buildContext) =>
                widget.widgetSignUp ?? const SizedBox()));
      },
    );
  }

  Widget buildExploreApp(BuildContext context) {
    return (widget.isExploreApp == null || widget.isExploreApp == false)
        ? SizedBox()
        : GestureDetector(
            //onTap: widget.functionExploreApp,
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                width: (widget.typeLoginModel.length > 3)
                    ? MediaQuery.of(context).size.width * 0.90
                    : MediaQuery.of(context).size.width * 0.80,
                child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                          child: Text(
                        widget.keyWord.exploreApp,
                        style: TextStyle(
                            color: widget.textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      )),
                    ))),
          );
  }

  SizedBox buildTypeLogin(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: (widget.typeLoginModel.length > 3)
          ? MediaQuery.of(context).size.width * 0.90
          : MediaQuery.of(context).size.width * 0.80,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: this.getCardLogin()),
        ),
      ),
    );
  }

  Padding buildLoginWith() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(widget.keyWord.loginWith,
          style: TextStyle(
              color: widget.textColor ?? Color(0xFF0F2E48),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> getCardLogin() {
    List<Widget> list = [];

    for (TypeLoginModel tlm in widget.typeLoginModel) {
      list.add(GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: ExactAssetImage(
              tlm.logo,
              package: (tlm.logo.contains('assets/images_login_fresh_34_/'))
                  ? 'login_fresh'
                  : null,
            ),
          ),
        ),
        onTap: () {
          tlm.callFunction(context);
        },
      ));
    }

    return list;
  }
}

class Words {
  String loginWith;
  String login;
  String exploreApp;
  String notAccount;
  String signUp;
  String textLoading;
  String hintLoginUser;
  String hintLoginPassword;
  String hintSignUpRepeatPassword;
  String hintName;
  String hintSurname;

  String recoverPassword;

  String messageRecoverPassword;

  Words(
      {this.loginWith = 'Login With',
      this.hintName = 'Name',
      this.hintSurname = 'Surname',
      this.hintSignUpRepeatPassword = 'Repeat Password',
      this.hintLoginPassword = 'Password',
      this.recoverPassword = 'Recover Password',
      this.messageRecoverPassword =
          'To recover the password, enter the email and press send email, you will receive an email so you can update your password. Only available for accounts created by username and password',
      this.hintLoginUser = 'Username or email',
      this.login = 'Login',
      this.exploreApp = 'Explore App',
      this.notAccount = 'You dot not have an account?',
      this.signUp = 'Sign Up',
      this.textLoading = 'please wait ...'});
}
