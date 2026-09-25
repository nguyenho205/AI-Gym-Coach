import 'package:flutter/material.dart';

/// Centralized border radius tokens with mathematical concentric curves.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double full = 999.0;

  // Concentric Curves for Double-Bezel Card Technique
  static const double outerCard = 22.0;
  static const double innerCard = 16.0;

  // BorderRadius objects
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius roundedFull = BorderRadius.all(Radius.circular(full));
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(outerCard));
  static const BorderRadius roundedInner = BorderRadius.all(Radius.circular(innerCard));
}
