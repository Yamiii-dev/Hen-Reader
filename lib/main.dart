import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:system_theme/system_theme.dart';

import "pages/results.dart";

void main() async {
  fvp.registerWith();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: SystemTheme.accentColor.accent),
      ),
      darkTheme: ThemeData(
        colorScheme: .fromSeed(seedColor: SystemTheme.accentColor.accent, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: ResultsPage()
    );
  }
}
