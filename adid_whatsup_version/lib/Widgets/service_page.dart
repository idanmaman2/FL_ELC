import 'dart:async';

import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rive/rive.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class DeviceControlPage extends StatefulWidget {
  const DeviceControlPage({Key? key, required this.device}) : super(key: key);
  final ScanResult device;
  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late RiveAnimationController _controller;
  String con = "Not Conected ";
  bool isActive = false;
  List<BluetoothService> listy = [];
  bool av = false;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache();
  @override
  void initState() {
    super.initState();
    widget.device.device
        .connect(timeout: const Duration(seconds: 20))
        .then((value) {
      setState(() => con = "Conected Success");
      Timer.periodic(const Duration(milliseconds: 450), (T) async {
        print("flash light ${await TorchLight.isTorchAvailable()}");
        if (!isActive) {
          if (av) TorchLight.disableTorch();
          if (await audioPlayer.state == PlayerState.PLAYING) {
            audioPlayer.pause();
          }
        }
        print("hello");

        if (isActive) {
          if (await TorchLight.isTorchAvailable()) {
            (av ? TorchLight.disableTorch() : TorchLight.enableTorch());
            av = !av;
          }
          if (await PerfectVolumeControl.getVolume() != 1) {
            await PerfectVolumeControl.setVolume(1);
          }
          if (await audioPlayer.state == PlayerState.STOPPED ||
              await audioPlayer.state == PlayerState.COMPLETED) {
            final uri = await audioCache.load('audio.mp3');
            await audioPlayer.play(uri.toString(), isLocal: true);
          }
          if (await audioPlayer.state == PlayerState.PAUSED) {
            await audioPlayer.resume();
          }
          if (await Vibration.hasAmplitudeControl() as bool) {
            Vibration.vibrate(amplitude: 128);
          } else {
            Vibration.vibrate();
          }

          List<BluetoothService> services =
              await widget.device.device.discoverServices();
          if (services.length > 0) {
            List<int> bytes = utf8.encode("hello world");
            print("bytes recieved");
            var characteristics = services[0].characteristics;
            setState(() {
              listy.removeWhere((element) => true);
              listy.insertAll(0, services);
            });

            //  await characteristics
            //        .firstWhere((x) => x.properties.write)
            //       .write(bytes, withoutResponse: true);
          }
        }
      });
    }).onError((error, stackTrace) {
      setState(() => con = "ERROR");
    }).timeout(const Duration(seconds: 20), onTimeout: () {
      setState(() => con = "ERROR");
    });
    _controller = SimpleAnimation('Animation 1');
  }

  void initCon() {
    setState(() {
      _controller.isActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.device.name)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: listy.length,
              itemBuilder: (context, index) {
                var dv = listy[index];
                return Text(dv.toString());
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: CircleAvatar(
                radius: 130,
                child: ClipOval(
                  child: InkWell(
                    onTap: () {
                      print("pressed");
                      isActive = !isActive;
                      _controller.isActive = !_controller.isActive;
                      if (!_controller.isActive) _controller.dispose();
                    },
                    child: Stack(children: [
                      RiveAnimation.asset(
                        "assets\\gps_ani.riv",
                        controllers: [_controller],
                        fit: BoxFit.cover,
                        onInit: (_) => initCon(),
                      ),
                      const Center(child: Text("Start Gps Track")),
                    ]),
                  ),
                )),
          ),
          Expanded(flex: 1, child: Text(con))
        ],
      ),
    );
  }
}
