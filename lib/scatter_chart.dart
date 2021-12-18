import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'cfg.dart';

List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

class ScatterChartWidget extends StatelessWidget {
  const ScatterChartWidget({Key? key,
    required this.data,
    required this.xType,
    required this.ticks,
    required this.titles,
  }) : super(key: key);

  final List<List<Object>> data;
  final DataType xType;
  final List<int?> ticks;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    final minMax = getMaxMin();
    final delta = getDelta();

    return ScatterChart(
      ScatterChartData(
        scatterSpots: [getData()],
        scatterTouchData: ScatterTouchData(
          touchTooltipData: ScatterTouchTooltipData(
              maxContentWidth: 100,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              // getTooltipItems: (touchedSpots) {
              //   return touchedSpots.map((LineBarSpot touchedSpot) {
              //     final textStyle = TextStyle(
              //       color: touchedSpot.bar.colors[0],
              //       fontWeight: FontWeight.bold,
              //       fontSize: 14,
              //     );
              //     return LineTooltipItem(
              //         'x: ${formatData(touchedSpot.x, xType)}\ny: ${touchedSpot.y.toStringAsFixed(2)}', textStyle);
              //   }).toList();
              // }
              ),
          handleBuiltInTouches: true,
        ),
        titlesData: titlesData(),
        borderData: borderData,
        maxY: minMax[1][1],
        minY: minMax[0][1],
        maxX: minMax[1][0],
        minX: minMax[0][0],
        clipData: FlClipData.all(),
        axisTitleData: getAxisTitles(),
        gridData: FlGridData(
          verticalInterval: (ticks[0] == null) ? null : delta[0]/(ticks[0]!*3 - 1),
          horizontalInterval: (ticks[1] == null) ? null : delta[1]/(ticks[1]! - 1),
        )
      ),
    );
  }

  FlAxisTitleData getAxisTitles() {
    return FlAxisTitleData(
        leftTitle: AxisTitle(
          showTitle: (titles[1] != "") ? true : false,
          titleText: titles[1],
          textStyle: const TextStyle(
            color: Color(0xff7589a2)
          )
        ),
        bottomTitle: AxisTitle(
          showTitle: (titles[0] != "") ? true : false,
          titleText: titles[0],
          textStyle: const TextStyle(
            color: Color(0xff7589a2)
          ),
        )
    );
  }

  getData() {
    return LineChartBarData(
      spots: [for (var value in data) FlSpot(value[0] as double, value[1] as double)],
      isCurved: false,
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

  getMaxMin() {
    final maxX = (data.reduce((a, b) => (a[0] as double) > (b[0] as double) ? a : b)[0] as double);
    final minX = (data.reduce((a, b) => (a[0] as double) < (b[0] as double) ? a : b)[0] as double);
    final maxY = (data.reduce((a, b) => (a[1] as double) > (b[1] as double) ? a : b)[1] as double);
    final minY = (data.reduce((a, b) => (a[1] as double) < (b[1] as double) ? a : b)[1] as double);

    final deltaX = maxX - minX;
    final deltaY = maxY - minY;
    const coef = 0.1;

    return [[minX, minY], [maxX, maxY + deltaY*coef]];
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
      reservedSize: 45,
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
      rightTitles: SideTitles(showTitles: true, reservedSize: 20, getTextStyles: (context, value) => const TextStyle(color: Color(0x00000000))),
    );
  }

  FlBorderData get borderData => FlBorderData(
    show: false,
  );
}