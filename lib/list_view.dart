import 'package:flutter/material.dart';
import 'cfg.dart';

class ListViewWidget extends StatelessWidget {
  const ListViewWidget({Key? key,
    required this.data,
    required this.xType
  }) : super(key: key);

  final List<List<double>> data;
  final DataType xType;
  
  List<Widget> getList() {
    List<Widget> ret = [];
    for (var value in data) {
      ret.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatData(value[0], xType) + ":", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value[1].toStringAsFixed(2))
              ]
            )
          )
        )
      );
    }
    
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: getList()
        )
      )
    );
  }
}