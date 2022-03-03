import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';

import 'bluetooth_device_card.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "";
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

    // Start scanning

// Listen to scan results
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
