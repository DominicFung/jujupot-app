import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';

import 'package:jujupot_app_v1/details_page.dart';
import 'package:jujupot_app_v1/connect_pot/connect_pot_dialog.dart';
import 'package:jujupot_app_v1/login/login.dart';
import 'package:jujupot_app_v1/login/service/type_login.dart';

import 'package:jujupot_app_v1/model/user.dart';

//import 'package:jujupot_app_v1/amplifyconfiguration.dart';
import 'package:jujupot_app_v1/hommieoconfiguration.dart';

import 'model/pot.dart';

void main() {
  runApp(const JujuApp());
}

class JujuApp extends StatelessWidget {
  const JujuApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juju Pot',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const HomePage(title: 'Juju-Pot'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const primaryCol = Color(0xffccd5ae);

  List<Pot> pots = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _operationsOrder();
  }

  void _operationsOrder() async {
    await _configureAmplify();
    await listUserDevices(user!.userId, user!.getAccessKey());
  }

  Future<void> _configureAmplify() async {
    // Add the following line to add API plugin to your app.
    // Auth plugin needed for IAM authorization mode, which is default for REST API.
    try {
      Amplify.addPlugins([AmplifyAPI()]);
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print(
          "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }

    user = await User().init();
    if (user!.error.isNotEmpty) {
      if (user!.error.contains("Invalid access key")) {
        _showUserAccessKeyRevokeError();
      } else {
        print("This is some other error we don't know about.");
      }
    } else {
      print("User is logged in. User: ${user!.userId}");
      setState(() {
        user = user;
      });
    }
  }

  Future<void> _showUserAccessKeyRevokeError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Disabled.'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text('We believe your account has been hacked.'),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                      'Click "Learn More" to learn more about how to recover your account/contact us for assistance.'),
                ),
                Text(
                    'Click "Reset" to reset your app. WARNING! This will delete all your data.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Learn More'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset'),
              onPressed: () {
                user!.createGuestUser();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> listUserDevices(String userId, String accessToken) async {
    print(" $userId, $accessToken");
    RestOptions options = RestOptions(
        path: '/user/guest/device/list',
        headers: {
          'hommieo-user-id': userId,
          'hommieo-access-token': accessToken
        });

    RestResponse response;
    try {
      RestOperation restOperation = Amplify.API.get(restOptions: options);
      response = await restOperation.response;
    } on RestException catch (e) {
      print(e.toString());
      return;
    }

    pots = []; // reset the list
    List<dynamic> rawdata = json.decode(response.body) as List<dynamic>;
    print(rawdata);
    for (Map<String, dynamic> rawpot in rawdata) {
      Pot pot = Pot.fromJson(rawpot);
      pots.add(pot);
    }

    setState(() {
      pots = pots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryCol,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                SizedBox(
                    width: 125.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        user != null
                            ? ConnectPotDialog(
                                user: user!,
                                updateUserDevices: () async {
                                  await listUserDevices(
                                      user!.userId, user!.getAccessKey());
                                },
                              )
                            : IconButton(
                                onPressed: () {
                                  return;
                                },
                                color: Colors.white,
                                icon: const Icon(Icons.add_rounded)),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Login(
                                      pathLogo: 'assets/pot-logo.png',
                                      typeLoginModel: [
                                        TypeLoginModel(
                                            logo: TypeLogo.facebook,
                                            callFunction: () => {}),
                                      ],
                                    )));
                          },
                          color: Colors.white,
                          icon: const Icon(Icons.login_rounded),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          const SizedBox(height: 25.0),
          Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Row(
                children: const <Widget>[
                  Text('My Juju Pots',
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 25.0)),
                  SizedBox(width: 10),
                ],
              )),
          const SizedBox(height: 40.0),
          Container(
              height: MediaQuery.of(context).size.height - 185.0,
              //width: 300,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
              ),
              child: ListView(
                primary: false,
                // shrinkWrap: true,
                // physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: 25.0, right: 20.0),
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(top: 45),
                      child: SizedBox(
                        height: 600,
                        child: ListView(
                            children: List.generate(pots.length, (i) {
                          int num = (i % 4) + 1;
                          return _buildJujuPot(
                              "assets/pot$num.png",
                              pots[i].title,
                              "aloe vera",
                              '',
                              41,
                              pots[i].potId);
                        })
                            // children: [
                            //   _buildJujuPot('assets/pot1.png', 'Burro\'s Tail',
                            //       'Sedum Morganianum', '', 12),
                            //   _buildJujuPot('assets/pot2.png', 'Crown of Thorns',
                            //       '', '', 100),
                            //   _buildJujuPot('assets/pot3.png',
                            //       'Flaming Katy (kal...', '', '', 20),
                            //   _buildJujuPot('assets/pot4.png',
                            //       'Aloe Vera (aloe vera)', '', '', 53),
                            // ],
                            ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 65.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                      Container(
                        height: 65,
                        width: 60,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                            child: Icon(Icons.shopping_basket,
                                color: Colors.black)),
                      ),
                      Container(
                        height: 65.0,
                        width: 120.0,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                            color: const Color(0xFF1C1428)),
                        child: const Center(
                            child: Text('Checkout',
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontSize: 15.0))),
                      )
                    ],
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildJujuPot(String imgPath, String name, String species,
      String design, double health, String deviceId) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailsPage(
                      heroTag: imgPath,
                      potName: name,
                      potDesign: design,
                      potSpecies: species,
                      deviceId: deviceId,
                      user: user ?? NoneUser())));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Hero(
                    tag: imgPath,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image(
                            semanticLabel: imgPath,
                            image: AssetImage(imgPath),
                            fit: BoxFit.contain,
                            height: 75.0,
                            width: 75.0))),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        Text(deviceId,
                            style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                color: Colors.grey))
                      ]),
                ),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                        decoration: const BoxDecoration(
                            color: Color(0xfffaedcd), shape: BoxShape.circle),
                        child: Center(
                            child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.eco_rounded,
                                      color: primaryCol, size: 30)),
                              Text(health.toString() + "%",
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffd4a373))),
                            ])))),
                IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DetailsPage(
                              heroTag: imgPath,
                              potName: name,
                              potDesign: design,
                              potSpecies: species,
                              deviceId: deviceId,
                              user: user ?? NoneUser())));
                    })
              ],
            )));
  }
}
