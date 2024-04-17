import 'package:flutter/material.dart';
import "package:curved_navigation_bar/curved_navigation_bar.dart";
import "package:provider/provider.dart";
// import "package:pie_chart/pie_chart.dart";

import "package:balancedcraves/config.dart";
import "package:balancedcraves/Screens/home.dart";

// Authentication =================================================================================
Authentication _auth = Authentication();
// Database =======================================================================================
Database _db = Database();

class Profile extends StatefulWidget {

  final AppUser? user;

  const Profile({super.key, this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  // Keep track of my current location
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {

    dynamic user = widget.user;

    return Scaffold(
      backgroundColor: UserTheme.isDark ? Colors.grey[850] : Colors.grey[350],
      appBar: HomeAppBar.homeAppBar(context, "Profile", (UserTheme.isDark ? Colors.blue[900]! : Colors.blue[400]!)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {setState(() {_currentIndex = index;});},
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController controller = TextEditingController(text: user.profileImg);
                            return AlertDialog(
                              title: const Text("Enter URL of new image"),
                              content: TextField(
                                controller: controller,
                              ),
                              actions: [
                                IconButton(
                                  onPressed: () {
                                    user.profileImg = controller.text;
                                    _db.updateUser(user);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.edit)
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(user.profileImg),
                        backgroundColor: UserTheme.isDark ? const Color(Palette.black) : const Color(Palette.white),
                        radius: 60.0,
                      ),
                    ),
                    Text("Welcome,\n${user.username}",
                      style: const TextStyle(
                        fontSize: 50.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Light", style: TextStyle(fontSize: 35.0)),
                    const SizedBox(width: 15.0),
                    Switch(
                      value: UserTheme.isDark,
                      onChanged: (val) {
                        Provider.of<UserTheme>(context, listen: false).toggleTheme(val);
                        user.isDark = UserTheme.isDark;
                        _db.updateUser(user);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                children: [
                                  Icon(UserTheme.isDark?Icons.dark_mode:Icons.light_mode),
                                  const SizedBox(width: 10.0),
                                  Text("Applied ${UserTheme.isDark?'Dark':'Light'} Theme"),
                                ]
                              ),
                            );
                          },
                        );
                      }
                    ),
                    const SizedBox(width: 15.0),
                    const Text("Dark", style: TextStyle(fontSize: 35.0)),
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red[600]!),
                          foregroundColor: UserTheme.isDark ? MaterialStateProperty.all<Color>(const Color(Palette.white)) : MaterialStateProperty.all<Color>(const Color(Palette.black)),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Are you sure you want to delete your acccount?"),
                                actionsAlignment: MainAxisAlignment.spaceAround,
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      await _db.deleteUser(user);
                                      await _auth.deleteUser();
                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pop();
                                      // ignore: use_build_context_synchronously
                                      Navigator.pushReplacementNamed(context, "WelcomeScreen");
                                    },
                                    child: const Text("Confirm"),
                                  ),
                                  TextButton(
                                    onPressed: () {Navigator.of(context).pop();},
                                    child: const Text("Cancel"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Delete Account"),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // PieChart(
                //   dataMap: {
                //     "Breakfast": ,
                //     "Lunch": ,
                //     "Dinner": ,
                //     "Snack": ,
                //   },
                // ),
                Text("Diets"),
              ]
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: UserTheme.isDark ? Colors.grey[850]! : Colors.grey[350]!,
        color: Colors.blue[600]!,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.settings),
          Icon(Icons.straighten)
        ],
        onTap: (index) {_pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);}
      ),
    );
  }
}
