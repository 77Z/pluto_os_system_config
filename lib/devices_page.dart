import 'package:flutter/material.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({ super.key });

  @override
  State<StatefulWidget> createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text("USB Bus", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          Text("PCI Bus", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
}