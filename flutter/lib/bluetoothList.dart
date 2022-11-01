import 'package:flutter/material.dart';
import 'package:rfircontrollerapp/wifiSettings.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Cihaz Eşle",
      home: CihazEsleEkran(),
    );
  }
}

class CihazEsleEkran extends StatefulWidget {
  const CihazEsleEkran({super.key});

  @override
  State<CihazEsleEkran> createState() => _CihazEsleEkranState();
}

class _CihazEsleEkranState extends State<CihazEsleEkran> {
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
            "Cihaz Eşle",
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
                  InkWell(
                    child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: const Center(
                          child: Text(
                            "ESP32",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        )),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WifiSettingsEdit())),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
