import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:shopdemo/views/chart/map.dart';
import 'package:shopdemo/views/chart/map_data.dart';

class Chart extends StatelessWidget {
  Chart({super.key});

  @override
  Widget build(BuildContext context) {
    final option1 = jsonEncode({
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

    final option2 = jsonEncode({
      'visualMap': {
        'type': 'continuous',
        'min': 0,
        'max': 2500,         
        'text': ['Cao', 'Thấp'],
        'calculable': true,
        'inRange': {
          'color': ['#e0f3f8', '#ffffbf', '#fee090', '#d73027']
        },
        'bottom': '10%',
        'left': 'center',
        'orient': 'horizontal'
      },
      'series': [
        {
          'name': 'Doanh số',
          'type': 'map',
          'map': 'VN_MAP_2', 
          'roam': true,   
          'emphasis': {
            'label': { 'show': true, 'color': '#000' },
            'itemStyle': { 'areaColor': '#ffcc00' } 
          },
          'data': densityData 
        }
      ]
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column( 
          children: [
            Expanded(
              child: Echarts(
                key: ValueKey(option1),
                extraScript: '''
                  var mapData = ${jsonEncode(vietnamGeoJson)};
                  echarts.registerMap('VN_MAP', mapData);
                ''',
                option: option1,
              ),
            ),

            Container(height: 1, color: Colors.grey.shade300),

            Expanded(
              child: Echarts(
                key: ValueKey(option2),
                extraScript: '''
                  var mapData = ${jsonEncode(vietnamGeoJson)};
                  echarts.registerMap('VN_MAP_2', mapData);
                ''',
                option: option2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
