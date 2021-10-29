import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:jujupot_app_v1/connect_pot/bluetooth_disabled_screen.dart';

import 'connect_pot/wifi_input.dart';

class ConnectPotDialog extends StatefulWidget {
  const ConnectPotDialog({Key? key}) : super(key: key);

  @override
  _ConnectPotDialogState createState() => _ConnectPotDialogState();
}

class _ConnectPotDialogState extends State<ConnectPotDialog> {
  final GlobalKey<WifiInputState> wifiFormKey = GlobalKey<WifiInputState>();

  final _controller = PageController();
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  static const _scanLengthSeconds = 60;

  Stream<List<ScanResult>> btsr = FlutterBlue.instance.scanResults;
  StreamSubscription<List<ScanResult>>? btsrl;

  late List<Widget> _pages;

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
      WifiInput(key: wifiFormKey),
    ];

    super.initState();
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
    btsrl ??= btsr.listen((event) {
      if (event.isNotEmpty) {
        for (ScanResult d in event) {
          if (d.device.name.contains("JuJuPot-")) {
            //print("JuJuPot Found! " + d.device.name);
            d.device.connect();
            _controller.animateToPage(1, duration: _kDuration, curve: _kCurve);

            //FlutterBlue.instance.stopScan();
            //stopBtConnectionListener();
          } else {
            //print(d.device.name);
          }
        }
      }
    });
  }

  void stopBtConnectionListener() {
    btsrl?.cancel();
    btsrl = null;
  }

  void showConnectPotDialog(BuildContext context, FlutterBlue bt) => showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return SimpleDialog(
                  title: const Text('Connect your pot!'),
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
                        color: const Color(0xfffec5bb),
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
