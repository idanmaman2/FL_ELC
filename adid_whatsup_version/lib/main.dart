import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import '/Widgets/bluetooth_device_card.dart';
import 'package:latlong2/latlong.dart' as latLng;

import 'Widgets/Map/map_widg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(title: 'ADID GPS FINDER'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  ValueNotifier<Position?> _notifer = ValueNotifier<Position?>(null);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _screenLock = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<List<ScanResult>> _incrementCounter() async {
    List<ScanResult> dvItems =
        await flutterBlue.startScan(timeout: const Duration(seconds: 4));

    dvItems = dvItems.where((element) => element.device.name != "").toList();
    dvItems.sort((x, y) => x.rssi.compareTo(y.rssi) * -1);
    return dvItems;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("testing");
    Timer.periodic(Duration(milliseconds: 200), (T) {
      if (!this._screenLock) {
        this._screenLock = true;
        (Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((_value) =>
                (widget._notifer as ValueNotifier<Position?>).value = _value));
        this._screenLock = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Expanded(
            flex: 1,
            child: ValueListenableBuilder(
              builder: (C, x, ch) {
                return Text(x.toString());
              },
              valueListenable: widget._notifer as ValueListenable<Position?>,
            )),
        Expanded(
            flex: 1,
            child: Center(
                child: FutureBuilder(
              builder: (context, projectSnap) {
                if (projectSnap.connectionState == ConnectionState.none &&
                    projectSnap.hasData == null) {
                  print('project snapshot data is: ${projectSnap.data}');
                  return Text("Failed");
                }
                if (!projectSnap.hasData)
                  return Center(child: CircularProgressIndicator());
                return Text(projectSnap.data.toString());
              },
              future: Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high),
            ))),
        
        Expanded(
          flex: 1,
          child: FutureBuilder(
            builder: (context, projectSnap) {
              if (projectSnap.connectionState == ConnectionState.none &&
                  projectSnap.hasData == null) {
                print('project snapshot data is: ${projectSnap.data}');
                return Text("Failed");
              }
              if (!projectSnap.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: (projectSnap.data as List<ScanResult>).length,
                itemBuilder: (context, index) {
                  ScanResult dv = (projectSnap.data as List<ScanResult>)[index];
                  return BCard(device: dv);
                },
              );
            },
            future: _incrementCounter(),
          ),
        ),
      ]),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MapWid(notifer: widget._notifer)),
        ),
        tooltip: 'Map',
        child: const Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
