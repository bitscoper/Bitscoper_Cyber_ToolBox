/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';

import 'package:bitscoper_cyber_toolbox/home_page.dart';

void main() {
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(false);
  bool userToggledTheme = false;

  void toggleTheme() {
    setState(
      () {
        userToggledTheme = true;
        isDarkTheme.value = !isDarkTheme.value;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final brightness = MediaQuery.of(context).platformBrightness;

    if (!userToggledTheme) {
      isDarkTheme.value = brightness == Brightness.dark;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTheme,
      builder: (
        context,
        isDark,
        child,
      ) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(
            toggleTheme: toggleTheme,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
