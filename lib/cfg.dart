import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FilterType {
  datePicker,
  sortBy,
  numericEval
}

enum DataType {
  date,
  numeric,
  integer,
}

enum ChartType {
  barChart,
  lineChart,
  pieChart,
  listView
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

double sortFilter(bool greater, List<List<double>> data) {

  if (greater) {
    return data.reduce((a, b) => a[0] > b[0] ? a : b)[0];
  }
  return data.reduce((a, b) => a[0] < b[0] ? a : b)[0];
}

double filterGreater(List<List<double>> data) {
  return sortFilter(true, data);
}

double filterLesser(List<List<double>> data) {
  return sortFilter(false, data);
}


const Map<String, dynamic> uiConfig = {
  "name": "Mobi7 Dashboard",
  "color": Colors.blue,
  "brightness": Brightness.dark
};

final List<Map<String, Map<String, dynamic>>> chartsConfig = [
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
    },

    "filters": {
      "left": {
        "key": "minData",
        "name": "Início",
        "type": FilterType.datePicker,
        "min": DateTime(2008).millisecondsSinceEpoch,
        "max": null, //TODAY
        "default": filterLesser
      },
      "right": {
        "key": "maxData",
        "name": "Fim",
        "type": FilterType.datePicker,
        "min": DateTime(2008).millisecondsSinceEpoch,
        "max": null, //TODAY
        "default": filterGreater
      }
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
      "name": "Pizza Teste",
      "type": ChartType.pieChart,
      "size": [400, 300]
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
  },
  {
    "chart": {
      "name": "Lista Teste",
      "type": ChartType.listView,
      "size": [400, 300]
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