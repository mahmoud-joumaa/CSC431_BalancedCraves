import 'package:flutter/material.dart';
// import 'package:page_transition/page_transition.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:balancedcraves/firebase_options.dart';

import "package:balancedcraves/config.dart";
// import "package:balancedcraves/Screens/welcome.dart";

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    setUpFirebase();
  }

  void setUpFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Future.delayed(Duration(seconds: 1), () {Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.fade, duration: Duration(seconds: 3), child: Welcome()));});
    Future.delayed(const Duration(seconds: 2), () {Navigator.pushReplacementNamed(context, "WelcomeScreen");});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(Palette.red), Color(Palette.white), Color(Palette.orange)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Image.asset("assets/logo.png",
            height: 250.0,
            width: 250.0,
          ),
        ),
      )
    );
  }

}
