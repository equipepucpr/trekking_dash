import 'package:flutter/material.dart';
import 'cfg.dart';

class NumViewWidget extends StatelessWidget {
  const NumViewWidget({Key? key,
    required this.data,
    required this.xType
  }) : super(key: key);

  final Object data;
  final DataType xType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatData(data, xType),
            textScaleFactor: 2.5,
          )
        ]
      )
    );
  }
}