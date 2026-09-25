import 'package:flutter/material.dart';

/// Centralized subtle, diffused shadow elevations.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glowCyan = [
    BoxShadow(
      color: Color(0x3300E5FF),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glowVolt = [
    BoxShadow(
      color: Color(0x3300F0A8),
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardElevation = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
}
