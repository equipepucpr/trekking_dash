import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DataType {
  date,
  numeric,
  integer,
}

enum ChartType {
  barChart,
  lineChart
}

formatData(double value, DataType xType) {
  switch (xType) {
    case DataType.date:
      return DateFormat("dd/MM/yy").format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
    case DataType.numeric:
      return NumberFormat.compact(locale: 'pt-BR').format(value);
    default:
      return value.toString();
  }
}


const Map<String, dynamic> uiConfig = {
  "name": "Mobi7 Dashboard",
  "color": Colors.blue,
  "brightness": Brightness.dark
};

const List<Map<String, Map<String, dynamic>>> chartsConfig = [
  {
    "chart": {
      "name": "Linha Teste",
      "type": ChartType.lineChart,
      "size": [400, 300],
      "ticks": [4, null]
    },

    "data": {
      "query": "http://127.0.0.1:8000",
      "xValue": {
        "name": "Data",
        "type": DataType.date
      },
    }
  },
  {
    "chart": {
      "name": "Erro Teste",
      "type": ChartType.barChart,
      "size": [400, 300]
    },

    "data": {
      "query": "http://127.0.0.1:800",
      "xValue": {
        "name": "Data",
        "type": DataType.integer
      },
    }
  },
  {
    "chart": {
      "name": "Barra Teste",
      "type": ChartType.barChart,
      "size": [800, 300]
    },

    "data": {
      "query": "http://127.0.0.1:8000",
      "xValue": {
        "name": "Data",
        "type": DataType.date
      },
    }
  }
];