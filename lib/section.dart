import 'package:flutter/material.dart';

import 'chart.dart';

class Section {
  List<Chart> charts = [];
  BuildContext context;
  Color sectionColor = const Color(0xffffffff);
  String sectionName = "";

  Section(Map<String, dynamic>sectionConfig, this.context) {
    for (var chartConfig in sectionConfig["charts"]) {
      charts.add(Chart(chartConfig, context));
    }

    if (sectionConfig["section"].containsKey("color")) {
      sectionColor = sectionConfig["section"]["color"];
    }
    sectionName = sectionConfig["section"]["name"];
  }

  Widget getSection() {
    List<Widget> widgets = [
      const SizedBox(height: 10),
      Text(sectionName, textScaleFactor: 1.5,),
      const SizedBox(height: 10)
    ];
    double width = MediaQuery
        .of(context)
        .size
        .width - 40;
    double curWidth = width;
    List<Widget> curRow = [];
    List<List<Widget>> rows = [];

    double maxWidth = 0;
    double maxRowWidth = 200;

    for (Chart chart in charts) {
      double chartSize = chart.chartConfig["chart"]!["size"][0];
      if (chartSize > maxWidth) {
        maxWidth = chartSize;
        if (maxWidth > width) {
            rows = [
              [
                Expanded(
                  child: Center (
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const[
                        Text("Resolução inválida!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Padding(padding: EdgeInsets.only(bottom: 10))
                      ]
                    )
                  )
                )
              ]
            ];
            break;
        }
      }

      if (curWidth - chartSize >= 0) {
        curRow.add(chart.getGraph());
        curWidth -= chartSize;
      } else {
        if (curRow.isNotEmpty) {
          rows.add(List.from(curRow));
        }
        curWidth = width - chartSize;
        curRow = [chart.getGraph()];
      }

      if ((width - curWidth) > maxRowWidth) {
        maxRowWidth = width - curWidth;
      }
    }
    rows.add(curRow);

    for (var row in rows) {
      widgets.add(
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
          )
      );
    }

    widgets.add(const SizedBox(height: 10));
    return SizedBox(
        width: maxRowWidth + 20,
        child: Card(
            color: sectionColor,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgets
            )
        )
    );
  }
}