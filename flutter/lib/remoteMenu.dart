// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rfircontrollerapp/addRemoteCode.dart';
import 'package:rfircontrollerapp/database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rfircontrollerapp/main.dart';
import 'package:rfircontrollerapp/mqtt/mqttHive.dart';

class RemoteMenu extends StatefulWidget {
  const RemoteMenu({super.key});

  @override
  State<RemoteMenu> createState() => _RemoteMenuState();
}

class _RemoteMenuState extends State<RemoteMenu> {
  final _mybox = Hive.box('mybox');
  IrDataBase db = IrDataBase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: const Color.fromRGBO(35, 35, 35, 1),
                padding: const EdgeInsets.all(15),
                child: const Text(
                  "ESP 32",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      wordSpacing: 2,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.topRight,
                height: 55,
                child: InkWell(
                  child: Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 17, right: 27),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 25)),
                  onTap: () {},
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            color: const Color.fromRGBO(25, 25, 25, 1),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: db.commandList.length,
              itemBuilder: (context, index) {
                return InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        child: Center(
                          child: Text(
                            db.commandList[index][0].toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                        )),
                    onTap: () {
                      manager.publish(db.commandList[index][1].toString());
                    });
              },
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          color: const Color.fromRGBO(25, 25, 25, 1),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(100))),
                child: const Center(
                  child: Text(
                    "+",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                )),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddRemoteCode())),
          ),
        ),
      ],
    ));
  }
}
