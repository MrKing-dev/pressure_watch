import 'package:flutter/material.dart';
import 'package:pressure_watch/data.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Init {
  Future<String> setLocationCity() async {
    Position position = await Data().determinePosition();
    print('Got location');

    var output = placemarkFromCoordinates(position.latitude, position.longitude)
        .then((placemarks) {
      var output;
      print('Got placemarks');
      if (placemarks.isNotEmpty) {
        output = placemarks[0];
        print('Got output');
      } else {
        print('No placemarks');
      }

      print(output);
      print('${output.locality}, ${output.administrativeArea}');
      return '${output.locality}, ${output.administrativeArea}';
    });

    return output;
  }
}
