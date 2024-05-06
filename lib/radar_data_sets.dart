import 'package:flutter/material.dart' hide Axis;
import 'equidistant_line_style.dart';
import 'axis.dart';
import 'cutting_line_style.dart';
import 'polygon_data_sets.dart';

class RadarDataSets {
  static List<Color> colors = [
    const Color(0xff5470c6),
    const Color(0xff91cc75),
    const Color(0xfffac858),
    const Color(0xffee6666),
    const Color(0xff73c0de),
    const Color(0xff3ba272),
    const Color(0xfffc8452),
    const Color(0xff9a60b4),
    const Color(0xffea7ccc),
  ];
  List<Axis> axisList;
  List<PolygonDataSets> polygonList;
  EquidistantLineStyle equidistantStyle;
  CuttingLineStyle cuttingStyle;
  PolygonStyle polygonStyle;
  TextStyle axisTitleStyle;
  /// 点击了多边形上的点，第一个int为多边形的序号，第二个为点在多边形中的序号
  void Function(PolygonDataSets, int, int)? onTapPolygonPoint;
  /// 点击了轴标题
  void Function(Axis, int)? onTapAxisTitle;
  Size? _size;

  double get suggestPadding {
    return (axisTitleStyle.fontSize ?? 14.0) * 2.0;
  }

  void setSize(Size? size) {
    _size = size;
  }
  Size? get size {
    return _size;
  }

  RadarDataSets({
    required this.axisList,
    required this.polygonList,
    this.equidistantStyle = const EquidistantLineStyle(),
    this.cuttingStyle = const CuttingLineStyle(),
    this.polygonStyle = const PolygonStyle(),
    this.axisTitleStyle = const TextStyle(fontSize: 14, color: Colors.black),
    this.onTapPolygonPoint,
    this.onTapAxisTitle,
  });
}
