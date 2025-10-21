import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({ super.key });

  @override
  State<StatefulWidget> createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  String bruh = "BRUH";
  Object? usbDevices;

  @override
  void initState() {
    super.initState();

    getUSBDevices();
  }

  Future<void> getUSBDevices() async {
    final commandResult = await Process.run("bash", ["-c", "lsusb -v | jc --lsusb"]);

    if (commandResult.exitCode != 0) return;

    setState(() {
      // bruh = commandResult.stdout;


      usbDevices = json.decode(commandResult.stdout);
    });

  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text("USB Bus", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          Text(bruh),
          Text("PCI Bus", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
}