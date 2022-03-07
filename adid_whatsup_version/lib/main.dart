import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';
import '/Widgets/bluetooth_device_card.dart';
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
  final ValueNotifier<Position?> _notifer = ValueNotifier<Position?>(null);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _screenLock = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  void initState() {
    flutterBlue.startScan(timeout: const Duration(seconds: 50));
    super.initState();
    print("testing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(children: [
        Expanded(
          flex: 4,
          child:
              StreamBuilder(stream: flutterBlue.scanResults.asyncMap((dvItems) {
            dvItems =
                dvItems.where((element) => element.device.name != "").toList();
            dvItems.sort((x, y) => x.rssi.compareTo(y.rssi) * -1);
            return dvItems;
          }), builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            if (snapshot.connectionState == ConnectionState.done) {}

            return ListView.builder(
              itemCount: (snapshot.data as List<ScanResult>).length,
              itemBuilder: (context, index) {
                ScanResult dv = (snapshot.data as List<ScanResult>)[index];
                print(dv);
                return BCard(device: dv);
              },
            );
          }),
        ),
        Expanded(
          flex: 1,
          child: StreamBuilder(
              stream: Geolocator.getPositionStream(
                  desiredAccuracy: LocationAccuracy.high),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.connectionState == ConnectionState.done) {}
                Future.delayed(Duration(milliseconds: 15)).then((value) =>
                    widget._notifer.value = snapshot.data as Position);
                return Text(
                  snapshot.data.toString(),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                );
              }),
        )
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
