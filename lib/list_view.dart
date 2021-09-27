import 'package:flutter/material.dart';
import 'cfg.dart';

class ListViewWidget extends StatelessWidget {
  ListViewWidget({Key? key,
    required this.data,
    required this.xType
  }) : super(key: key);

  final List<List<double>> data;
  final DataType xType;
  final ScrollController _scrollController = ScrollController();
  
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
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatData(data[index][0], xType) + ":", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(data[index][1].toStringAsFixed(2))
                  ]
                )
              )
            )
          );
        }
      ),
    );
  }
}