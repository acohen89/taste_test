import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taste_test/Recipe/fullRecipeCard.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:taste_test/Shared/apiCalls.dart';
import 'package:taste_test/Shared/constants.dart';

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
          Expanded(child: inProgressRecipeCard(recipe: widget.recipe, horizontalCardPadding: 0)),
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
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? token = sp.getString("token");
    if (token == null) throw Exception("Null token");
    Response res = await updateRecipeProgress(token, r.parentRID ?? r.id);
    if (res.statusCode == 404) throw Exception("Id ${r.id} not found");
    if (res.statusCode == 406) throw Exception("Id param not properly given");
    if (res.statusCode == 500) throw Exception("500 response");
    //successful
    return;
  }
}
