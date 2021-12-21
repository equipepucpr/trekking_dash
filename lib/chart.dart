import 'dart:async';
import 'dart:convert';

import 'package:trekk_dash/pie_chart.dart';
import 'package:trekk_dash/scatter_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'bar_chart.dart';
import 'cfg.dart';
import 'events.dart';
import 'line_chart.dart';
import 'list_view.dart';
import 'num_view.dart';

enum ChartState {
  loading,
  error,
  finished
}

class Chart {
  Map<String, Map<String, dynamic>> chartConfig = {};
  BuildContext context;
  ChartState state = ChartState.loading;
  Object data = [];
  Map<String, String> params = {"left": "", "right": ""};

  Chart(this.chartConfig, this.context) {
    if (chartConfig["chart"]!["type"] == ChartType.lineChart && chartConfig["data"]!["xType"] == DataType.string) {
      throw Exception("X data of type String isn't compatible with chart type LineChart");
    }
    Timer.periodic(const Duration(seconds: 1), (timer) {
      getData();
    });
  }

  getData() async {
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
        data = jsonDecode(response.body);
      } catch (e) {
        print(e);
        acc++;
        if (acc > 3) {
          state = ChartState.error;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      state = ChartState.finished;
      break;
    }
    eventBus.fire(ChartUpdated(chartConfig["chart"]!["name"]));
  }

  _filterAction(String filter) async {
    switch (chartConfig["data"]!["xType"]) {
      case DataType.date:
        var date = await showDatePicker(
            context: context,
            initialDate: (params[filter] == "")
                ? (chartConfig["filters"]![filter]["default"] == null)
                ? DateTime.now()
                : DateTime.fromMicrosecondsSinceEpoch((chartConfig["filters"]![filter]["default"](data) as double).toInt())
                : DateTime.fromMicrosecondsSinceEpoch(int.parse(params[filter]!)),
            firstDate: (chartConfig["filters"]![filter].containsKey("min") && chartConfig["filters"]![filter]["min"] != null) ?
              DateTime.fromMicrosecondsSinceEpoch(chartConfig["filters"]![filter]["min"]) : DateTime(2000),
            lastDate: (chartConfig["filters"]![filter].containsKey("max") && chartConfig["filters"]![filter]["max"] != null) ?
              DateTime.fromMicrosecondsSinceEpoch(chartConfig["filters"]![filter]["max"]) : DateTime.now(),
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
      case DataType.numeric:
      case DataType.integer:
        String filterValue = (params[filter] == "")
            ? (chartConfig["filters"]![filter]["default"] == null)
            ? ""
            : (chartConfig["filters"]![filter]["default"](data) as double).toInt().toString()
            : params[filter]!;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(chartConfig["filters"]![filter]["name"]),
              content: SingleChildScrollView(
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Valor para filtrar',
                  ),
                  initialValue: filterValue,
                  onChanged: (value) {
                      filterValue = value;
                  },
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Limpar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    params[filter] = "";
                    getData();
                  }
                ),
                TextButton(
                  child: const Text('Filtrar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    params[filter] = filterValue;
                    getData();
                  },
                ),
              ],
            );
          },
        );
        break;
      default:
        break;
    }
  }

  Widget _filterWidget(String filter) {
    final Widget? child;
    child = ElevatedButton(
        onPressed: (state == ChartState.finished) ? () {_filterAction(filter);} : null,
        child: Text(chartConfig["filters"]![filter]["name"])
    );

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
          child = BarChartWidget(data: chartConfig["chart"]!["getData"](data), xType: chartConfig["data"]!["xType"]);
          break;
        case (ChartType.lineChart):
          child = LineChartWidget(data: chartConfig["chart"]!["getData"](data),
            xType: chartConfig["data"]!["xType"],
            ticks: chartConfig["chart"]!["ticks"],
            titles: chartConfig["chart"]!["titles"]);
          break;
        case (ChartType.pieChart):
          child = PieChartWidget(data: chartConfig["chart"]!["getData"](data), xType: chartConfig["data"]!["xType"]);
          break;
        case (ChartType.scatterChart):
          child = ScatterChartWidget(data: chartConfig["chart"]!["getData"](data), xType: chartConfig["data"]!["xType"]);
          break;
        case (ChartType.listView):
          child = ListViewWidget(data: chartConfig["chart"]!["getData"](data), xType: chartConfig["data"]!["xType"]);
          break;
        case (ChartType.numView):
          child = NumViewWidget(data: chartConfig["chart"]!["getData"](data), xType: chartConfig["data"]!["xType"]);
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: child,
                )
              ),
              const Padding(
                padding: EdgeInsets.all(10),
              ),
            ]
          ),
        )
    );

    return container;
  }
}