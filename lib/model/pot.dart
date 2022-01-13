import 'dart:convert';

class Pot {
  String potId = "";
  String title = "";

  Map<String, dynamic> sensors = {};
  Map<String, dynamic> controllables = {};

  Pot(this.title, this.sensors, this.controllables);
  Pot.fromJson(Map<String, dynamic> potjson) {
    title = potjson['deviceName'];
    potId = potjson['deviceId'];
    //sensors = json.decode(potjson['sensors']) as Map<String, dynamic>;
    controllables =
        json.decode(potjson['controllables']) as Map<String, dynamic>;
  }
}
