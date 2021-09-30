import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FilterType {
  datePicker,
  numericEval
}

enum DataType {
  date,
  numeric,
  integer,
  string
}

enum ChartType {
  barChart,
  lineChart,
  pieChart,
  listView,
  numView
}

String formatData(dynamic value, DataType xType) {
  switch (xType) {
    case DataType.date:
      return DateFormat("dd/MM/yy").format(DateTime.fromMicrosecondsSinceEpoch(value.toInt()));
    case DataType.numeric:
      return NumberFormat.compact(locale: 'pt-BR').format(value as double);
    case DataType.string:
      return (value as String);
    default:
      return value.toString();
  }
}

Object sortFilter(bool greater, List<List<Object>> data) {
  if (data[0][0] is num) {
    if (greater) {
      return data.reduce((a, b) => (a[0] as double) > (b[0] as double) ? a : b)[0];
    }
    return data.reduce((a, b) => (a[0] as double) < (b[0] as double) ? a : b)[0];
  }
  if (greater) {
    return data.reduce((a, b) => (a[0] as String).compareTo(b[0] as String) > 0 ? a : b)[0];
  }
  return data.reduce((a, b) => (a[0] as String).compareTo(b[0] as String) < 0 ? a : b)[0];


}

Object filterGreater(List<List<Object>> data) {
  return sortFilter(true, data);
}

Object filterLesser(List<List<Object>> data) {
  return sortFilter(false, data);
}


const Map<String, dynamic> uiConfig = {
  "name": "Mobi7 Dashboard",
  "color": Colors.blue,
  "brightness": Brightness.dark,
};

final List<Map<String, dynamic>> chartsConfig = [
  {
    "section": {
      "name": "Veículos Ativos",
      "color": const Color(0x402c4260)
    },
    "charts": [
        {
        "chart": {
          "name": "Série Histórica",
          "type": ChartType.lineChart,
          "size": [800, 300],
          "ticks": [7, 5],
          "titles": ["", "Veículos"],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/total_active/time_series",
          "xType": DataType.date,
        },
      },
      {
        "chart": {
          "name": "Atual",
          "type": ChartType.numView,
          "size": [400, 300],
          "getData": (value) {
            return (value as int);
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/total_active/current_vehicles",
          "xType": DataType.integer
        },
      },
    ]
  },

  {
    "section": {
      "name": "Confiabilidade GPS",
      "color": const Color(0x402c4260)
    },
    "charts": [
      {
        "chart": {
          "name": "Série Histórica",
          "type": ChartType.lineChart,
          "size": [400, 300],
          "ticks": [3, 5],
          "titles": ["", "Veículos"],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/gps_conf/time_series",
          "xType": DataType.date
        },
      },
      {
        "chart": {
          "name": "Porcentagem",
          "type": ChartType.pieChart,
          "size": [400, 300],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/gps_conf/current_percentage",
          "xType": DataType.string
        },
      },
      {
        "chart": {
          "name": "Veículos",
          "type": ChartType.listView,
          "size": [400, 300],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/gps_conf/current_vehicles",
          "xType": DataType.string
        },
      },
    ]
  },

  {
    "section": {
      "name": "Não Posicionando",
      "color": const Color(0x402c4260)
    },
    "charts": [
      {
        "chart": {
          "name": "Série Histórica",
          "type": ChartType.lineChart,
          "size": [400, 300],
          "ticks": [3, 5],
          "titles": ["", "Veículos"],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/not_reporting/time_series",
          "xType": DataType.date
        },
      },
      {
        "chart": {
          "name": "Porcentagem",
          "type": ChartType.pieChart,
          "size": [400, 300],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) (value as List).cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/not_reporting/current_percentage",
          "xType": DataType.string
        },
      },
      {
        "chart": {
          "name": "Veículos",
          "type": ChartType.listView,
          "size": [400, 300],
          "getData": (List<dynamic> data) {
            return <List<Object>>[
              for (var value in data) [value].cast<Object>()
            ];
          }
        },

        "data": {
          "query": "http://127.0.0.1:5000/not_reporting/current_vehicles",
          "xType": DataType.string
        },
      },
    ]
  },
];

/*
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
      "xType": DataType.date
    },

    "filters": {
      "left": {
        "key": "minData",
        "name": "Início",
        "min": DateTime(2008).millisecondsSinceEpoch,
        "max": null, //TODAY
        "default": filterLesser
      },
      "right": {
        "key": "maxData",
        "name": "Fim",
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
      "xType": DataType.date
    }
  },
  {
    "chart": {
      "name": "Pizza Teste",
      "type": ChartType.pieChart,
      "size": [400, 300]
    },

    "data": {
      "query": "http://127.0.0.1:8080",
      "xType": DataType.string
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
      "xType": DataType.numeric
    },

    "filters": {
      "right": {
        "key": "maxVal",
        "name": "Fim",
        "min": null,
        "max": null, //TODAY
        "default": filterGreater
      }
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
      "xType": DataType.date
    }
  }
];*/