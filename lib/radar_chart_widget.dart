import 'dart:math';
import 'package:flutter/material.dart' hide Axis;
import 'polygon_data_sets.dart';
import 'axis.dart';
import 'radar_data_sets.dart';
/// 雷达图
class RadarChartWidget extends StatefulWidget {
  RadarDataSets dataSets;
  RadarChartWidget({super.key,
    required this.dataSets,
  });
  @override
  State<StatefulWidget> createState() {
    return _RadarChartWidgetState();
  }

}

class _RadarChartWidgetState extends State<RadarChartWidget> {
  void onTapPosition(Offset position) {
    debugPrint("position $position");
    RadarDataSets dataSets = widget.dataSets;
    final size = dataSets.size;
    if (size != null) {
      final offset = Offset(size.width * 0.5, size.height * 0.5);
      final angle = toAngle(position, offset);
      final axisAmount = dataSets.axisList.length;
      if (axisAmount == 0) {
        return;
      }
      /// 缩小范围到某个轴
      final perAngle = 360.0 / axisAmount.toDouble();
      int targetAxisIndex = 0;
      var startAngle = perAngle * 0.5;
      int index = 1;
      while (startAngle < (360.0 - perAngle)) {
        final endAngle = startAngle + perAngle;
        if (angle > startAngle && angle < endAngle) {
          targetAxisIndex = index;
          break;
        }
        index += 1;
        startAngle = endAngle;
      }
      int? targetPolygonIndex;
      /// 查找多边形
      for (int i = dataSets.polygonList.length - 1; i >= 0; i--) {
        final polygon = dataSets.polygonList[i];
        if (polygon.hidden || polygon.points == null || !(targetAxisIndex < polygon.points!.length)) {
          continue;
        }
        final point = polygon.points![targetAxisIndex];
        final path = Path();
        path.addOval(Rect.fromCircle(center: point, radius: 10.0));
        if (path.contains(position)) {
          targetPolygonIndex = i;
          break;
        }
      }
      if (targetPolygonIndex != null && dataSets.onTapPolygonPoint != null) {
        final polygon = dataSets.polygonList[targetPolygonIndex];
        dataSets.onTapPolygonPoint!(polygon, targetPolygonIndex, targetAxisIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataSets = widget.dataSets;
    final style = dataSets.axisTitleStyle;
    final titleWidgets = <Widget>[];
    final suggestPadding = dataSets.suggestPadding;
    final amount = dataSets.axisList.length;
    final tapEnable = (dataSets.onTapAxisTitle != null);
    for (int i = 0; i < amount; i ++) {
      final axis = dataSets.axisList[i];
      final title = axis.title;
      final titleWidget = CustomSingleChildLayout(
        delegate: AxisTitleLayoutDelegate(
          index: i,
          amount: amount,
          suggestPadding: suggestPadding,
        ),
        child: tapEnable ? InkWell(
          onTap: () {
            dataSets.onTapAxisTitle!(axis, i);
          },
          child: Text(title, style: style,),
        ) : Text(title, style: style,),
      );
      titleWidgets.add(titleWidget);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: RadarPainter(
            dataSets: dataSets,
          ),
        ),
        if (dataSets.onTapPolygonPoint != null)
          GestureDetector(
            onTapUp: (TapUpDetails details) {
              onTapPosition(details.localPosition);
            },
          ),
        Stack(
          /// 不能放在外层stack中，否者会导致CustomSingleChildLayout的child和Stack一样大，那么child的可点击区域就和Stack一样大
          children: titleWidgets,
        ),
      ],
    );
  }
}
/// 计算文本所占大小
Size boundingTextSize(BuildContext context,
    String? text,
    TextStyle style,
    {double maxWidth = double.infinity}) {
  if (text == null || text.isEmpty) {
    return Size.zero;
  }
  final TextPainter textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    locale: Localizations.localeOf(context),
    text: TextSpan(text: text, style: style),
  )..layout(maxWidth: maxWidth);
  return textPainter.size;
}
///
class AxisTitleLayoutDelegate extends SingleChildLayoutDelegate {
  int index;
  int amount;
  double suggestPadding;

  AxisTitleLayoutDelegate({
    required this.index,
    required this.amount,
    required this.suggestPadding,
  });

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final offset =  Offset(size.width * 0.5, size.height * 0.5);
    final perAngle = 360.0 / amount.toDouble();
    /// 总长度
    final radius = min(size.width, size.height) * 0.5 - suggestPadding;
    /// 轴结束点
    final end = toRectangularPoint(radius, index * perAngle, offset);
    final realSize = childSize;
    if (index == 0) {
      final dx = end.dx - realSize.width * 0.5;
      final dy = end.dy - realSize.height;
      return Offset(dx, dy);
    } else if (amount%2 == 0 && index == amount/2) {
      final dx = end.dx - realSize.width * 0.5;
      final dy = end.dy + 2;
      return Offset(dx, dy);
    } else if (index < amount / 2.0) {
      final dx = end.dx - realSize.width - 7;
      final dy = end.dy - realSize.height * 0.5;
      return Offset(dx, dy);
    } else if (index > amount / 2.0) {
      final dx = end.dx + 7;
      final dy = end.dy - realSize.height * 0.5;
      return Offset(dx, dy);
    } else {
      return end;
    }
  }
}
/// 将titleWidgets放于外层stack时可用次类，仅用于展示文本
// class AxisTitleLayoutDelegate extends SingleChildLayoutDelegate {
//   int index;
//   int amount;
//   double suggestPadding;
//   Size size;
//
//   AxisTitleLayoutDelegate({
//     required this.index,
//     required this.amount,
//     required this.suggestPadding,
//     required this.size,
//   });
//
//   @override
//   bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
//     return true;
//   }
//
//   @override
//   Size getSize(BoxConstraints constraints) {
//     return size;
//   }
//
//   @override
//   Offset getPositionForChild(Size size, Size childSize) {
//     final offset =  Offset(size.width * 0.5, size.height * 0.5);
//     final perAngle = 360.0 / amount.toDouble();
//     /// 总长度
//     final radius = min(size.width, size.height) * 0.5 - suggestPadding;
//     /// 轴结束点
//     final end = toRectangularPoint(radius, index * perAngle, offset);
//     final realSize = this.size;
//     if (index == 0) {
//       final dx = end.dx - realSize.width * 0.5;
//       final dy = end.dy - realSize.height;
//       return Offset(dx, dy);
//     } else if (amount%2 == 0 && index == amount/2) {
//       final dx = end.dx - realSize.width * 0.5;
//       final dy = end.dy + 2;
//       return Offset(dx, dy);
//     } else if (index < amount / 2.0) {
//       final dx = end.dx - realSize.width - 7;
//       final dy = end.dy - realSize.height * 0.5;
//       return Offset(dx, dy);
//     } else if (index > amount / 2.0) {
//       final dx = end.dx + 7;
//       final dy = end.dy - realSize.height * 0.5;
//       return Offset(dx, dy);
//     } else {
//       return end;
//     }
//   }
// }

/// 将极坐标转换为直角坐标
/// 以Canvas中直角坐标系的-y轴为极坐标的+x轴，逆时针方向为量化角度的正方向
/// +offset将转换后的点的中心移动至画板的中心
Offset toRectangularPoint(double length, double angle, Offset offset) {
  final radian = angle / 180.0 * pi;
  final x = 0 - length * sin(radian);
  final y = 0 - length * cos(radian);
  return Offset(x + offset.dx, y + offset.dy);
}
/// 将直角坐标转换为极坐标
/// 以Canvas中直角坐标系的-y轴为极坐标的+x轴，逆时针方向为量化角度的正方向
/// -offset是为将直角坐标的原点移动至画板的左上角（于极坐标的原点重合）
double toAngle(Offset point, Offset offset) {
  final x = point.dx - offset.dx;
  final y = point.dy - offset.dy;
  var radian = atan2(y, x);
  final angle = radian * 180.0 / pi;
  var revisedAngle = 360.0 - 90.0 - angle;
  if (revisedAngle >= 360.0) {
    revisedAngle -= 360.0;
  }
  return revisedAngle;
}

class RadarPainter extends CustomPainter {
  RadarDataSets dataSets;
  RadarPainter({
    required this.dataSets,
  });

  Paint get cuttingLinePaint {
    return Paint()
      ..color = dataSets.cuttingStyle.color
      ..strokeWidth = dataSets.cuttingStyle.width
      ..style = PaintingStyle.stroke
    ;
  }

  Paint get equidistantLinePaint {
    return Paint()
      ..color = dataSets.equidistantStyle.color
      ..strokeWidth = dataSets.equidistantStyle.width
      ..style = PaintingStyle.stroke
    ;
  }

  Paint get polygonLinePaint {
    return Paint()
      ..strokeWidth = dataSets.polygonStyle.lineWidth
      ..style = PaintingStyle.stroke
    ;
  }

  Paint get polygonPointPaint {
    return Paint()
      ..style = PaintingStyle.fill
    ;
  }

  @override
  void paint(Canvas canvas, Size size) {
    dataSets.setSize(size);
    final offset =  Offset(size.width * 0.5, size.height * 0.5);
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final padding = dataSets.suggestPadding;
    /// 总长度
    final radius = min(size.width, size.height) * 0.5 - padding;
    final axisAmount = dataSets.axisList.length;
    if (axisAmount == 0) {
      return;
    }
    final perAngle = 360.0 / axisAmount.toDouble();
    /// 画扇形分割线
    final clPen = cuttingLinePaint;
    for (int i = 0; i < axisAmount; i ++) {
      final end = toRectangularPoint(radius, perAngle * i, offset);
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(end.dx, end.dy);
      canvas.drawPath(path, clPen);
    }
    /// 画等距分割线
    final elPen = equidistantLinePaint;
    for (int i = 0; i < dataSets.equidistantStyle.amount; i ++) {
      final perRadius = radius / dataSets.equidistantStyle.amount.toDouble();
      final iRadius = perRadius * (i + 1);
      final path = Path();
      for (int j = 0; j < axisAmount; j ++) {
        final p = toRectangularPoint(iRadius, j * perAngle, offset);
        if (j == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
          if (j == axisAmount - 1) {
            path.close();
          }
        }
      }
      canvas.drawPath(path, elPen);
    }
    /// 画多边形
    bool filling = false; /// 填充min，max一次就行
    for (int i = 0; i < dataSets.polygonList.length; i ++) {
      PolygonDataSets polygon = dataSets.polygonList[i];
      if (polygon.hidden) {
        continue;
      }
      final polygonPoints = <Offset>[];
      final path = Path();
      for (int j = 0; j < dataSets.axisList.length; j ++) {
        Axis axis = dataSets.axisList[j];
        if (!filling && (axis.min == null || axis.max == null)) {
          fillMinAndMaxForAxis(axis, atIndex: j);
        }
        Offset lineI_PointJ = center;
        if (j >= polygon.valueList.length) {/// 补足该点
          /// 第j个点在原点
        } else if (axis.min == null || axis.max == null) {/// 填充axis的min和max后，仍可能为空。
          /// 第j个点在原点
        } else if (axis.min! >= axis.max!) {/// 通常是min==max的非正常情况
          /// 第j个点在轴的最远端
          lineI_PointJ = toRectangularPoint(radius, j * perAngle, offset);
        } else {
          final range = axis.max! - axis.min!;
          final value = polygon.valueList[j];
          final percent = (value - axis.min!) / range;
          var convertRadius = percent * radius;
          lineI_PointJ = toRectangularPoint(convertRadius, j * perAngle, offset);
        }
        if (j == 0) {
          path.moveTo(lineI_PointJ.dx, lineI_PointJ.dy);
          polygonPoints.add(lineI_PointJ);
        } else {
          path.lineTo(lineI_PointJ.dx, lineI_PointJ.dy);
          polygonPoints.add(lineI_PointJ);
        }
        canvas.drawCircle(lineI_PointJ, dataSets.polygonStyle.joinRadius, polygonPointPaint..color = polygon.color);
      }
      path.close();
      canvas.drawPath(path, polygonLinePaint..color = polygon.color);
      polygon.points = polygonPoints;
      polygon.path = path;
      /// 正常走完一个流程后，所有轴上的min和max都尝试填充过了
      filling = true;
    }
  }

  void fillMinAndMaxForAxis(Axis axis, {required int atIndex}) {
    double? min, max;
    for (int i = 0; i < dataSets.polygonList.length; i ++) {
      PolygonDataSets polygon = dataSets.polygonList[i];
      if (atIndex < polygon.valueList.length) {
        final valueAtIndex = polygon.valueList[atIndex];
        if (min == null || valueAtIndex < min) {
          min = valueAtIndex;
        }
        if (max == null || valueAtIndex > max) {
          max = valueAtIndex;
        }
      }
    }
    if (min != null) {
      if (axis.min == null || min < axis.min!) {
        axis.min = min;
      }
    }
    if (max != null) {
      if (axis.max == null || max > axis.max!) {
        axis.max = max;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}