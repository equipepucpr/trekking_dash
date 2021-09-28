import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'cfg.dart';
import 'indicator.dart';

const List<Color> colors = [
  Color(0xff0293ee),
  Color(0xff13d38e),
  Color(0xff845bef),
  Color(0xfff8b250),
  Color(0xfffc4d3d),
  Color(0xffff3dbb),
  Color(0xffffeb52),
  Color(0xff4a4a4a),
];

getColor(int index) {
  return colors[index & 0x7];
}

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({Key? key,
    required this.data,
    required this.xType,}) : super(key: key);

  final List<List<Object>> data;
  final DataType xType;

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<PieChartWidget> {
  int touchedIndex = -1;

  double getPercentage(int index) {
    return (widget.data[index][1] as double) * 100.0 / widget.data.fold(0, (p, c) => p + (c[1] as double));
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> ret = [];

    for (int i = 0; i < widget.data.length; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;

      final value = getPercentage(i);

      ret.add(
        PieChartSectionData(
          color: getColor(i),
          value: value,
          title: value.toStringAsFixed(1) + "%",
          radius: radius,
          titleStyle: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
          )
      );
    }

    return ret;
  }

  List<Widget> getLabels() {
    List<Widget> ret = [];
    for (int i = 0; i < widget.data.length; i++) {
      ret.add(
        Indicator(
          color: getColor(i),
          text: formatData(widget.data[i][0], widget.xType),
          isSquare: true,
        )
      );
      ret.add(
        const SizedBox(
          height: 4,
        )
      );
    }

    ret.add(
      const SizedBox(
        height: 6,
      )
    );

    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                      PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections()),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getLabels(),
            ),
          ],
    );
  }
}