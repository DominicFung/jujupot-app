import 'package:flutter/material.dart';
import 'package:jujupot_app_v1/details_page.dart';
import 'package:jujupot_app_v1/connect_pot_dialog.dart';

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
        primarySwatch: Colors.pink,
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
  static const primaryCol = Color(0xfffec5bb);

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
                  color: Colors.white,
                  onPressed: () {},
                ),
                SizedBox(
                    width: 125.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const ConnectPotDialog(),
                        //const Icon(Icons.bluetooth_searching_rounded)),
                        IconButton(
                          onPressed: () {},
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
                  // Text('JujuPots',
                  //     style: TextStyle(
                  //         fontFamily: 'Montserrat',
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 25.0)),
                  // Text('!',
                  //     style: TextStyle(
                  //         fontFamily: 'Montserrat',
                  //         color: Colors.white,
                  //         fontSize: 25.0))
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
                          children: [
                            _buildJujuPot('assets/plate1.png', 'Burro\'s Tail',
                                'Sedum Morganianum', '', 12),
                            _buildJujuPot('assets/plate2.png',
                                'Crown of Thorns', '', '', 100),
                            _buildJujuPot('assets/plate6.png',
                                'Flaming Katy (kal...', '', '', 20),
                            _buildJujuPot('assets/plate5.png',
                                'Aloe Vera (aloe vera)', '', '', 53),
                          ],
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
      String design, double health) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DetailsPage(
                      heroTag: imgPath,
                      potName: name,
                      potDesign: design,
                      potSpecies: species)));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Hero(
                    tag: imgPath,
                    child: Image(
                        image: AssetImage(imgPath),
                        fit: BoxFit.cover,
                        height: 75.0,
                        width: 75.0)),
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
                        Text(species,
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
                            color: Color(0xffF8EDEB), shape: BoxShape.circle),
                        child: Center(
                            child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                              const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.favorite_rounded,
                                      color: primaryCol, size: 30)),
                              Text(health.toString() + "%",
                                  style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey)),
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
                              potSpecies: species)));
                    })
              ],
            )));
  }
}
