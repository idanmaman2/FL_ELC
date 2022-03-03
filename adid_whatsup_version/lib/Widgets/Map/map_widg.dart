import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLng;

class MapWid extends StatefulWidget {
  MapWid({Key? key, required this.notifer}) : super(key: key);

  @override
  State<MapWid> createState() => _MapWidState();
  ValueNotifier<Position?> notifer;
}

class _MapWidState extends State<MapWid> {
  latLng.LatLng convert(ValueNotifier<Position?>? x,
      {double addx = 0, double addy = 0}) {
    Position? x2 = x?.value;
    if (x2 == null)
      return latLng.LatLng(0, 0);
    else
      return latLng.LatLng(
          (x2 as Position).latitude + addx, (x2 as Position).longitude + addy);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: ValueListenableBuilder(
          builder: (C, x, ch) {
            return FlutterMap(
              options: MapOptions(
                center: convert(widget.notifer),
                zoom: 13.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  attributionBuilder: (_) {
                    return Text("");
                  },
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: convert(widget.notifer),
                      builder: (ctx) => Container(
                        child: Image.asset("assets\\ps1.png"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          valueListenable: widget.notifer as ValueListenable<Position?>,
        ));
  }
}
