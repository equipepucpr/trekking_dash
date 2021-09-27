import 'package:flutter/material.dart';

import 'cfg.dart';
import 'chart.dart';
import 'events.dart';

void main() {
  runApp(const Dashboard());
}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: uiConfig["name"],
      theme: ThemeData(
        primarySwatch: uiConfig["color"],
        brightness: uiConfig["brightness"]
      ),
      home: HomePage(title: uiConfig["name"]),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chart> charts = [];

  @override
  void initState() {
    super.initState();

    for (var chartConfig in chartsConfig) {
      charts.add(Chart(chartConfig, context));
    }

    eventBus.on<ChartUpdated>().listen((event) {
      print("Chart updated: " + event.name);
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<Widget> chartLayout() {
    List<Widget> widgets = [const SizedBox(height: 25)];
    double width = MediaQuery.of(context).size.width*0.95;
    double curWidth = width;
    List<Widget> curRow = [];
    List<List<Widget>> rows = [];

    double maxWidth = 0;

    for (Chart chart in charts) {
      double chartSize = chart.chartConfig["chart"]!["size"][0];
      if (chartSize > maxWidth) {
        maxWidth = chartSize;
        if (maxWidth > width) {
          return [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.25),
              child: const Text("Resolução inválida!")
            )
          ];
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

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center (
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chartLayout()
          ),
        )
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
