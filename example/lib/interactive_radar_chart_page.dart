import 'package:flutter/material.dart' hide Axis;
import 'package:radar_chart_widget/axis.dart';
import 'package:radar_chart_widget/polygon_data_sets.dart';
import 'package:radar_chart_widget/radar_chart_widget.dart';
import 'package:radar_chart_widget/radar_data_sets.dart';

class InteractiveRadarChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Interactive雷达图"),
      ),
      body: Container(
        child: RadarChartWidget(dataSets: _buildRadarChartDataSource(context)),
      ),
    );
  }
}

RadarDataSets _buildRadarChartDataSource(BuildContext context) {
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
    axisTitleStyle: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
    polygonStyle: PolygonStyle(lineWidth: 3, joinRadius: 4),
    onTapAxisTitle: (axis, atIdx) async {
      final subject = axis.title;
      final scoreInSubject = <String>[];
      scoreList.forEach((stu) {
        final text = stu.title + "：" + stu.valueList[atIdx].toString() + "分";
        scoreInSubject.add(text);
      });
      await showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text("$subject各学生成绩"),
          content: Text(scoreInSubject.join("\n")),
        );
      });
    },
    onTapPolygonPoint: (polygon, atIdx, pointIdx) async {
      final stuName = polygon.title;
      final subject = subjectList[pointIdx].title;
      final score = polygon.valueList[pointIdx];
      await showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: Text(stuName + "的" + subject + "成绩："),
          content: Text(score.toString() + "分"),
        );
      });
    },
  );
}