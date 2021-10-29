import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiInput extends StatefulWidget {
  const WifiInput({
    Key? key,
  }) : super(key: key);

  @override
  WifiInputState createState() => WifiInputState();
}

class WifiInputState extends State<WifiInput> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String wifi = "";
  String pass = "";

  bool shouldSendToFW = false;

  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    String? wifiName;

    try {
      if (!kIsWeb && Platform.isIOS) {
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      print(e.toString());
      wifiName = 'Failed to get Wifi Name';
    }

    setState(() {
      _connectionStatus = 'Wifi Name: $wifiName';
      if (wifiName != null) {
        wifi = wifiName;
      } else
        print("wifi name was null");
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(width: 200, height: 200),
        child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(
                              top: 40, right: 10, left: 10, bottom: 5),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Wifi',
                            ),
                            onSaved: (value) => wifi = value!,
                            validator: (value) => value != null &&
                                    value.length < 3
                                ? 'Wifi Passwords needs at least 3 characters.'
                                : null,
                          ))),
                ]),
                Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                            ),
                            onSaved: (value) => pass = value!,
                            validator: (value) =>
                                value != null && value.length < 3
                                    ? 'Wifi SSID needs at least 3 characters.'
                                    : null,
                          ))),
                ]),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextButton(
                    onPressed: () => submit(),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                          color: Color(0xfffec5bb)),
                      height: 50.0,
                      child: const Center(
                        child: Text('Submit',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat')),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }

  void submit() {
    final form = formKey.currentState!;

    if (form.validate()) {
      form.save();
      setState(() => shouldSendToFW = true);
    }
  }
}
