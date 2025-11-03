import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.primaryAction,
    required this.secondaryButton,
    required this.success,
    required this.successTrack,
    required this.successBorder,
  });

  final Color primaryAction;
  final Color secondaryButton;

  final Color success;
  final Color successTrack;
  final Color successBorder;

  @override
  CustomColors copyWith({
    Color? primaryAction,
    Color? secondaryButton,
    Color? success,
    Color? successTrack,
    Color? successBorder,
  }) {
    return CustomColors(
      primaryAction: primaryAction ?? this.primaryAction,
      secondaryButton: secondaryButton ?? this.secondaryButton,
      success: success ?? this.success,
      successTrack: successTrack ?? this.successTrack,
      successBorder: successBorder ?? this.successBorder,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      secondaryButton: Color.lerp(secondaryButton, other.secondaryButton, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTrack: Color.lerp(successTrack, other.successTrack, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
    );
  }
}
