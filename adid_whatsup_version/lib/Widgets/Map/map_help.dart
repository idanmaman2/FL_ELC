import 'dart:math';
import '../../primitives/point.dart';

class Map {
  static double Radius = 6378137;
  static double E = 0.0000000848191908426;
  static double D2R = pi / 180;
  static double PiDiv4 = pi / 4;

  static Point FromLonLat(
      double lon,
      double
          lat) //converts from Lon,Lat to X,Y (Maps Ui uses X,Y and doesnt use Lon,Lat)
  {
    var lonRadians = D2R * lon;
    var latRadians = D2R * lat;
    var x = Radius * lonRadians;
    //y=a×ln[tan(π/4+φ/2)×((1-e×sinφ)/(1+e×sinφ))^(e/2)]
    var y = Radius *
        log(tan(PiDiv4 + latRadians * 0.5) /
            pow(tan(PiDiv4 + asin(E * sin(latRadians)) / 2), E));
    return Point(x: x, y: y);
  }
}
