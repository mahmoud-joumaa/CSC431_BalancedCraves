import 'package:flutter/material.dart';
import "package:flutter_spinkit/flutter_spinkit.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Palette { // (Based off of the logo.png)

  static const int white = 0xFFEAEAEA;
  static const int black = 0xFF040404;
  static const int red = 0xFFEB2C3B;
  static const int darkred = 0xFF931C24;
  static const int orange = 0xFFF6AD3F;
  static const int blue = 0xFF049BF3;
  static const int green = 0xFF04A233;
  static const int grey = 0xFF818180;

}

class UserTheme extends ChangeNotifier {
  static bool isDark = false;
  bool isDarkNotify = isDark;
  toggleTheme(bool flag) {
    isDark = flag;
    isDarkNotify = flag;
    return notifyListeners();
  }
}

class Loading extends StatelessWidget {

  final Color? backgroundColor;
  final Color? color;
  final double? size;

  const Loading({super.key, this.backgroundColor, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? (UserTheme.isDark ? const Color(Palette.black) : const Color(Palette.orange)),
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: SpinKitFadingCircle(
          color: color ?? (UserTheme.isDark ? const Color(Palette.orange) : const Color(Palette.black)),
          size: size ?? 50.0,
        ),
      ),
    );
  }
}

/* ================================================================================================
User
================================================================================================ */

class AppUser {

  final String? uid;
  String? username;
  bool? isDark;
  String? profileImg;
  List<dynamic>? diets;
  List<dynamic>? recipes;

  AppUser({ this.uid, this.username, this.isDark, this.profileImg, this.diets, this.recipes });

}

class Diet {

  final double? calories;
  final double? carbs;
  final double? proteins;
  final double? fats;

  const Diet({ this.calories, this.carbs, this.proteins, this.fats});

}

class Recipe {
  String? title;
  String? description;
  String? imgURL;
  String? category;
  bool? isPublic;
  bool? isFav;
  // Per 100g
  double? calories;
  double? carbs;
  double? proteins;
  double? fats;
  // Dates to track
  List<dynamic>? dates;

  Recipe({this.title, this.description, this.imgURL, this.category, this.calories, this.carbs, this.proteins, this.fats, this.dates, this.isPublic, this.isFav});

  toMap() {
    return {
      "title": title!.isEmpty?"New Recipe":title,
      "description": description!.isEmpty?"Description sample":description,
      "imgURL": imgURL!.isEmpty?"https://media.istockphoto.com/id/1457433817/photo/group-of-healthy-food-for-flexitarian-diet.jpg?b=1&s=612x612&w=0&k=20&c=V8oaDpP3mx6rUpRfrt2L9mZCD0_ySlnI7cd4nkgGAb8=":imgURL,
      "category": category,
      "calories": calories,
      "carbs": carbs,
      "proteins": proteins,
      "fats": fats,
      "dates": dates,
      "isPublic": isPublic,
      "isFav": isFav,
    };
  }
}

/* ================================================================================================
Firebase Authentication
================================================================================================ */

class Authentication {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register w/ Email & Password
  registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return AppUser(uid: result.user!.uid);
    }
    catch (error) { return error; }
  }

  // Login w/ Email & Pass
  logInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AppUser(uid: result.user!.uid);
    }
    catch (error) { return error; }
  }

  // Login w/ Google

  // Sign out
  signOut() async {
    try {
      return await _auth.signOut();
    }
    catch (error) { return error; }
  }

  // Delete user
  deleteUser() async {
    FirebaseAuth.instance.currentUser!.delete();
  }

}

/* ================================================================================================
Firebase Firestore
================================================================================================ */

class Database {

  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection("Users");

  // Snapshot of the entire collection
  getUsers() {
    try { return _usersCollection.snapshots(); }
    catch (error) { return error; }
  }

  // One-time read of user data & return AppUsers (given uid)
  getUser(String? uid) async {
    try {
      final userData = await _usersCollection.doc(uid).get();
      return AppUser(uid: uid, username: userData["username"], profileImg: userData["profileImg"], isDark: userData["isDark"], diets: userData["diets"], recipes: userData["recipes"]);
    }
    catch (error) { return error; }
  }

  // Add a new user into Firebase Firestore w/ the default configurations
  addUser(String? uid, {String? username, bool? isDark}) async {
    try {
      return await _usersCollection.doc(uid).set({
        "username": username,
        "profileImg": "https://p7.hiclipart.com/preview/8/1006/572/emoji-smiley-happiness-iphone-emoticon-emoji.jpg",
        "isDark": isDark,
        "diets": [],
        "recipes": [],
      });
    }
    catch (error) { return error; }
  }

  // Update user attributes
  updateUser(AppUser user) async {
    try {
      return await _usersCollection.doc(user.uid).set({
        "username": user.username,
        "profileImg": user.profileImg,
        "isDark": user.isDark,
        "diets": user.diets,
        "recipes": user.recipes,
      });
    }
    catch (error) { return error; }
  }

  // Delete user from database
  deleteUser(AppUser user) async {
    try {
      return await _usersCollection.doc(user.uid).delete();
    }
    catch (error) { return error; }
  }

  // Get recipes
  getRecipes(AppUser user) {
    try {
      return _usersCollection.doc(user.uid).collection("Recipes");
    }
    catch (error) { return error; }
  }

  // Add recipe
  addRecipe(AppUser user, Recipe recipe) async {
    try {
      return await _usersCollection.doc(user.uid).collection("Recipes").add(recipe.toMap());
    }
    catch (error) { return error; }
  }
  // Set recipe
  setRecipe(AppUser user, Recipe recipe, String recipeId) async {
    try {
      return await _usersCollection.doc(user.uid).collection("Recipes").doc(recipeId).set(recipe.toMap());
    }
    catch (error) { return error; }
  }

  // Delete
  deleteRecipe(AppUser user, String recipeId) async {
    try {
      return await _usersCollection.doc(user.uid).collection("Recipes").doc(recipeId).delete();
    }
    catch (error) { return error; }
  }

}
