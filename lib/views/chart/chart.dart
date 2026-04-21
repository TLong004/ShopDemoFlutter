import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:shopdemo/views/chart/map.dart';
import 'package:shopdemo/views/chart/map_data.dart';

class Chart extends StatelessWidget {
  Chart({super.key});

  @override
  Widget build(BuildContext context) {
    final option = jsonEncode({
      'visualMap': {
        'type': 'piecewise',
        'pieces': [
          {'value': 3, 'label': 'Hà Nội', 'color': 'red'},
          {'value': 0, 'label': 'Miền Bắc', 'color': '#ff9800'},
          {'value': 1, 'label': 'Miền Trung', 'color': '#4caf50'},
          {'value': 2, 'label': 'Miền Nam', 'color': '#2196f3'},
        ],
        'orient': 'horizontal',
        'bottom': 100,
        'left': 'center'
      },
      'series': [
        {
          'type': 'map',
          'map': 'VN_MAP',
          'roam': true,
          'data': regionData,
          'itemStyle': {
            'areaColor': '#eee',
            'borderColor': '#111',
          },
          'emphasis': {
            'itemStyle': {
              'areaColor': '#2a333d',
            },
            'label': {'show': true, 'color': '#fff'}
          }
        }
      ]
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Echarts(
          key: ValueKey(option), 
          extraScript: '''
            var mapData = ${jsonEncode(vietnamGeoJson)};
            echarts.registerMap('VN_MAP', mapData);
          ''',
          option: option,
        )
      ),
    );
  }
}
