import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:shopdemo/views/chart/map.dart';
import 'package:shopdemo/views/chart/map_data.dart';

String prepareMapScript(Map<String, dynamic> geoJson, String map_name) {
  final String jsonString = jsonEncode(geoJson);
  return '''
      var mapData = $jsonString;
      echarts.registerMap('$map_name', mapData);
    ''';
}

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  String? final1;
  String? final2;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final script1 = await Isolate.run(() => prepareMapScript(vietnamGeoJson, 'VN_MAP'));
    final script2 = await Isolate.run(() => prepareMapScript(vietnam2, 'VN_MAP_2'));

    if (mounted) {
      setState(() {
        final1 = script1;
        final2 = script2;
        _isProcessing = false;
      });
    }
  }

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
      body: _isProcessing ?
      Center(child: CircularProgressIndicator(),)
      : Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column( 
          children: [
            Expanded(
              child: Echarts(
                key: ValueKey(option1),
                extraScript: final1!,
                option: option1,
              ),
            ),

            Container(height: 1, color: Colors.grey.shade300),

            Expanded(
              child: Echarts(
                key: ValueKey(option2),
                extraScript: final2!,
                option: option2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
