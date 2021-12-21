import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'cfg.dart';

List<Color> gradientColors = [
  const Color(0xff23b6e6),
  const Color(0xff02d39a),
];

class ScatterSpotNamed extends ScatterSpot {

  late String spotName;
  late Color color;

  ScatterSpotNamed(double x,
  double y, {
  bool? show,
  double? radius,
  required this.color, required this.spotName}) : super(x, y);
} 

class ScatterChartWidget extends StatelessWidget {
  const ScatterChartWidget({Key? key,
    required this.data,
    required this.xType,
  }) : super(key: key);

  final List<List<Object>> data;
  final DataType xType;

  @override
  Widget build(BuildContext context) {
    final minMax = getMaxMin();
    final delta = getDelta();

    return ScatterChart(
      ScatterChartData(
        minX: 0,
        minY: 0,
        maxX: 50,
        maxY: 30,
        scatterSpots: getData(),
        scatterTouchData: ScatterTouchData(
          touchTooltipData: ScatterTouchTooltipData(
              maxContentWidth: 100,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (ScatterSpot touchedBarSpot) {
                  return ScatterTooltipItem(
                    (touchedBarSpot is ScatterSpotNamed) ? touchedBarSpot.spotName : "D",
                    textStyle: TextStyle(
                      height: 1.2,
                      color: Colors.grey[100],
                      fontStyle: FontStyle.normal,
                    ),
                    bottomMargin: 10,
                  );
                },
              ),
          handleBuiltInTouches: true,
        ),
        borderData: borderData,
        clipData: FlClipData.all(),
      ),
    );
  }

  getData() {
    return [for (var value in data) ScatterSpotNamed(value[0] as double, value[1] as double, 
    color: value[2] == 'Trekking' ? const Color(0xFF610127) : value[2].toString().contains("Cone") ? const Color(0xFFD18700) : const Color(0xFFFFFFFF), 
    spotName: value[2].toString())];
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

  FlBorderData get borderData => FlBorderData(
    show: false,
  );
}