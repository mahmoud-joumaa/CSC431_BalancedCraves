import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:balancedcraves/config.dart';
import 'package:balancedcraves/Screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Database =======================================================================================
Database _db = Database();

class Recipes extends StatefulWidget {

  final AppUser? user;

  const Recipes({super.key, this.user});

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final Stream<QuerySnapshot> recipes = _db.getRecipes(user!).snapshots();
    final pageController = PageController();
    return StreamBuilder<QuerySnapshot>(
      stream: recipes,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Scaffold(
          appBar: HomeAppBar.homeAppBar(context, "Recipes", (UserTheme.isDark ? Colors.red[900]! : Colors.red[400]!)),
          body: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {setState(() {_currentIndex = index;});},
            children: [
              ListView(
                children: snapshot.data!.docs.map(
                  (DocumentSnapshot doc) {
                    Map<String, dynamic>? recipeData = doc.data()! as Map<String, dynamic>?;
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return RecipeDialog(user: user, recipe: recipeData, recipeId: doc.id);
                          }
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        title: Text(recipeData!["title"]),
                        subtitle: Text(recipeData["description"]),
                        leading: CircleAvatar(foregroundImage: NetworkImage(recipeData["imgURL"]), radius: 45.0),
                        trailing: SizedBox(
                          width: 80.0,
                          child: IconButton(onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Are you sure you want to delete ${recipeData['title']} from your recipe book?"),
                                  actionsAlignment: MainAxisAlignment.spaceBetween,
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {Navigator.of(context).pop();},
                                    ),
                                    TextButton(
                                      child: const Text("Confirm"),
                                      onPressed: () {_db.deleteRecipe(user, doc.id); Navigator.of(context).pop();},
                                    )
                                  ]
                                );
                              },
                            );
                          }, icon: const Icon(Icons.delete), iconSize: 50.0),
                        ),
                      ),
                    );
                  }
                ).toList(),
              ),
              const Center(child: Text("Favorites")),
              const Center(child: Text("Public")),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.red[600]!,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: GNav(
                selectedIndex: _currentIndex,
                onTabChange: (value) {setState(() {pageController.animateToPage(value, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);});},
                gap: 10.0,
                padding: const EdgeInsets.all(13.0),
                backgroundColor: Colors.red[600]!,
                activeColor: UserTheme.isDark ? const Color(Palette.black) : const Color(Palette.white),
                tabBackgroundColor: UserTheme.isDark ? Colors.red[300]! : Colors.red[800]!,
                tabs: const [
                  GButton(
                    icon: Icons.menu_book,
                    text: "My Recipes",
                  ),
                  GButton(
                    icon: Icons.favorite,
                    text: "Favorites",
                  ),
                  GButton(
                    icon: Icons.public,
                    text: "Public Recipes",
                  )
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: UserTheme.isDark ? Colors.red[700]! : Colors.red[300]!,
            child: Icon(Icons.add, color: UserTheme.isDark ? const Color(Palette.white) : const Color(Palette.black),),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return RecipeDialog(user: user, recipe: null);
                },
              );
            },
          ),
        );
      }
    );
  }

}

class RecipeDialog extends StatefulWidget {

  final AppUser? user;
  final Map<String, dynamic>? recipe;
  final String? recipeId;

  const RecipeDialog({super.key, this.user, this.recipe, this.recipeId});

  @override
  State<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<RecipeDialog> {
  late String category;
  late double calories, carbs, proteins, fats;
  late bool isPublic;
  late bool isFav;
  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final recipe = widget.recipe;
    final titleController = TextEditingController(text: recipe?["title"]??"");
    final descriptionController = TextEditingController(text: recipe?["description"]??"");
    final imgController = TextEditingController(text: recipe?["imgURL"]??"");
    category = recipe?["category"]??"Breakfast";
    calories = recipe?["calories"]??0.0; carbs = recipe?["carbs"]??0.0; proteins = recipe?["proteins"]??0.0; fats = recipe?["fats"]??0.0;
    isPublic = recipe?["isPublic"]??false;
    isFav = recipe?["isFav"]??false;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState){
      return AlertDialog(
        title: const Text("Recipe View", textAlign: TextAlign.center,),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(decoration: const InputDecoration(labelText: "Recipe Name"), controller: titleController),
            const SizedBox(height: 10.0),
            TextField(decoration: const InputDecoration(labelText: "Description"), controller: descriptionController),
            const SizedBox(height: 10.0),
            TextField(decoration: const InputDecoration(labelText: "Image URL"), controller: imgController),
            const SizedBox(height: 20.0),
            DropdownButton<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: "Breakfast", child: Text("Breakfast")),
                DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                DropdownMenuItem(value: "Snack", child: Text("Snack")),
              ],
              onChanged: (cat) {setState(() {category=cat!;});},
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                const Text("Calories"),
                Slider(
                  min: 0,
                  max: 10000,
                  divisions: 500,
                  value: calories,
                  onChanged: (value) {setState(() {calories = value;});}
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Text("Carbs"),
                Slider(
                  min: 0,
                  max: 400,
                  divisions: 100,
                  value: carbs,
                  onChanged: (value) {setState(() {carbs = value;});}
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Text("Proteins"),
                Slider(
                  min: 0,
                  max: 250,
                  divisions: 50,
                  value: proteins,
                  onChanged: (value) {setState(() {proteins = value;});}
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                const Text("Fats"),
                Slider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  value: fats,
                  onChanged: (value) {setState(() {fats = value;});}
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isPublic,
                  onChanged: (value) {setState(() {isPublic = value!;});},
                ),
                const Text("Public"),
                Checkbox(
                  value: isFav,
                  onChanged: (value) {setState(() {isFav = value!;});},
                ),
                const Text("Favorite"),
              ],
            ),
          ]
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {Navigator.of(context).pop();},
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Recipe recipeNew = Recipe(title: titleController.text, description: descriptionController.text, imgURL: imgController.text, category: category, isPublic: isPublic, isFav: isFav, calories: calories, carbs: carbs, proteins: proteins, fats: fats, dates: []);
              if (recipe == null) {_db.addRecipe(user!, recipeNew);}
              else {_db.setRecipe(user!, recipeNew, widget.recipeId!);}
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          )
        ],
      );
    });
  }
}
