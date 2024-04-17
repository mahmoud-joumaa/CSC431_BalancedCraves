import 'package:flutter/material.dart';

import 'package:balancedcraves/config.dart';
import 'package:balancedcraves/Screens/home.dart';

class Tracker extends StatelessWidget {

  final AppUser? user;

  const Tracker({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar.homeAppBar(context, "Tracker", (UserTheme.isDark ? Colors.green[900]! : Colors.green[400]!)),
    );
  }
}
