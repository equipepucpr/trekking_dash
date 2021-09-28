import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'cfg.dart';

List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({Key? key,
    required this.data,
    required this.xType,
    required this.ticks
  }) : super(key: key);

  final List<List<Object>> data;
  final DataType xType;
  final List<int?> ticks;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
              maxContentWidth: 100,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final textStyle = TextStyle(
                    color: touchedSpot.bar.colors[0],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  return LineTooltipItem(
                      'x: ${formatData(touchedSpot.x, xType)}\ny: ${touchedSpot.y.toStringAsFixed(2)}', textStyle);
                }).toList();
              }),
          handleBuiltInTouches: true,
          getTouchLineStart: (data, index) => 0,
        ),
        titlesData: titlesData(),
        borderData: borderData,
        clipData: FlClipData.all(),
        lineBarsData: [getData()]
      ),
    );
  }

  getData() {
    return LineChartBarData(
      spots: [for (var value in data) FlSpot(value[0] as double, value[1] as double)],
      isCurved: true,
      colors: gradientColors,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
  }

  getDelta() {
    final x = (data.reduce((a, b) => (a[0] as double) > (b[0] as double) ? a : b)[0] as double) - (data.reduce((a, b) => (a[0] as double) < (b[0] as double) ? a : b)[0] as double);
    final y = (data.reduce((a, b) => (a[1] as double) > (b[1] as double) ? a : b)[1] as double) - (data.reduce((a, b) => (a[1] as double) < (b[1] as double) ? a : b)[1] as double);

    return [x, y];
  }

  FlTitlesData titlesData() {
    final delta = getDelta();
    final sideTitle = SideTitles(
      showTitles: true,
      interval: (ticks[1] == null) ? null : delta[1]/(ticks[1]! - 1),
      getTextStyles: (context, value) => const TextStyle(
        color: Color(0xff7589a2),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        getTextStyles: (context, value) =>
        const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        margin: 25,
        interval: (ticks[0] == null) ? null : delta[0] / (ticks[0]! - 1),
        getTitles: (double value) {
          return formatData(value, xType);
        },
      ),
      leftTitles: sideTitle,
      topTitles: SideTitles(showTitles: false),
      rightTitles: sideTitle,
    );
  }

  FlBorderData get borderData => FlBorderData(
    show: false,
  );
}