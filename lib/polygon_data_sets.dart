import 'package:flutter/material.dart';
/// 闭合多边形的样式
class PolygonStyle {
  final double lineWidth;
  final double joinRadius;
  final double fillOpacity;

  const PolygonStyle({
    this.lineWidth = 2,
    this.joinRadius = 3,
    this.fillOpacity = 0.2,
  });
}


/// 一个闭合多边形上的点
class PolygonDataSets {
  String title;
  List<double> valueList;
  Color color;
  bool hidden;
  List<Offset>? points;
  Path? path;

  bool get show {
    return !hidden;
  }

  PolygonDataSets({
    required this.title,
    required this.valueList,
    required this.color,
    this.hidden = false,
  });
}

