import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pressure_watch/chart_data.dart';
import 'package:pressure_watch/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Data {
  var apiKey = '34be28e6e2d64c17702640838b0efbf8';

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Future<Data> setLocation() async {
  //   Position position = await determinePosition();
  //   latitude = position.latitude;
  //   longitude = position.longitude;
  //   print(latitude);
  //   print(longitude);
  //   return this;
  // }

  Future<CurrentWeather> getCurrentWeatherData() async {
    Position position = await determinePosition();
    var latitude = position.latitude;
    var longitude = position.longitude;

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$latitude&lon=$longitude&exclude=minutely,hourly&units=imperial&appid=$apiKey'));

    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current weather data');
    }
  }

  Future<HistoricalWeather> getHistoricalWeatherData(int date) async {
    Position position = await determinePosition();
    var latitude = position.latitude;
    var longitude = position.longitude;

    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=$latitude&lon=$longitude&dt=$date&appid=$apiKey'));

    if (response.statusCode == 200) {
      return HistoricalWeather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load historical weather data');
    }
  }

  Future<List> populateWeatherGraph(int daysToRun) async {
    var pressureArr = Map();
    var pressureList = [];
    var iterator = 0;

    for (var i = 0; i < daysToRun; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      var dateUnix = date.millisecondsSinceEpoch ~/ 1000;
      var dateLocal = date.toLocal();
      var dateReadable = '${dateLocal.month}/${dateLocal.day}';
      var historicalWeather = await getHistoricalWeatherData(dateUnix);
      pressureArr[dateReadable] = historicalWeather.pressure.toDouble();
    }
    print(pressureArr);
    pressureArr.forEach((k, v) {
      pressureList.add(WeatherPoint(z: k, y: v, x: iterator.toDouble()));
      iterator++;
    });

    return pressureList;
  }
}

class CurrentWeather {
  final timeStamp;
  final temp;
  final pressure;
  final weather;
  final icon;

  const CurrentWeather(
      {required this.timeStamp,
      required this.temp,
      required this.pressure,
      required this.weather,
      required this.icon});

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      timeStamp: json['current']['dt'],
      temp: json['current']['temp'],
      pressure: json['current']['pressure'],
      weather: json['current']['weather'][0]['main'],
      icon: json['current']['weather'][0]['icon'],
    );
  }
}

class HistoricalWeather {
  final double pressure;
  final int timeStamp;

  const HistoricalWeather({required this.pressure, required this.timeStamp});

  factory HistoricalWeather.fromJson(Map<String, dynamic> json) {
    return HistoricalWeather(
      pressure: json['data'][0]['pressure'].toDouble(),
      timeStamp: json['data'][0]['dt'],
    );
  }
}
