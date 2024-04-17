import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import 'package:balancedcraves/config.dart';
import 'package:balancedcraves/Screens/UserScreens/profile.dart';
import 'package:balancedcraves/Screens/UserScreens/recipes.dart';
import 'package:balancedcraves/Screens/UserScreens/tracker.dart';
import 'package:balancedcraves/Screens/about.dart';

AppUser? _user;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  MenuItem currentItem = Menu.menuItems[0];
  @override
  Widget build(BuildContext context) {

    _user = ModalRoute.of(context)?.settings.arguments as AppUser;

    return ZoomDrawer(
      style: DrawerStyle.defaultStyle,
      disableDragGesture: currentItem.title=="Logout",
      mainScreenScale: 0.15,
      menuScreen: Builder(
        builder: (context) {
          return Menu(
            currentItem: currentItem,
            onSelectedItem: (menuItem) async {
              setState(() {currentItem = menuItem;});
              if (currentItem.title=="Logout") { ZoomDrawer.of(context)!.close(); }
              else { await Future.delayed(const Duration(milliseconds: 800), () {ZoomDrawer.of(context)!.close();}); }
            },
          );
        }
      ),
      mainScreen: getScreen(),
    );
  }

  getScreen() {
    switch (currentItem.title) {
      case "Profile": return Profile(user: _user);
      case "Recipes": return Recipes(user: _user);
      case "Tracker": return Tracker(user: _user);
      case "About": return const About();
      case "Logout":
        Future.delayed(const Duration(seconds: 1), () {Navigator.pushReplacementNamed(context, "WelcomeScreen");});
        return Loading(
          backgroundColor: UserTheme.isDark ? const Color(Palette.black) : const Color(Palette.white),
          color: const Color(Palette.orange),
        );
    }
  }

}

class MenuItem {
  final String? title;
  final IconData? icon;
  const MenuItem({this.title, this.icon});
}

class Menu extends StatelessWidget {

  final MenuItem? currentItem;
  final ValueChanged<MenuItem>? onSelectedItem;

  static const menuItems = [
    MenuItem(title: "Profile", icon: Icons.person),             // 0
    MenuItem(title: "Recipes", icon: Icons.restaurant_menu),    // 1
    MenuItem(title: "Tracker", icon: Icons.track_changes),      // 2
    MenuItem(title: "About", icon: Icons.info),                 // 3
    MenuItem(title: "Logout", icon: Icons.logout),              // 4
  ];

  const Menu({super.key, this.currentItem, this.onSelectedItem});

  @override
  Widget build(BuildContext context) {
    final BorderSide border = BorderSide(width: 2.0, color: UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black));
    return Scaffold(
      backgroundColor: UserTheme.isDark ? const Color(Palette.black) : const Color(Palette.white),
      body: Container(
        decoration: BoxDecoration(
          border: Border(right: border, bottom: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...Menu.menuItems.map((menuItem) => renderMenuItem(menuItem))
          ]
        ),
      ),
    );
  }

  Widget renderMenuItem(MenuItem item) {
    ListTile menuItem = ListTile(
      // Default ListTile
      onTap: () {onSelectedItem!(item);},
      leading: Icon(item.icon!),
      // Light vs Dark Theme (Default)
      iconColor: UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black),
      title: Text(item.title!, style: const TextStyle(fontSize: 16.0)),
      textColor: UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black),
      // Light vs Dark Theme (Selection based on entity)
      selected: item == currentItem,
      selectedColor: !UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black),
      selectedTileColor: UserTheme.isDark ? currentItem!.title=="Profile" ? Colors.blue[400] :
                                            currentItem!.title=="Recipes" ? Colors.red[400] :
                                            currentItem!.title=="Tracker" ? Colors.green[400] :
                                            currentItem!.title=="About"   ? Colors.deepPurple[400] :
                                                                            Colors.amber[400] :
                                            currentItem!.title=="Profile" ? Colors.blue[800] :
                                            currentItem!.title=="Recipes" ? Colors.red[800] :
                                            currentItem!.title=="Tracker" ? Colors.green[800] :
                                            currentItem!.title=="About"   ? Colors.deepPurple[800] :
                                                                            Colors.amber[800],
    );
    if (item.title == "About") return Padding(padding: const EdgeInsets.only(top: 65.0), child: menuItem);
    return menuItem;
  }

}

class HomeAppBar extends StatelessWidget {

  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  static AppBar homeAppBar(BuildContext context, String title, Color bgColor) {
    return AppBar(
      title: Text(title, style: TextStyle(color: UserTheme.isDark?const Color(Palette.white):const Color(Palette.black))),
      centerTitle: true,
      backgroundColor: bgColor,
      leading: IconButton(
        onPressed: () {ZoomDrawer.of(context)!.toggle();},
        icon: Icon(Icons.menu, color: UserTheme.isDark?const Color(Palette.white):const Color(Palette.black)),
      ),
    );
  }

}
