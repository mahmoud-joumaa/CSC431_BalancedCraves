import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import "package:balancedcraves/config.dart";

// Authentication =================================================================================
final Authentication _auth = Authentication();
// Database =======================================================================================
final Database _db = Database();

// User input =====================================================================================
final TextEditingController loginEmailController = TextEditingController();
final TextEditingController loginPasswordController = TextEditingController();
final TextEditingController signUpUsernameController = TextEditingController();
final TextEditingController signUpEmailController = TextEditingController();
final TextEditingController signUpPasswordController = TextEditingController();
final TextEditingController signUpConfirmPasswordController = TextEditingController();
final loginEmail = InputField(type: "email", controller: loginEmailController);
final loginPassword = InputField(type: "password", controller: loginPasswordController);
final signUpUsername = InputField(type: "username", controller: signUpUsernameController);
final signUpEmail = InputField(type: "email", controller: signUpEmailController);
final signUpPassword = InputField(type: "password", controller: signUpPasswordController);
final signUpConfirmPassword = InputField(type: "confirm password", controller: signUpConfirmPasswordController);
clearInputs() {
  loginEmailController.clear();
  loginPasswordController.clear();
  signUpUsernameController.clear();
  signUpEmailController.clear();
  signUpPasswordController.clear();
  signUpConfirmPasswordController.clear();
}

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {

  // Toggle between the two forms
  static bool isLogin = true;

  @override
  void initState() {
    super.initState();
    _auth.signOut();
    isLogin = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Title Header
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10.0, 35.0, 10.0, 5.0),
                color: const Color(Palette.grey).withOpacity(0.30),
                child: Column(
                  children: [
                    Image.asset("assets/logo.png", height: 65.0, width: 65.0),
                    const Text(
                      "Balanced Craves",
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text("The app that helps you balance your craves!",
                      style: TextStyle(
                        fontSize: 15.0,
                      )
                    ),
                  ],
                ),
              ),
            ),
            // Login & Signup Bookmarks
            Positioned(
              top: 200,
              right: 0,
              child: generateBookmark("Login"),
            ),
            Positioned(
              top: 350,
              right: 0,
              child: generateBookmark("Signup"),
            ),
            // Inputs & Submission Buttons
            Positioned(
              top: 200,
              bottom: 25,
              left: 15,
              right: 150,
              child: AnimatedSwitcher( // TODO: Add transition (other than fade)
                duration: const Duration(seconds: 0),
                child: generateInputs(),
              ),
            )
          ],
        ),
      ),
    );
  }

  generateBookmark(String title) {
    return GestureDetector(
      onTap: () {setState(() {isLogin = title=="Login"?true:false;});},
      child: Stack(
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Icon(
              Icons.bookmark,
              color: title=="Login" ? const Color(Palette.blue) : title=="Signup" ? const Color(Palette.orange) : null,
              size: 200,
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: (isLogin && title=="Login") || (!isLogin && title=="Signup") ? const BorderSide(color: Color(Palette.black), width: 3.5) : BorderSide.none,
                  ),
                ),
                child: Text(title,
                  style: TextStyle(
                    color: const Color(Palette.black),
                    fontSize: (isLogin && title=="Login") || (!isLogin && title=="Signup") ? 25.0 : 20.0,
                    fontWeight: (isLogin && title=="Login") || (!isLogin && title=="Signup") ? FontWeight.bold : FontWeight.normal,
                  )
                )
              )
            ),
          ),
        ],
      ),
    );
  }

  generateInputs() { // TODO: Add form validation logic
    return ClipRect(
      key: Key(isLogin ? "Login" : "Signup"),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isLogin ? const Color(Palette.blue).withOpacity(0.5) : const Color(Palette.orange).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  children: isLogin ?
                    [
                      loginEmail,
                      loginPassword,
                    ] :
                    [
                      signUpUsername,
                      signUpEmail,
                      signUpPassword,
                      signUpConfirmPassword,
                    ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: isLogin ?
                [
                  const SubmitButton(type: "login", text: "Login with Username"),
                  // const SizedBox(height: 10.0),
                  // const SubmitButton(type: "google", text: "Login with Google"),
                ] :
                [
                  const SubmitButton(type: "signup", text: "Signup with Email"),
                  // const SizedBox(height: 10.0),
                  // const SubmitButton(type: "google", text: "Login with Google"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}

class InputField extends StatefulWidget {

  final String? type;
  final TextEditingController? controller;

  const InputField({super.key, this.type, this.controller});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        prefixIcon: widget.type=="username" ? const Icon(Icons.account_circle_outlined) :
                    widget.type=="email" ? const Icon(Icons.email_outlined) :
                    widget.type=="password" || widget.type=="confirm password" ? const Icon(Icons.lock_outline) :
                    null,
        prefixIconColor: const Color(Palette.black),
        suffixIcon: widget.type=="password" || widget.type=="confirm password" ? IconButton(icon: _hidePassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off), onPressed: () {setState(() {_hidePassword = !_hidePassword;});}) : null,
        suffixIconColor: const Color(Palette.black),
        labelText: widget.type!.substring(0,1).toUpperCase()+widget.type!.substring(1),
        labelStyle: TextStyle(color: const Color(Palette.black).withOpacity(0.5)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(Palette.black))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(Palette.black), width: 2.0)),
      ),
      keyboardType: widget.type=="email"?TextInputType.emailAddress:TextInputType.text,
      style: const TextStyle(color: Color(Palette.black)),
      cursorColor: const Color(Palette.black),
      obscureText: widget.type=="password"||widget.type=="confirm password"?_hidePassword:false,
      obscuringCharacter: '*',
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}

class SubmitButton extends StatefulWidget {

  final String? text;
  final String? type;

  const SubmitButton({super.key, this.text, this.type});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {isLoading = true;});
        if (widget.type != "google") {
          // User Sign Up
          if (!_WelcomeState.isLogin) {
            dynamic result = await _auth.registerWithEmailAndPassword(signUpEmailController.text, signUpPasswordController.text);
            // Validate password
            if (signUpPasswordController.text != signUpConfirmPasswordController.text) {
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("An error has occurred"),
                  content: const Text("Passwords don't match"),
                  backgroundColor: UserTheme.isDark ? Colors.redAccent[700] : Colors.redAccent[100],
                ),
              );
            }
            // No error
            else if (result is AppUser) {
              await _db.addUser(result.uid, username: signUpUsernameController.text, isDark: UserTheme.isDark);
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("${signUpUsernameController.text} created successfully"),
                  backgroundColor: UserTheme.isDark ? Colors.greenAccent[700] : Colors.greenAccent[100],
                  actions: [
                    TextButton(
                      onPressed: () async {
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, "HomeScreen", arguments: await _db.getUser(result.uid));
                      },
                      style: ButtonStyle(
                        backgroundColor: UserTheme.isDark ? MaterialStateProperty.all<Color>(Colors.greenAccent[100]!) : MaterialStateProperty.all<Color>(Colors.greenAccent[700]!),
                        foregroundColor: UserTheme.isDark ? MaterialStateProperty.all<Color>(const Color(Palette.black)) : MaterialStateProperty.all<Color>(const Color(Palette.white)),
                      ),
                      child: const Text("Login"),
                    ),
                  ],
                )
              );
            }
            // Error
            else {
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("An error has occurred"),
                  content: Text(result.toString()),
                  backgroundColor: UserTheme.isDark ? Colors.redAccent[700] : Colors.redAccent[100],
                ),
              );
            }
          }
          // User login
          else {
            dynamic result = await _auth.logInWithEmailAndPassword(loginEmailController.text, loginPasswordController.text);
            // No error
            if (result is AppUser) {
              final user = await _db.getUser(result.uid);
              UserTheme.isDark = user.isDark;
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, "HomeScreen", arguments: user);
            }
            // Error
            else {
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text("An error has occurred"),
                  content: Text(result.toString()),
                  backgroundColor: UserTheme.isDark ? Colors.redAccent[700] : Colors.redAccent[100],
                ),
              );
            }
          }
        }
        else {
          // TODO: Sign in with Google
        }
        setState(() {isLoading = false;});
        await Future.delayed(const Duration(milliseconds: 500), clearInputs);
      },
      style: ButtonStyle(
        backgroundColor: UserTheme.isDark ? MaterialStateProperty.all<Color>(const Color(Palette.black)) : MaterialStateProperty.all<Color>(const Color(Palette.white)),
        foregroundColor: UserTheme.isDark ? MaterialStateProperty.all<Color>(const Color(Palette.white)) : MaterialStateProperty.all<Color>(const Color(Palette.black)),
      ),
      child: Row(
        children: [
          Icon(widget.type=="google"?MdiIcons.google:widget.type=="login"?Icons.login:widget.type=="signup"?Icons.login:null,
          ),
          Expanded(
            child: isLoading ? Loading(color: UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black), backgroundColor: Colors.transparent, size: 20.0) : Text(widget.text!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.0,
              )
            ),
          ),
        ],
      ),
    );
  }
}
