import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:taste_test/Recipe/RecipeClass.dart';
import 'package:taste_test/Shared/constants.dart';

class inProgressRecipeCard extends StatefulWidget {
  const inProgressRecipeCard({
    super.key,
    required this.recipe,
    required this.horizontalCardPadding,
  });

  final Recipe recipe;
  final double horizontalCardPadding;

  @override
  State<inProgressRecipeCard> createState() => _inProgressRecipeCardState();
}

class _inProgressRecipeCardState extends State<inProgressRecipeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print(widget.recipe.id),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width - (widget.horizontalCardPadding * 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Title(),
              const Divider(),
              const SizedBox(height: 8),
              const Text("Ingredients", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
              Ingredients(context),
              const SizedBox(height: 8),
              const Text("Procedure", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
               Procedure(context),
              const SizedBox(height: 8),
              const Text("Notes", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20, color: lightBlue)),
              widget.recipe.notes == null ? 
              const Text("none", style: TextStyle(color: greyColor, fontStyle: FontStyle.italic),) 
              : Text(widget.recipe.notes!, maxLines: null,),
      
      
            ],
          ),
        ),
      ),
    );
  }

  Column Procedure(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.recipe.procedure.length; i++)
                RichText(
                  text: TextSpan(
                    text: "${i+1}. ",
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: widget.recipe.procedure[i], style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  maxLines: null,
                )
            ],
          );
  }

  Column Ingredients(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (String ingredient in widget.recipe.ingredients) 
            RichText(text: TextSpan(
                  text: bullet,
                  style: DefaultTextStyle.of(context).style,
                  children:  <TextSpan>[
                    TextSpan(text: ingredient, style: const TextStyle(fontSize: 16)),
                  ],
                ),
                maxLines: null,)
            ],
          );
  }

  Center Title() {
    return Center(
              child: AutoSizeText(widget.recipe.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            minFontSize: 14,
            maxLines: 3,
          ));
  }
}
