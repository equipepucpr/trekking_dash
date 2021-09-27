import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'bar_chart.dart';
import 'cfg.dart';
import 'events.dart';
import 'line_chart.dart';

enum ChartState {
  loading,
  error,
  finished
}

class Chart {
  Map<String, Map<String, dynamic>> chartConfig;
  ChartState state = ChartState.loading;
  List<List<double>> data = [];

  Chart(this.chartConfig) {
    getData();
  }

  getData() async {
    state = ChartState.loading;
    eventBus.fire(ChartUpdated(chartConfig["chart"]!["name"]));

    int acc = 0;
    while (true) {
      http.Response response;
      try {
        var url = Uri.parse(chartConfig["data"]!["query"]);
        response = await http.get(url);
        if (response.statusCode != 200) {
          print("Status code: " + response.statusCode.toString());
          acc++;
          if (acc > 3) {
            state = ChartState.error;
            break;
          }
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        data = <List<double>>[for (var value in jsonDecode(response.body)["data"] as List) <double>[value[0], value[1]]];
      } catch (e) {
        print(e);
        acc++;
        if (acc > 3) {
          state = ChartState.error;
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }

      state = ChartState.finished;
      break;
    }
    eventBus.fire(ChartUpdated(chartConfig["chart"]!["name"]));
  }

  Widget getGraph() {
    Widget child;

    if (state != ChartState.finished) {
      final double aspectRatio = chartConfig["chart"]!["size"][0] /
          chartConfig["chart"]!["size"][1];

      child = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 50,
              height: 50,
              child: (state == ChartState.error)
                  ? Tooltip(message: "Tentar novamente", child: IconButton(icon: const Icon(Icons.error), onPressed: () {getData();}))
                  : const CircularProgressIndicator()
            )
          ]
        );
    } else {
      switch (chartConfig["chart"]!["type"]) {
        case (ChartType.barChart):
          child = Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: BarChartWidget(data: data, xType: chartConfig["data"]!["xValue"]["type"])
          );
          break;
        case (ChartType.lineChart):
          child = Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: LineChartWidget(data: data, xType: chartConfig["data"]!["xValue"]["type"], ticks: chartConfig["chart"]!["ticks"])
          );
          break;
        default:
          child = const Text("Invalid type!");
      }
    }

    final container = SizedBox(
        width: chartConfig["chart"]!["size"][0],
        height: chartConfig["chart"]!["size"][1],
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: const Color(0xff2c4260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    chartConfig["chart"]!["name"],
                    style: const TextStyle(color: Colors.white, fontSize: 22)
                  )
                )
              ),
              Expanded(
                child: child
              )
            ]
          ),
        )
    );

    return container;
  }
}