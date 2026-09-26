import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/theme/app_theme.dart';
import 'package:plant_garden/theme/floraqua_palette.dart';

void main() {
  test('светлая и тёмная темы содержат свои semantic palette', () {
    final lightTheme = buildAppTheme(brightness: Brightness.light);
    final darkTheme = buildAppTheme(brightness: Brightness.dark);
    final lightPalette = lightTheme.extension<FloraquaPalette>();
    final darkPalette = darkTheme.extension<FloraquaPalette>();

    expect(lightTheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
    expect(lightPalette, isNotNull);
    expect(darkPalette, isNotNull);
    expect(lightPalette!.background, isNot(darkPalette!.background));
    expect(lightPalette.textPrimary, isNot(darkPalette.textPrimary));
  });
}
