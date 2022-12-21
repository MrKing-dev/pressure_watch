import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pressure_watch/chart_data.dart';
import 'package:pressure_watch/data.dart';
import 'package:pressure_watch/init.dart';
import 'package:pressure_watch/line_chart.dart';
import 'package:pressure_watch/splash_screen.dart';
import 'package:pressure_watch/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pressure Watch',
      theme: ColorThemes().getTheme(DateTime.now().toLocal().hour > 6 &&
          DateTime.now().toLocal().hour < 18),
      home: FutureBuilder(
        future: Init().setLocationCity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage(
                title: 'Pressure Watch', location: snapshot.data.toString());
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.location});

  final String title;
  final String location;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String weather = 'Default weather';
  num pressure = 0;
  num temp = 0;
  var weatherIcon = '01d';
  double sliderValue = 1.0;
  List chartInputList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.sunny),
        onPressed: () async {
          CurrentWeather currentWeather = await Data().getCurrentWeatherData();
          setState(() {
            weather = currentWeather.weather;
            pressure = currentWeather.pressure;
            temp = currentWeather.temp;
            weatherIcon = currentWeather.icon;
          });
        },
      ),
      body: Container(
        decoration: ColorGradients().getGradient(
            DateTime.now().toLocal().hour > 6 &&
                DateTime.now().toLocal().hour < 18),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                //Location text
                flex: 2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                  child: Text(
                    widget.location,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Flexible(
                // Current weather items
                flex: 3,
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${pressure.toString()} hPa',
                              style: Theme.of(context).textTheme.headline4,
                              textAlign: TextAlign.left),
                          Text(
                            '${temp.toString()} °F',
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        width: 3,
                        height: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Image.network(
                        'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                        scale: 0.75,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                // Chart load items
                flex: 2,
                child: Container(
                  width: 300,
                  child: Column(
                    children: [
                      Text('Select number of days to load for chart.'),
                      Slider(
                        value: sliderValue,
                        label: sliderValue.toInt().toString(),
                        min: 1,
                        max: 10,
                        divisions: 10,
                        onChanged: (double value) {
                          setState(() {
                            sliderValue = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: (() async {
                          weatherPoints(sliderValue.toInt()).then((value) {
                            setState(() {
                              chartInputList = value;
                            });
                          });
                        }),
                        child: Text('Load Chart'),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                // Chart display
                flex: 5,
                child: Container(
                  child: LineChartWidget(chartInputList),
                  margin: EdgeInsets.all(3),
                  padding: EdgeInsets.all(15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}