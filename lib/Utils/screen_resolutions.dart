import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height - MediaQuery.of(this).padding.top - MediaQuery.of(this).padding.bottom;
}