import 'package:flutter/material.dart';
/// 等距分割线样式
class EquidistantLineStyle {
  final int amount;
  final double width;
  final Color color;

  const EquidistantLineStyle({
    this.amount = 5,
    this.width = 1,
    this.color = Colors.grey,
  });
}