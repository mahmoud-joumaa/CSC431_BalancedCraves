import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "package:balancedcraves/config.dart";
import 'package:balancedcraves/Screens/splash.dart';
import 'package:balancedcraves/Screens/welcome.dart';
import 'package:balancedcraves/Screens/home.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  UserTheme.isDark = (WidgetsBinding.instance.platformDispatcher.platformBrightness==Brightness.dark);

  runApp(ChangeNotifierProvider<UserTheme>(
    create: (context) => UserTheme(),
    child: const Root(),
  ));

}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<UserTheme>(context,listen: false).toggleTheme(UserTheme.isDark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: Provider.of<UserTheme>(context).isDarkNotify ? ThemeMode.dark : ThemeMode.light,
      // initialRoute: "SplashScreen",
      initialRoute: "SplashScreen",
      routes: {
        "SplashScreen": (context) => const Splash(),
        "WelcomeScreen": (context) => const Welcome(),
        "HomeScreen": (context) => const Home(),
      }
    );
  }

}
