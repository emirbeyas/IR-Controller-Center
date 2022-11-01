// ignore_for_file: file_names, dead_code

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rfircontrollerapp/database.dart';
import 'package:rfircontrollerapp/main.dart';

class AddRemoteCode extends StatefulWidget {
  const AddRemoteCode({super.key});

  @override
  State<AddRemoteCode> createState() => _AddRemoteCodeState();
}

class _AddRemoteCodeState extends State<AddRemoteCode> {
  TextEditingController commandNameController = TextEditingController();

  final _mybox = Hive.box('mybox');
  IrDataBase db = IrDataBase();
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(15),
            color: const Color.fromRGBO(25, 25, 25, 1),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 45,
                  ),
                  InkWell(
                      child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.white54, width: 2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Center(
                            child: Text(
                              irCommandTextController.text,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          )),
                      onTap: () {}),
                  const SizedBox(height: 15),
                  TextField(
                    controller: commandNameController,
                    decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 2, color: Colors.white)),
                        labelText: "Komut Adı",
                        labelStyle: TextStyle(
                            color: Colors.white,
                            wordSpacing: 2,
                            letterSpacing: 2)),
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
                        child: const Align(
                          child: Text(
                            "Kaydet",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                wordSpacing: 2,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500),
                          ),
                        )),
                    onTap: () {
                      String irCom =
                          irCommandTextController.text.split(":")[2].trim();
                      db.commandList.add([commandNameController.text, irCom]);
                      db.updateDataBase();
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}



// Expanded(
//                 child: Container(
//               color: const Color.fromRGBO(25, 25, 25, 1),
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                     maxCrossAxisExtent: 440,
//                     childAspectRatio: 10 / 3,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20),
//                 padding: const EdgeInsets.all(15),
//                 itemCount: manager.commandListFromEsp.length,
//                 itemBuilder: (context, index) {
//                   return
//                 },
//               ),
//             )),