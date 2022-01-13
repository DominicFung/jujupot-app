import 'package:flutter/material.dart';

class TestPotConnected extends StatefulWidget {
  const TestPotConnected({Key? key, this.cloudConnectComplete})
      : super(key: key);

  final VoidCallback? cloudConnectComplete;

  @override
  TestPotConnectedState createState() => TestPotConnectedState();
}

class TestPotConnectedState extends State<TestPotConnected> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
            const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                child: Text(
                  "Congradulations! Your Device is attached and registered in the cloud!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                )),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: TextButton(
                onPressed: () {
                  widget.cloudConnectComplete!();
                },
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
                    child: Text('Done!',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Montserrat')),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
