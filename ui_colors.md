# App Theme Configuration

This file defines the core color palette and implementation guide for theming the Flutter application.

## 🎨 Color Palette

| Name         | Hex Code   | Usage                          |
|--------------|------------|--------------------------------|
| Mine Shaft   | `#262626`  | Backgrounds, text, app bar     |
| White        | `#FFFFFF`  | Main background, text          |
| Blue Accent  | `#3D95CE`  | Primary buttons, highlights    |

## 🌐 Flutter Theme Setup

Use the following `ThemeData` configuration inside your `MaterialApp`:

```dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Color(0xFFFFFFFF), // White background
  primaryColor: Color(0xFF3D95CE),            // Blue accent
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3D95CE),
    primary: Color(0xFF3D95CE),
    secondary: Color(0xFF262626),             // Mine Shaft
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onPrimary: Color(0xFFFFFFFF),             // Text on primary (blue)
    onSecondary: Color(0xFFFFFFFF),           // Text on Mine Shaft
    onBackground: Color(0xFF262626),          // Text on white
    onSurface: Color(0xFF262626),
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF262626),       // Dark header
    foregroundColor: Color(0xFFFFFFFF),       // White text
  ),
);
