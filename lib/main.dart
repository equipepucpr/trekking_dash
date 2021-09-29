import 'package:dashboard/section.dart';
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
  List<Section> sections = [];

  @override
  void initState() {
    super.initState();

    for (var section in chartsConfig) {
      sections.add(Section(section, context));
    }

    eventBus.on<ChartUpdated>().listen((event) {
      print("Chart updated: " + event.name);
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<Widget> getSections() {
    List<Widget> ret = [];
    for (var section in sections) {
      ret.add(section.getSection());
    }

    return ret;
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
            children: getSections()
          ),
        )
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
