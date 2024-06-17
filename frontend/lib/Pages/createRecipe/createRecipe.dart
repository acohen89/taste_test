
import "dart:developer";
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:http/http.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:taste_test/Components/BottomNavBar.dart";
import "package:taste_test/Ingredient/IngredientClass.dart";
import "package:taste_test/Pages/createRecipe/createRecipeComponents/ingredient_text_field.dart";
import "package:taste_test/Pages/createRecipe/createRecipeComponents/notes_text_field.dart";
import "package:taste_test/Pages/createRecipe/createRecipeComponents/procedure_field.dart";
import "package:taste_test/Pages/createRecipe/createRecipeComponents/quantity_text_field.dart";
import "package:taste_test/Pages/createRecipe/createRecipeComponents/title_text_field.dart";
import "package:taste_test/Pages/inProgressRecipe/inProgressRecipesPage.dart";
import "package:taste_test/Shared/apiCalls.dart";
import "package:taste_test/Shared/constants.dart";
import "package:taste_test/Ingredient/IngredientRow.dart";
import "package:taste_test/Shared/globalFunctions.dart";

class CreateRecipe extends StatefulWidget {
  final bool isIteration;
  final int? parentRID;
  final int? id;
  final String? title;
  final List<String>? ingredientList;
  final List<String>? procedureList;
  final String? notes;

  const CreateRecipe({
    super.key,
    this.isIteration = false,
    this.parentRID,
    this.id,
    this.title,
    this.ingredientList,
    this.procedureList,
    this.notes,
  });

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  final TextStyle hintTextStyle = const TextStyle(fontSize: 8, fontStyle: FontStyle.italic);
  String missingInputText = "";
  List<String> procedureList = [];
  List<String> ingredientWidgets = ["One"];
  List<Ingredient?> ingredientsAddedController = [];
  Unit? unitController;
  late TextEditingController ingredientsController;
  late TextEditingController procedureController;
  late TextEditingController quantityController;
  late TextEditingController titleController;
  late TextEditingController notesController;
  bool waitingForApiCallBack = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    notesController = TextEditingController(text: widget.notes);
    ingredientsController = TextEditingController();
    quantityController = TextEditingController();
    procedureController = TextEditingController();
    ingredientsAddedController = [];
    if (widget.ingredientList != null) {
      ingredientsAddedController = [for (var i in widget.ingredientList!) Ingredient.fromString(i)];
    }
    procedureList = widget.procedureList ?? [];
  }

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
    final bool isIter = widget.isIteration;
    //if parentid is null we know that it's a beginning recipe
    final bool beginningRecipe = (widget.parentRID == null && widget.id == null) ? true : false;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: widget.isIteration,
          title: Text(isIter ? "New Iteration" : "New Recipe"),
        ),
        body: Container(
          padding: const EdgeInsets.only(left: edgePadding, right: edgePadding, bottom: bottomPadding, top: topPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  children: [
                    Text("Title", style: headingStyle),
                  ],
                ),
                TitleTextField(titleController: titleController, inputBoxRadius: inputBoxRadius),
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
                                  unit: ingredientsAddedController[index]?.unit,
                                  food: ingredientsAddedController[index]!.food,
                                  quantity: ingredientsAddedController[index]?.quantity,
                                  deleteFunction: deleteIFromIngredientsAddedController,
                                  index: index);
                            }),
                      )
                    : Container(),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: QuantityTextField(quantityController: quantityController, hintTextStyle: hintTextStyle, ingredientInputRadius: ingredientInputRadius),
                    ),
                    unitController?.name != "none" ? UnitDropDown() : const SizedBox(width: 4,),
                    Expanded(
                      child: IngredientTextField(ingredientsController: ingredientsController, hintTextStyle: hintTextStyle, ingredientInputRadius: ingredientInputRadius),
                    ),
                    IconButton(
                        onPressed: () {
                          String errorText(String e) => "Please add $e before adding the ingredient";
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
                        icon: const Icon(
                          Icons.add,
                        )),
                  ],
                ),
                const SizedBox(height: titleSpace),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Steps",
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
                                  Container(padding: const EdgeInsets.only(right: 15), child: Text('${index + 1}.', style: const TextStyle(fontSize: 18))),
                                  Expanded(
                                    child: Text(
                                      procedureList[index],
                                      maxLines: procedureMaxLines,
                                    ),
                                  ),
                                  IconButton(onPressed: () => setState(() => procedureList.removeAt(index)), icon: const Icon(Icons.delete))
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
                    SizedBox(width: 30, child: Text('${procedureList.length + 1}.', style: const TextStyle(fontSize: 20))),
                    Expanded(child: ProcedureField(procedureController: procedureController, procedureMinLines: procedureMinLines, procedureMaxLines: procedureMaxLines)),
                    IconButton(
                        onPressed: () {
                          if (procedureController.text.isEmpty) {
                            errorPopUp("Please edit to procedure field before adding");
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
                NotesTextField(notesController: notesController, inputBoxRadius: inputBoxRadius),
                const SizedBox(height: titleSpace),
                waitingForApiCallBack
                    ? const SpinKitWave(color: lightBlue, size: 50)
                    : SizedBox(
                        width: 200,
                        child: TextButton(
                            style: OutlinedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: lightBlue, width: 1)),
                            ),
                            onPressed: () async {
                              if (titleController.text.isEmpty) {
                                errorPopUp("Please add a title");
                                return;
                              }
                              if (ingredientsAddedController.isEmpty) {
                                errorPopUp("Please add at least one ingredient");
                                return;
                              }
                              if (procedureList.isEmpty) {
                                errorPopUp("Please add at least one step to the procedure");
                                return;
                              }
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              final String token = await getToken(prefs, "create recipe");
                              setState(() => waitingForApiCallBack = true);
                              final List<String> ingredientList = ingredientsAddedController.map((i) => i.toString()).toList();
                              Response res = await createRecipe(token, titleController.text, ingredientList, procedureList, notesController.text, beginningRecipe,
                                  parentRID: widget.parentRID ?? widget.id);
                              setState(() => waitingForApiCallBack = false);
                              if (res.statusCode == 400) {
                                log(res.body); 
                                errorPopUp("Error creating recipe");
                                return;
                              }
                              if (res.statusCode == 406) {
                                log("no parent id given, ${res.body}"); 
                                errorPopUp("Error creating recipe");
                                return;
                              }

                              addRecipeToPrefs(res, prefs, beginningRecipe, widget.parentRID ?? widget.id);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const inProgressRecipes()));
                            },
                            child:  Text(
                              "create ${isIter ? "iteration" : "recipe"}",
                              style: const TextStyle(color: lightBlue, fontWeight: FontWeight.bold),
                            )),
                      )
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(startIndex: 1));
  }

  void addRecipeToPrefs(Response res, SharedPreferences sp, bool beginningRecipe, int? recId) {
    String id = recId.toString();
    try {
      if (beginningRecipe) {
        List<String> ids = sp.getStringList("recipeIDList") ?? [];
        ids.add(id);
        sp.setStringList("recipeIDList", ids);
        sp.setString(id, res.body);
        // ignore: curly_braces_in_flow_control_structures
      } else if (recId == null)
        throw Exception("Cannot add recipe to prefs because id is null");
      else if (sp.containsKey("$id iterations")) {
        var recStrList = sp.getStringList("$id iterations");
        recStrList!.add(res.body);
        sp.setStringList("$id iterations", recStrList);
      } else {
        sp.setStringList("$id iterations", [res.body]);
      }
    } catch (e) {
      throw Exception("$e, trying to addRecipeToPrefs");
    }
  }

  DropdownButton UnitDropDown() { 
      List<DropdownMenuItem<Unit?>> items = Unit.values.map((Unit classType) {
        return DropdownMenuItem(value: classType, child: Text(classType.name));
      }).toList(); 
    return DropdownButton(
      hint: Text(
        "Units",
        style: hintTextStyle,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      value: unitController,
      onChanged: (newValue) {
        setState(() {
          unitController = newValue;
        });
      },
      items: items,
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
    if (ingredientsController.text.isEmpty || quantityController.text.isEmpty || unitController == null) {
      return;
    }
    double? q = double.tryParse(quantityController.text);
    if (q == null) {
      return;
    }
    Unit? u = unitController!.name == "none" ? null : unitController;  
    final Ingredient i = Ingredient(q, u, ingredientsController.text);
    setState(() {
      ingredientsAddedController.add(i);
      quantityController.text = "";
      ingredientsController.text = "";
      unitController = null;
    });
  }
}
