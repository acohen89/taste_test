import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:taste_test/Components/BottomNavBar.dart";
import "package:taste_test/Shared/apiCalls.dart";
import "package:taste_test/Shared/constants.dart";
import "package:taste_test/Ingredient/IngredientClass.dart";
import "package:taste_test/Pages/home.dart";
import "package:taste_test/Shared/globalFunctions.dart";


class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  String missingInputText = "";
  List<String> procedureList = [];
  List<String> ingredientWidgets = ["One"];
  List<Ingredient> ingredientsAddedController = [];
  Unit? unitController;
  final ingredientsController = TextEditingController();
  final procedureController = TextEditingController();
  final quantityController = TextEditingController();
  final titleController = TextEditingController();
  final notesController = TextEditingController();
  bool waitingForApiCallBack = false;
  @override
  Widget build(BuildContext context) {
    const double titleSpace = 24;
    const procedureMinLines = 1;
    const procedureMaxLines = 4;
    const double edgePadding = 30.0;
    const double bottomPadding = 30.0;
    const double topPadding = 10;
    const double ingredientInputRadius = 6;
    const TextStyle headingStyle = TextStyle(
      fontSize: 30,
      color: lightBlue,
    );
    const double inputBoxRadius = 12;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("New Recipe"),
        ),
        body: Container(
          padding: const EdgeInsets.only(
              left: edgePadding,
              right: edgePadding,
              bottom: bottomPadding,
              top: topPadding
              ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // const SizedBox(height: titleSpace),
                const Row(
                  children: [
                    Text("Title", style: headingStyle),
                  ],
                ),
                TextField(
                  textAlignVertical: TextAlignVertical.bottom,
                  maxLines: null,
                  controller: titleController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(inputBoxRadius),
                      borderSide: const BorderSide(color: greyColor),
                    ),
                    hintText: 'enter recipe title',
                  ),
                ),
                const SizedBox(height: titleSpace),
                const Row(
                  children: [
                    Text("Ingredients", style: headingStyle),
                  ],
                ),
                (ingredientsAddedController.isNotEmpty)
                    ? SizedBox(
                        height: 50.0 * ingredientsAddedController.length,
                        child: ListView.builder(
                            itemCount: ingredientsAddedController.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AddedIngredient(
                                  unit: ingredientsAddedController[index].unit,
                                  food: ingredientsAddedController[index].food,
                                  quantity: ingredientsAddedController[index]
                                      .quantity,
                                  deleteFunction:
                                      deleteIFromIngredientsAddedController,
                                  index: index);
                            }),
                      )
                    : Container(),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.right,
                        controller: quantityController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.only(
                              right: 10, top: 10, bottom: 0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(ingredientInputRadius),
                            borderSide:
                                const BorderSide(color: greyColor),
                          ),
                          hintText: '',
                        ),
                      ),
                    ),
                    DropdownButton(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      value: unitController,
                      onChanged: (newValue) {
                        setState(() {
                          unitController = newValue;
                        });
                      },
                      items: Unit.values.map((Unit classType) {
                        return DropdownMenuItem<Unit>(
                            value: classType, child: Text(classType.name));
                      }).toList(),
                    ),
                    Expanded(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.bottom,
                        controller: ingredientsController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(ingredientInputRadius),
                            borderSide:
                                const BorderSide(color: greyColor),
                          ),
                          hintText: '',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          String errorText(String e) =>
                              "Please add $e before adding the ingredient";
                          if (quantityController.text.isEmpty) {
                            errorPopUp(errorText("a quantity"));
                            return;
                          }
                          if (unitController == null) {
                            errorPopUp(errorText("a unit"));
                            return;
                          }
                          if (ingredientsController.text.isEmpty) {
                            errorPopUp(errorText("an ingredient"));
                            return;
                          }
                          addIngredient();
                        },
                        icon: const Icon(Icons.check, size: 22)),
                  ],
                ),
                const SizedBox(height: titleSpace),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Procedure",
                          style: headingStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                procedureList.isNotEmpty
                    ? ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: procedureList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: Text('${index + 1}.',
                                          style:
                                              const TextStyle(fontSize: 18))),
                                  Expanded(
                                    child: Text(
                                      procedureList[index],
                                      maxLines: procedureMaxLines,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () => setState(
                                          () => procedureList.removeAt(index)),
                                      icon: const Icon(Icons.delete))
                                ],
                              ),
                              const Divider(),
                            ],
                          );
                        })
                    : Container(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                        width: 30,
                        child: Text('${procedureList.length + 1}.',
                            style: const TextStyle(fontSize: 20))),
                    Expanded(
                        child: TextField(
                            textAlignVertical: TextAlignVertical.bottom,
                            decoration: const InputDecoration(
                                hintText:
                                    "enter the steps you took to create this recipe",
                                hintStyle: TextStyle(fontSize: 10)),
                            minLines: procedureMinLines,
                            maxLines: procedureMaxLines,
                            controller: procedureController)),
                    IconButton(
                        onPressed: () {
                          if (procedureController.text.isEmpty) {
                            errorPopUp(
                                "Please edit to procedure field before adding");
                            return;
                          }
                          setState(() {
                            procedureList.add(procedureController.text);
                            procedureController.text = "";
                          });
                        },
                        icon: const Icon(Icons.add))
                  ],
                ),
                const SizedBox(height: titleSpace),
                const Row(
                  children: [
                    Text("Notes", style: headingStyle),
                  ],
                ),
                TextField(
                  textAlignVertical: TextAlignVertical.bottom,
                  maxLines: null,
                  controller: notesController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(inputBoxRadius),
                      borderSide: const BorderSide(color: greyColor),
                    ),
                    hintText: 'any notes on this recipe',
                  ),
                ),
                const SizedBox(height: titleSpace),
                waitingForApiCallBack
                    ? const SpinKitWave(color: lightBlue, size: 50)
                    : SizedBox(
                        width: 200,
                        child: TextButton(
                            style: OutlinedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                      color: lightBlue, width: 1)),
                            ),
                            onPressed: () async {
                              if (titleController.text.isEmpty) {
                                errorPopUp("Please add a title");
                                return;
                              }
                              if (ingredientsAddedController.isEmpty) {
                                errorPopUp(
                                    "Please add at least one ingredient");
                                return;
                              }
                              if (procedureList.isEmpty) {
                                errorPopUp(
                                    "Please add at least one step to the procedure");
                                return;
                              }

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final String? key = prefs.getString("token");
                              if (key == null)
                                throw ("Unable to get auth token");
                              setState(() => waitingForApiCallBack = true);
                              final List<String> ingredientList =
                                  ingredientsAddedController
                                      .map((i) => i.toString())
                                      .toList();
                              var res = await createRecipe(
                                  key,
                                  titleController.text,
                                  ingredientList,
                                  procedureList,
                                  notesController.text);
                              setState(() => waitingForApiCallBack = false);
                              if (res.statusCode >= 300) {
                                errorPopUp("Error creating recipe");
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()));
                            },
                            child: const Text(
                              "Create Recipe",
                              style: TextStyle(
                                  color: lightBlue,
                                  fontWeight: FontWeight.bold),
                            )),
                      )
              ],
            ),
          ),
        ),
      bottomNavigationBar:  const BottomNavBar(startIndex: 1)
        );
  }

  void deleteIFromIngredientsAddedController(int index) {
    setState(() {
      try {
        ingredientsAddedController.removeAt(index);
      } catch (e) {
        rethrow;
      }
    });
  }

  void errorPopUp(String text, {int duration = 2250}) {
    final snack = snackBarError(text, duration);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void addIngredient() {
    if (ingredientsController.text.isEmpty ||
        quantityController.text.isEmpty ||
        unitController == null) {
      return;
    }
    double? q = double.tryParse(quantityController.text);
    if (q == null) {
      return;
    }
    final Ingredient i =
        Ingredient(q, unitController!, ingredientsController.text);
    setState(() {
      ingredientsAddedController.add(i);
      quantityController.text = "";
      ingredientsController.text = "";
      unitController = null;
    });
  }
}
