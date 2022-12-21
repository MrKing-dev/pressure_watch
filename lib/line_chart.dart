import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pressure_watch/chart_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'colors.dart';

class LineChartWidget extends StatelessWidget {
  final List weatherPoints;
  LineChartWidget(this.weatherPoints, {super.key});
  final mainColor = ColorThemes()
      .getTheme(DateTime.now().toLocal().hour > 6 &&
          DateTime.now().toLocal().hour < 18)
      .colorScheme
      .primary;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (weatherPoints.length.toDouble() - 1),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: ((value, meta) {
                switch (DateTime.now()
                    .subtract(Duration(days: value.toInt()))
                    .toLocal()
                    .weekday) {
                  case 1:
                    return Text('Mon');
                  case 2:
                    return Text('Tue');
                  case 3:
                    return Text('Wed');
                  case 4:
                    return Text('Thu');
                  case 5:
                    return Text('Fri');
                  case 6:
                    return Text('Sat');
                  case 7:
                    return Text('Sun');

                  default:
                    return Text('Invalid');
                }
              }),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
          border: Border.all(color: Colors.white, width: 2),
        ),
        backgroundColor: Colors.grey[800]!.withOpacity(0.2),
        lineBarsData: [
          LineChartBarData(
            spots: weatherPoints.map((e) => FlSpot(e.x, e.y)).toList(),
            isCurved: true,
            color: mainColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData:
                BarAreaData(show: true, color: mainColor.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
