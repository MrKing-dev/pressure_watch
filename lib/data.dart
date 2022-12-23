import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pressure_watch/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

import 'init.dart';

class Data {
  var apiKey = '34be28e6e2d64c17702640838b0efbf8';
  var historykey = 'S7SS885MC58WKKSPJ2DQ96TWX';
  static var currentWeatherConditions;

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

  Future<dynamic> getHistoricalWeatherData() async {
    print('Getting location for getHistoricalWeatherData');
    Position position = await determinePosition();
    print('Finished location for getHistoricalWeatherData');

    var latitude = position.latitude;
    var longitude = position.longitude;
    var placemark = await placemarkFromCoordinates(latitude, longitude);
    var zip = placemark[0].postalCode;
    var today = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var todayFormatted = formatter.format(today);
    var sevenDaysBeforeNow = today.subtract(Duration(days: 7));
    var sevenDaysBeforeNowFormatted = formatter.format(sevenDaysBeforeNow);

    print('Running api call for getHistoricalWeatherData');
    final response = await http.get(Uri.parse(
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$zip/$sevenDaysBeforeNowFormatted/$todayFormatted?unitGroup=us&elements=datetimeEpoch%2Cpressure&include=days%2Cobs%2Cremote%2Ccurrent%2Cfcst&key=S7SS885MC58WKKSPJ2DQ96TWX&contentType=json'));

    if (response.statusCode == 200) {
      print('Got good response from api call in getHistoricalWeatherData');
      return jsonDecode(response.body);
    } else {
      print('Bad api call in getHistoricalWeatherData');
      throw Exception('Failed to load historical weather data');
    }
  }

  Future<Map> populateWeatherGraph() async {
    var pressureArr = Map();
    var pressureList = [];
    print('Running getHistoricalWeatherData.');
    var historicalWeather = await getHistoricalWeatherData();
    print('Recieved data from getHistoricalWeatherData.');

    print('Running loop to create pressureArr map.');
    for (var i = 0; i < 7; i++) {
      pressureArr[(historicalWeather['days'][i]['datetimeEpoch']) * 1000] =
          historicalWeather['days'][i]['pressure'];
    }
    print('Finished loop to create pressureArr map.');
    try {
      pressureArr[Init.currentWeather.timeStamp * 1000] =
          Init.currentWeather.pressure;
      print('Added current pressure to pressureArr map.');
    } catch (err) {
      print('Error adding current pressure to pressureArr map.');
      print(err);
    }
    print(pressureArr);

    print(pressureArr);
    return pressureArr;
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
      pressure: json['days'][0]['pressure'].toDouble(),
      timeStamp: json['data'][0]['dt'],
    );
  }
}
