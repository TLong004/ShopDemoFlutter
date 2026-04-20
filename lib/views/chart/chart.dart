import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:shopdemo/views/chart/map_data.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});
  final option = '''
{
series: [
  {
    type: 'map',
    mapType: 'VN_MAP',
    roam: true,
    itemStyle: {
      areaColor: '#323c48',
      borderColor: '#111',
    },
    emphasis: {
      itemStyle: {
        areaColor: '#2a333d',
      },
    },
  }
]}
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Echarts(
          extraScript: '''
            var mapData = ${jsonEncode(vietnamGeoJson)};
            echarts.registerMap('VN_MAP', mapData);
          ''',
          option: option,
        ),
      ),
    );
  }
}
