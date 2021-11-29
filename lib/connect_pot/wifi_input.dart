import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'package:shared_preferences/shared_preferences.dart';

class WifiInput extends StatefulWidget {
  const WifiInput({
    Key? key,
    this.onPress,
  }) : super(key: key);

  final VoidCallback? onPress;

  @override
  WifiInputState createState() => WifiInputState();
}

class WifiInputState extends State<WifiInput> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();
  final _ssidController = TextEditingController();
  final _passController = TextEditingController();

  late bool _passwordVisible;
  late bool _saveWifiInfo;

  String wifi = "";
  String pass = "";

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _saveWifiInfo = true;
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    final SharedPreferences prefs = await _prefs;
    _saveWifiInfo = prefs.getBool("saveWifiPermission") ?? true;
    wifi = prefs.getString("wifiSsid") ?? "";
    pass = prefs.getString("wifiPass") ?? "";

    if (wifi != "") {
      _ssidController.text = wifi;
    } else {
      _initNetworkInfo();
    }

    if (pass != "") {
      _passController.text = pass;
    }
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
      print(_connectionStatus);
      if (wifiName != null) {
        //wifi = wifiName;
        _ssidController.text = wifiName;
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
                            validator: (value) =>
                                value != null && value.length < 3
                                    ? 'Wifi SSID needs at least 3 characters.'
                                    : null,
                            controller: _ssidController,
                          ))),
                ]),
                Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextFormField(
                            obscureText: !_passwordVisible,
                            controller: _passController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            onSaved: (value) => pass = value!,
                            validator: (value) => value != null &&
                                    value.length < 3
                                ? 'Wifi Password needs at least 3 characters.'
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
                          color: Color(0xffccd5ae)),
                      height: 50.0,
                      child: const Center(
                        child: Text('Submit',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat')),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: CheckboxListTile(
                    title: const Text(
                        "Allow JujuPot save WIFI information for future pots.",
                        style: TextStyle(color: Colors.grey)),
                    value: _saveWifiInfo,
                    onChanged: (newValue) async {
                      print("agree to save? $newValue");
                      setState(() {
                        _saveWifiInfo = newValue ?? true;
                      });

                      final SharedPreferences prefs = await _prefs;
                      prefs.setBool("saveWifiPermission", _saveWifiInfo);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    tileColor: Colors.grey[200],
                    checkColor: Colors.grey[100],
                  ),
                ),
              ],
            )));
  }

  void submit() async {
    final form = formKey.currentState!;

    if (form.validate()) {
      form.save();

      final SharedPreferences prefs = await _prefs;
      if (_saveWifiInfo) {
        prefs.setString("wifiSsid", wifi);
        prefs.setString("wifiPass", pass);
      } else {
        prefs.setString("wifiSsid", "");
        prefs.setString("wifiPass", "");
      }

      widget.onPress!();
    }
  }
}
