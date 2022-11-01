import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

class IrDataBase {
  String? ssid;
  String? ssidpass;

  List commandList = [];

  // reference our box
  final _myBox = Hive.box('mybox');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    commandList = [
      ["Turn On Tv", "0x03545ASD65"],
      ["Turn On Aircontioner", "0x03545ASD65"],
    ];

    updateDataBase();
  }

  // load the data from database
  void loadData() {
    commandList = _myBox.get("COMMANDLIST");

    ssid = _myBox.get("SSID");
    ssidpass = _myBox.get("SSIDPASS");
  }

  // update the database
  void updateDataBase() {
    _myBox.put("COMMANDLIST", commandList);
    _myBox.put("SSID", ssid);
    _myBox.put("SSIDPASS", ssidpass);
  }

  IrDataBase() {
    if (_myBox.get("COMMANDLIST") == null) {
      createInitialData();
    } else {
      loadData();
    }
  }
}
