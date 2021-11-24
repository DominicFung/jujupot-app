import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage(
      {Key? key,
      required this.heroTag,
      required this.potName,
      required this.potDesign,
      required this.potSpecies})
      : super(key: key);

  final String heroTag;
  final String potName;
  final String potDesign;
  final String potSpecies;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  var selectedCard = 'WEIGHT';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd4a373),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text('Details',
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 20, color: Colors.white)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            color: Colors.white,
          )
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
      ),
      body: ListView(children: [
        Stack(children: [
          Container(
              height: MediaQuery.of(context).size.height - 82,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent),
          Positioned(
            top: 75,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                  color: Colors.white),
              height: MediaQuery.of(context).size.height - 100,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Positioned(
              top: 30,
              left: (MediaQuery.of(context).size.width / 2) - 100,
              child: Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(widget.heroTag),
                              fit: BoxFit.cover)),
                      height: 200,
                      width: 200,
                    ),
                  ))),
          Positioned(
              top: 250,
              left: 25,
              right: 25,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.potName,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          color: Colors.grey)),
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: const Color(0xffd4a373)),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 1.5, left: 7, right: 7),
                            child: Text(widget.potSpecies,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Colors.white)),
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                      height: 150,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            _buildInfoCard('Moisture', '20', '%'),
                            _buildInfoCard('Moisture', '20', '%'),
                            _buildInfoCard('Moisture', '20', '%'),
                            _buildInfoCard('Moisture', '20', '%'),
                          ])),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                          color: Color(0xffd4a373)),
                      height: 50.0,
                      child: const Center(
                        child: Text('Disable Notifications',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Montserrat')),
                      ),
                    ),
                  )
                ],
              )),
        ]),
      ]),
    );
  }

  Widget _buildInfoCard(String sensorTitle, String info, String unit) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: InkWell(
            onTap: () {
              selectCard(sensorTitle);
            },
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: sensorTitle == selectedCard
                      ? const Color(0xffd4a373)
                      : Colors.white,
                  border: Border.all(
                      color: sensorTitle == selectedCard
                          ? Colors.transparent
                          : Colors.grey.withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 0.75),
                ),
                height: 100.0,
                width: 100.0,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 15.0),
                        child: Text(sensorTitle,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12.0,
                              color: sensorTitle == selectedCard
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.7),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(info,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14.0,
                                    color: sensorTitle == selectedCard
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold)),
                            Text(unit,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 12.0,
                                  color: sensorTitle == selectedCard
                                      ? Colors.white
                                      : Colors.black,
                                ))
                          ],
                        ),
                      )
                    ]))));
  }

  selectCard(cardTitle) {
    setState(() {
      selectedCard = cardTitle;
    });
  }
}
