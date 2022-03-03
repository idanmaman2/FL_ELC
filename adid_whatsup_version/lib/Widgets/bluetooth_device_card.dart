import 'dart:math';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BCard extends StatelessWidget {
  Color? rndColor;
  final ScanResult device;
  final Random rnd = Random();
  BCard({Key? key, required this.device}) : super(key: key) {
    rndColor = Color.fromARGB(
        255, rnd.nextInt(255), rnd.nextInt(255), rnd.nextInt(255));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 5, color: rndColor as Color),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: AutoSizeText(
                "device name: ${(device.device.name == "" ? "Unknown" : device.device.name)}",
                style: TextStyle(fontSize: 30, color: rndColor),
                maxLines: 2,
              )),
          Expanded(flex: 1, child: Container(color: rndColor)),
          Expanded(
              flex: 2,
              child: AutoSizeText(
                "type: ${device.device.type}",
                style: const TextStyle(fontSize: 30),
                maxLines: 2,
              )),
          Expanded(flex: 1, child: Container(color: rndColor)),
          Expanded(
              flex: 2,
              child: AutoSizeText(
                "rssi: ${device.rssi}",
                maxLines: 1,
              )),
          Expanded(flex: 1, child: Container(color: rndColor)),
        ],
      ),
    );
  }
}
