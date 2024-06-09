import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:taste_test/Components/BottomNavBar.dart';
import 'package:taste_test/Components/noRecipe.dart';
import 'package:taste_test/Recipe/InProgress/inProgressRecipeBuilder.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/constants.dart';

import 'package:taste_test/Shared/globalFunctions.dart';

class inProgressRecipes extends StatefulWidget {
  const inProgressRecipes({super.key});

  @override
  State<inProgressRecipes> createState() => _inProgressRecipesState();
}

class _inProgressRecipesState extends State<inProgressRecipes> {
  final PageController _controller = PageController();
  bool loadingRecipes = false;
  late Future<List<Recipe>?> recs;
  @override
  void initState() {
    super.initState();
    recs = loadMainRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalCardPadding = MediaQuery.of(context).size.width * 0.05;
    const double horizontalPageIndicatorPadding = 8; 
    const double dotSize = 4; 
    const double verticalPadding = dotSize + (horizontalPageIndicatorPadding * 2); 
    const double topPadding = 32;
    const double verticalPageIndicatorPadding = (topPadding-dotSize)/2; 
    const cardPadding =
        EdgeInsets.only(top: topPadding, bottom:0 , left: 0, right: verticalPadding);
    return PopScope(
      canPop: false,
      child: Scaffold(
          bottomNavigationBar: const BottomNavBar(
            startIndex: 0,
          ),
          body: FutureBuilder<List<Recipe>?>(
              future: recs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitWave(color: lightBlue, size: 50);
                }
                var nullOrEmpty = snapshot.data != null ? snapshot.data!.isEmpty : true;
                if (!nullOrEmpty) {
                  List<Recipe>? recipes = snapshot.data;
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: horizontalPageIndicatorPadding, right: horizontalPageIndicatorPadding),
                          child: SmoothPageIndicator(
                            controller: _controller,
                            count: recipes!.length,
                            axisDirection: Axis.vertical,
                            effect: const WormEffect(dotWidth: dotSize,  dotHeight: 8, activeDotColor: lightBlue, dotColor: greyColor),
                          ),
                        ),
                            Expanded(
                            child: PageView.builder(
                                scrollDirection: Axis.vertical,
                                controller: _controller,
                                itemCount: recipes!.length, 
                                itemBuilder: (context, index) {
                                  return  Container(
                                    color: Colors.white,
                                    padding: cardPadding,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: inProgressRecipeBuilder(
                                        dotHeight: verticalPageIndicatorPadding,
                                        dotSize: dotSize, 
                                        recipe: recipes[index], horizontalCardPadding: horizontalCardPadding),
                                  );
                                })),
                      ],
                    ),
                  );
                }
                return const NoRecipes(text: "No In Progress Recipes");
              })),
    );
  }

  void loadingError(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }


  
  Future<List<Recipe>?> loadMainRecipes() async {
    List<Recipe> filter(List<Recipe> recps) => recps.where((r) => r.in_progress == true).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if(token == null) throw Exception("Null token");  
    return getMainRecipes(filter, prefs, token, loadingError);
  }
}
