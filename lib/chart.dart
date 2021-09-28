import 'dart:convert';

import 'package:dashboard/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'bar_chart.dart';
import 'cfg.dart';
import 'events.dart';
import 'line_chart.dart';
import 'list_view.dart';

enum ChartState {
  loading,
  error,
  finished
}

class Chart {
  Map<String, Map<String, dynamic>> chartConfig = {};
  BuildContext context;
  ChartState state = ChartState.loading;
  List<List<Object>> data = [];
  Map<String, String> params = {"left": "", "right": ""};

  Chart(this.chartConfig, this.context) {
    if (chartConfig["chart"]!["type"] == ChartType.lineChart && chartConfig["data"]!["xType"] == DataType.string) {
      throw Exception("X data of type String isn't compatible with chart type LineChart");
    }
    getData();
  }

  getData() async {
    state = ChartState.loading;
    eventBus.fire(ChartUpdated(chartConfig["chart"]!["name"]));

    int acc = 0;
    while (true) {
      http.Response response;
      try {
        Map<String, String> queryParams = {};
        if (params["left"]! != "") {
          queryParams[chartConfig["filters"]!["left"]["key"]] = params["left"]!;
        }
        if (params["right"]! != "") {
          queryParams[chartConfig["filters"]!["right"]["key"]] = params["right"]!;
        }
        final url = Uri.parse(chartConfig["data"]!["query"] + "?" + Uri(queryParameters: queryParams).query);

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

        data = <List<Object>>[for (var value in jsonDecode(response.body)["data"] as List) <Object>[value[0], value[1]]];
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

  _filterAction(String filter) async {
    switch (chartConfig["filters"]![filter]["type"]) {
      case FilterType.datePicker:
        var date = await showDatePicker(
            context: context,
            initialDate: (params[filter] == "")
                ? (chartConfig["filters"]![filter]["default"] == null)
                ? DateTime.now()
                : DateTime.fromMillisecondsSinceEpoch((chartConfig["filters"]![filter]["default"](data) as double).toInt())
                : DateTime.fromMillisecondsSinceEpoch(int.parse(params[filter]!)),
            firstDate: (chartConfig["filters"]![filter].containsKey("min") && chartConfig["filters"]![filter]["min"] != null) ?
              DateTime.fromMillisecondsSinceEpoch(chartConfig["filters"]![filter]["min"]) : DateTime(2000),
            lastDate: (chartConfig["filters"]![filter].containsKey("max") && chartConfig["filters"]![filter]["max"] != null) ?
              DateTime.fromMillisecondsSinceEpoch(chartConfig["filters"]![filter]["max"]) : DateTime.now(),
            helpText: chartConfig["filters"]![filter]["name"],
            cancelText: "Limpar",
            confirmText: "Filtrar"
        );
        if (date != null) {
          params[filter] = date.millisecondsSinceEpoch.toString();
        } else {
          params[filter] = "";
        }
        getData();
        break;
      default:
        break;
    }
  }

  Widget _filterWidget(String filter) {
    final Widget? child;
    switch (chartConfig["filters"]![filter]["type"]) {
      case FilterType.datePicker:
        child = ElevatedButton(
            onPressed: (state == ChartState.finished) ? () {_filterAction(filter);} : null,
            child: Text(chartConfig["filters"]![filter]["name"])
        );
        break;
      default:
        child = null;
    }
    return SizedBox(width: 75, height: 25, child: child);
  }

  Widget _getHeader() {
    final title = Text(
        chartConfig["chart"]!["name"],
        style: const TextStyle(color: Colors.white, fontSize: 22)
    );

    Widget left = const SizedBox(width: 100);
    Widget right = const SizedBox(width: 100);
    if (chartConfig.containsKey("filters")) {
      if (chartConfig["filters"]!.containsKey("right")) {
        right = _filterWidget("right");
      }
      if (chartConfig["filters"]!.containsKey("left")) {
        left = _filterWidget("left");
      }
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          left,
          title,
          right
        ]
    );
  }

  Widget getGraph() {
    Widget child;

    if (state != ChartState.finished) {
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
              child: BarChartWidget(data: data, xType: chartConfig["data"]!["xType"])
          );
          break;
        case (ChartType.lineChart):
          child = Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: LineChartWidget(data: data, xType: chartConfig["data"]!["xType"], ticks: chartConfig["chart"]!["ticks"])
          );
          break;
        case (ChartType.pieChart):
          child = Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PieChartWidget(data: data, xType: chartConfig["data"]!["xType"]),
          );
          break;
        case (ChartType.listView):
          child = Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListViewWidget(data: data, xType: chartConfig["data"]!["xType"]),
          );
          break;
        default:
          child = const Text("Invalid type!");
      }
    }

    Widget header = _getHeader();

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
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: header
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