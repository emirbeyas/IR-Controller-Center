import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rfircontrollerapp/remoteMenu.dart';
import 'package:rfircontrollerapp/wifiSettings.dart';
import 'package:rfircontrollerapp/database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rfircontrollerapp/mqtt/mqttHive.dart';

import 'device.dart';

MQTTManager manager = MQTTManager();
TextEditingController irCommandTextController = TextEditingController();

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('mybox');
  //manager.initializeMQTTClient();
  //manager.connect();
  irCommandTextController.text = "Bir Kızıl ötesi komut bekleniyor";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final _mybox = Hive.box('mybox');
    IrDataBase db = IrDataBase();
    if (_mybox.get("SSID") == null || _mybox.get("SSIDPASS") == null) {
      return MaterialApp(
        title: "Cihaz Sec",
        home: StreamBuilder<BluetoothState>(
            stream: FlutterBlue.instance.state,
            initialData: BluetoothState.unknown,
            builder: (c, snapshot) {
              final state = snapshot.data;
              if (state == BluetoothState.on) {
                return const WifiSettingsEdit();
              }
              return BluetoothOffScreen(state: state);
            }),
      );
    } else {
      return const MaterialApp(
        home: RemoteMenu(),
      );
    }
  }
}

class CihazSecEkran extends StatefulWidget {
  const CihazSecEkran({super.key});

  @override
  State<CihazSecEkran> createState() => _CihazSecEkranState();
}

class _CihazSecEkranState extends State<CihazSecEkran> {
  final _mybox = Hive.box('mybox');
  IrDataBase db = IrDataBase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SafeArea(
              child: Container(
            width: MediaQuery.of(context).size.width,
            color: const Color.fromRGBO(35, 35, 35, 1),
            padding: const EdgeInsets.all(15),
            child: const Text(
              "Cihaz Seçin",
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
              color: const Color.fromRGBO(25, 25, 25, 1),
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBlue.instance.scanResults,
                      initialData: [],
                      builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((result) => ListTile(
                                  title: Container(
                                      height: 100,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(5))),
                                      child: Center(
                                        child: Text(
                                          result.device.name == ""
                                              ? "No Name "
                                              : result.device.name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24),
                                        ),
                                      )),
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    result.device.connect();
                                    return WifiSettingsEdit();
                                  })),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 8)));
          }
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// InkWell(
//                     child: Container(
//                         height: 100,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                             border: Border.all(color: Colors.white, width: 1),
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(5))),
//                         child: Center(
//                           child: Text(
//                             _mybox.get("DEVICENAME").toString(),
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 24),
//                           ),
//                         )),
//                     onTap: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const WifiSettingsEdit())),
//                   ),



// ListTile(
//                                   title: Text(result.device.name == ""
//                                       ? "No Name "
//                                       : result.device.name),
//                                   subtitle: Text(result.device.id.toString()),