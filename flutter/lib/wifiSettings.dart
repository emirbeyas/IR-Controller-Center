// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rfircontrollerapp/database.dart';
import 'package:rfircontrollerapp/remoteMenu.dart';
import 'dart:convert' show utf8;

class WifiSettingsEdit extends StatefulWidget {
  const WifiSettingsEdit({super.key});

  @override
  State<WifiSettingsEdit> createState() => _WifiSettingsEditState();
}

class _WifiSettingsEditState extends State<WifiSettingsEdit> {
  final _mybox = Hive.box('mybox');
  IrDataBase db = IrDataBase();

  TextEditingController ssidTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();

  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  final String TARGET_DEVICE_NAME = "ESP32";

  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;

  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic targetCharacteristic;

  String connectionText = "";
  bool buttonState = false;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    try {
      scanSubScription.cancel();
    } catch (exception, stackTrace) {
      print(exception.toString());
    }
  }

  connectToDevice() async {
    if (targetDevice == null) return;

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if (targetDevice == null) return;

    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    List<BluetoothService> services = await targetDevice.discoverServices();
    services.forEach((service) {
      // do something with service
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            targetCharacteristic = characteristic;

            setState(() {
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        });
      }
    });
  }

  writeData(String data) async {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    try {
      await targetCharacteristic.write(bytes);
    } catch (exception, stackTrace) {
      print(exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SafeArea(
            child: Container(
          width: MediaQuery.of(context).size.width,
          color: const Color.fromRGBO(35, 35, 35, 1),
          padding: const EdgeInsets.all(15),
          child: const Text(
            "Wifi Bilgileri",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                wordSpacing: 2,
                letterSpacing: 2,
                fontWeight: FontWeight.w600),
          ),
        )),
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(15),
          width: MediaQuery.of(context).size.width,
          color: const Color.fromRGBO(25, 25, 25, 1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  enabled: !buttonState,
                  controller: ssidTextController,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.white)),
                      labelText: "WIFI SSID",
                      labelStyle: TextStyle(color: Colors.white)),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                TextField(
                  enabled: buttonState,
                  controller: passTextController,
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.white)),
                      labelText: "WIFI SIFRE",
                      labelStyle: TextStyle(color: Colors.white)),
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 15),
                InkWell(
                    child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(35, 35, 35, 1),
                            border: Border.all(
                                color: const Color.fromARGB(15, 15, 15, 1),
                                width: 4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Align(
                          child: Text(
                            buttonState ? "Kaydet" : "Ileri",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                wordSpacing: 2,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                    onTap: () {
                      if (!buttonState) {
                        String ssid = 'SSID' + ssidTextController.text;
                        writeData(ssid);
                        setState(() {
                          buttonState = true;
                        });
                      } else {
                        String pass = 'PASS' + passTextController.text;
                        writeData(pass);
                        _mybox.put("SSID", ssidTextController.text);
                        _mybox.put("SSIDPASS", passTextController.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RemoteMenu()));
                      }
                    })
              ],
            ),
          ),
        ))
      ],
    ));
  }
}
