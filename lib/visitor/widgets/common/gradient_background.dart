import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [AppColors.gradientPrimary, AppColors.gradientSecondary],
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}