import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/FullRecipeCard/FullRecipeCard.dart'; 
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';
import 'package:taste_test/Shared/globalFunctions.dart';

class FullRecipePageView extends StatefulWidget {
  final Recipe recipe;
  const FullRecipePageView({super.key, required this.recipe});

  @override
  State<FullRecipePageView> createState() => _FullRecipePageViewState();
}

class _FullRecipePageViewState extends State<FullRecipePageView> {
  bool editLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 16, right: 16, left: 16),
      child: Column(
        children: [
          TopBar(context),
          const Divider(),
          // is finished true because it's coming from finished recipe page
          Expanded(child: FullRecipeCard(recipe: widget.recipe, horizontalCardPadding: 0, isFinished: true)),
        ],
      ),
    ));
  }

  Row TopBar(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_outlined,
            size: 32,
          )),
      AutoSizeText(
        widget.recipe.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        minFontSize: 14,
        maxLines: 3,
      ),
      editLoading
          ? const SpinKitWave(color: lightBlue, size: 32)
          : IconButton(
              onPressed: () async {
                setState(() => editLoading = true);
                await changeFinishedRecipeToIP(widget.recipe);
                setState(() => editLoading = false);
                Navigator.pushNamed(context, "inProgressRecipesWithReload");
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 24,
              )),
    ]);
  }

  Future<void> changeFinishedRecipeToIP(Recipe r) async {
    final String token = await getToken(null, "changeFinishedRecipeToIP");
    bool success = await updateRecipeProgress(token, r.parentRID ?? r.id);
    if(!success) errorPopUp("Edit function not working"); 
    //successful
    return;
  }
   void errorPopUp(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
