import 'package:flutter/material.dart' hide Axis;
import 'package:radar_chart_widget/axis.dart';
import 'package:radar_chart_widget/polygon_data_sets.dart';
import 'package:radar_chart_widget/radar_chart_widget.dart';
import 'package:radar_chart_widget/radar_data_sets.dart';

import 'interactive_radar_chart_page.dart';

class RadarChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("雷达图"),
        actions: [TextButton(onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) {
                return InteractiveRadarChartPage();
              })
          );
        }, child: Text("带点击的雷达图", style: TextStyle(color: Colors.white),))],
      ),
      body: Container(
        child: RadarChartWidget(dataSets: _buildRadarChartDataSource()),
      ),
    );
  }
}

RadarDataSets _buildRadarChartDataSource() {
  final subjectList = [
    Axis(title: "语文", min: 0, max: 150),
    Axis(title: "数学", min: 0, max: 150),
    Axis(title: "英语", min: 0, max: 150),
    Axis(title: "物理", min: 0, max: 100),
    Axis(title: "化学", min: 0, max: 100),
    Axis(title: "地理", min: 0, max: 100),
  ];
  final liLeiScore = PolygonDataSets(
    title: "李雷",
    valueList: [75, 133, 88, 92, 88, 40],
    color: RadarDataSets.colors.first,
  );
  final hanMeiMeiScore = PolygonDataSets(
    title: "韩梅梅",
    valueList: [130, 93, 138, 45, 38, 70],
    color: RadarDataSets.colors[1],
  );
  final scoreList = [liLeiScore, hanMeiMeiScore];
  return RadarDataSets(
    axisList: subjectList,
    polygonList: scoreList,
  );
}