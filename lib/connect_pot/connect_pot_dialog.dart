import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:jujupot_app_v1/connect_pot/bluetooth_disabled_screen.dart';
import 'package:jujupot_app_v1/connect_pot/test_pot_connected.dart';
import 'package:jujupot_app_v1/connect_pot/wifi_input.dart';
import 'package:jujupot_app_v1/model/user.dart';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';

class ConnectPotDialog extends StatefulWidget {
  const ConnectPotDialog({Key? key, required this.user, this.updateUserDevices})
      : super(key: key);

  final Function? updateUserDevices;
  final User user;

  @override
  _ConnectPotDialogState createState() => _ConnectPotDialogState();
}

class _ConnectPotDialogState extends State<ConnectPotDialog> {
  final GlobalKey<WifiInputState> wifiFormKey = GlobalKey<WifiInputState>();
  final GlobalKey<TestPotConnectedState> testPotKey =
      GlobalKey<TestPotConnectedState>();

  final _controller = PageController();
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  static const _scanLengthSeconds = 60;
  static const _jujuBluetoothPrefix = "JuJuPot-";
  static const _wifiPrefix = "wifi:: ";
  static const _passPrefix = "pass:: ";
  static const _userPrefix = "user:: ";

  final _serviceUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final _characteristicWriteUuid = Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  Stream<List<ScanResult>> btsr = FlutterBlue.instance.scanResults;
  StreamSubscription<List<ScanResult>>? btsrl;

  BluetoothDevice? btdevice;
  BluetoothDeviceState btdevicestate = BluetoothDeviceState.disconnected;

  late List<Widget> _pages;
  String deviceId = "";

  // STATES
  bool _passCommission = false;

  Future<String> attachUserDevice(String deviceId) async {
    String body = json.encode({
      "deviceId": deviceId,
    });

    RestOptions options = RestOptions(
        path: '/user/guest/attach-device',
        headers: {
          'hommieo-user-id': widget.user.userId,
          'hommieo-access-token': widget.user.getAccessKey()
        },
        body: Uint8List.fromList(body.codeUnits));

    RestResponse response;
    try {
      RestOperation restOperation = Amplify.API.post(restOptions: options);
      response = await restOperation.response;
    } on RestException catch (e) {
      return e.toString();
    }

    return response.body;
  }

  @override
  void initState() {
    _pages = <Widget>[
      ConstrainedBox(
          constraints: const BoxConstraints.expand(width: 200, height: 200),
          child: Column(
            children: [
              const Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Placeholder(),
                      ))),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                child: StreamBuilder<bool>(
                    stream: FlutterBlue.instance.isScanning,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data!) {
                        return const LinearProgressIndicator();
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
              ),
              const Text(
                "Long press the button on the pot to activate the device!",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
              ),
            ],
          )),
      WifiInput(
        key: wifiFormKey,
        onPress: () async {
          if (btdevice != null &&
              btdevicestate == BluetoothDeviceState.connected) {
            BluetoothCharacteristic? btw = await _getCharacteristic(btdevice);

            String wifi = _wifiPrefix + wifiFormKey.currentState!.wifi;
            String pass = _passPrefix + wifiFormKey.currentState!.pass;
            String user = _userPrefix + widget.user.userId;

            btw!.setNotifyValue(true);

            List<int> rawChars = await btw.read();
            print('raw chars from ESP32: $rawChars');

            deviceId = String.fromCharCodes(rawChars);
            print('Juju Pot ID: $deviceId');

            // WRITE TO BLUETOOTH
            btw.write(wifi.codeUnits);
            btw.write(pass.codeUnits);
            btw.write(user.codeUnits);

            print("Complete wifi/password transfer.");

            deviceId = deviceId.replaceAll("product::", "").replaceAll(" ", "");
            String res = await attachUserDevice(deviceId);

            print("Attach device response: $res");

            setState(() {
              _passCommission = true;
            });
          }
        },
      ),
      TestPotConnected(
          key: testPotKey,
          cloudConnectComplete: () async {
            print("product to be added to the list: $deviceId");
            widget.updateUserDevices!();
            setState(() {
              _passCommission = false;
            });
            Navigator.of(context).pop();
          })
    ];

    super.initState();
  }

  Future<BluetoothCharacteristic?> _getCharacteristic(btdevice) async {
    List<BluetoothService> services = await btdevice!.discoverServices();

    for (BluetoothService s in services) {
      if (s.uuid == _serviceUuid) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid == _characteristicWriteUuid) {
            print('Write Characteristic found: ${c.uuid}');
            return c;
          }
        }
      }
    }

    print("Error: our Service/Characteristic is not found");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showConnectPotDialog(context, FlutterBlue.instance);
          startBtConnectionListener();
          FlutterBlue.instance
              .startScan(timeout: const Duration(seconds: _scanLengthSeconds));
        },
        color: Colors.white,
        icon: const Icon(Icons.add_rounded));
  }

  void startBtConnectionListener() {
    btsrl ??= btsr.listen((event) async {
      if (event.isNotEmpty) {
        for (ScanResult d in event) {
          if (d.device.name.contains(_jujuBluetoothPrefix)) {
            d.device.connect();
            btdevice = d.device;
            startConnectedDeviceListener();
          }
        }
      }
    });
  }

  void stopBtConnectionListener() {
    btsrl?.cancel();
    btsrl = null;
  }

  void startConnectedDeviceListener() {
    if (btdevice != null) {
      btdevice!.state.listen((event) async {
        btdevicestate = event;
        if (_passCommission) {
          _controller.animateToPage(2, duration: _kDuration, curve: _kCurve);
        } else if (event == BluetoothDeviceState.connected &&
            _controller.page != 1) {
          print("Moving Jujupot to page 1");
          _controller.animateToPage(1, duration: _kDuration, curve: _kCurve);
        } else if (event == BluetoothDeviceState.disconnected &&
            _controller.page != 0) {
          print("Device disconnected, so moving Jujupot back to page 0");
          FocusScope.of(context).requestFocus(FocusNode());
          _controller.animateToPage(0, duration: _kDuration, curve: _kCurve);
        }
      });
    } else {
      print("Cannot start ConnectedDeviceListener -- btdevice = null");
    }
  }

  void destroyDevice() {
    if (btdevice != null) {
      btdevice!.disconnect();
      btdevice = null;
    } else {
      print("Cannot destroyDevice -- btdevice = null");
    }
  }

  void showConnectPotDialog(BuildContext context, FlutterBlue bt) => showDialog(
      context: context,
      barrierDismissible:
          false, // We cannot set dismissable half way (Nov 28 2021)
      builder: (BuildContext context) {
        return StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return SimpleDialog(
                  title: Row(children: [
                    const Expanded(
                      child: Text('Connect your pot!'),
                    ),
                    _passCommission
                        ? IconButton(
                            onPressed: () {
                              if (!_passCommission) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.close))
                        : const SizedBox.shrink()
                  ]),
                  titlePadding: const EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 0.0),
                  children: <Widget>[
                    SizedBox(
                      height: 350,
                      width: 350,
                      child: PageView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), //AlwaysScrollableScrollPhysics(),
                        controller: _controller,
                        itemBuilder: (BuildContext context, int index) {
                          return _pages[index % _pages.length];
                        },
                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(20.0),
                      child: DotsIndicator(
                        color: const Color(0xffccd5ae),
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageSelected: (int page) {
                          _controller.animateToPage(
                            page,
                            duration: _kDuration,
                            curve: _kCurve,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              return BluetoothOffScreen(state: state);
            });
      }).then((exit) {});
}

class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    Key? key,
    required this.controller,
    required this.itemCount,
    required this.onPageSelected,
    this.color = Colors.white,
  }) : super(listenable: controller, key: key);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;

  final Color color;

  // The base size of the dots
  static const double _kDotSize = 8.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.5;

  // The distance between the center of each dot
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return SizedBox(
      width: _kDotSpacing,
      child: Center(
        child: Material(
          color: color,
          type: MaterialType.circle,
          child: SizedBox(
            width: _kDotSize * zoom,
            height: _kDotSize * zoom,
            child: InkWell(
              onTap: () => {/*onPageSelected(index) */},
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
