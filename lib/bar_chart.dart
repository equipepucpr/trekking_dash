import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'cfg.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({Key? key,
    required this.data,
    required this.xType,
  }) : super(key: key);

  final List<List<double>> data;
  final DataType xType;

  @override
  Widget build(BuildContext context) {
    final maxY = data.reduce((a, b) => a[1] > b[1] ? a : b)[1];
    final minY = data.reduce((a, b) => a[1] < b[1] ? a : b)[1];
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups(),
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + (maxY - minY)*1/3,
        minY: minY - (maxY - minY)*1/6,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: const EdgeInsets.all(0),
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          rod.y.round().toString(),
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: SideTitles(
      showTitles: true,
      getTextStyles: (context, value) => const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      margin: 25,
      getTitles: (double value) {
        return formatData(data[value.toInt()][0], xType);
      },
    ),
    leftTitles: SideTitles(showTitles: false),
    topTitles: SideTitles(showTitles: false),
    rightTitles: SideTitles(showTitles: false),
  );

  FlBorderData get borderData => FlBorderData(
    show: false,
  );

  List<BarChartGroupData> barGroups() {
    var len = data.length - 1;
    List<BarChartGroupData> bars = [];

    for (var i = 0; i < data.length; i++) {
      bars.add(
        BarChartGroupData(
          x: len - i,
          barRods: [
            BarChartRodData(
                y: data[i][1], colors: [Colors.lightBlueAccent, Colors.greenAccent])
          ],
          showingTooltipIndicators: [0],
        )
      );
    }

    return bars;
  }
}