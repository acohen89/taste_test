import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import "package:googleapis_auth/auth_io.dart";
import "package:http/http.dart" as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:taste_test/api_calls.dart";
import "package:taste_test/classes/IngredientClass.dart";
import "constants.dart" as constants;

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  bool _ingredientError = false;
  String missingInputText = "";
  List<String> ingredientWidgets = ["One"];
  List<Ingredient> ingredientsAddedController = [];
  Unit? unitController;
  final ingredientsController = TextEditingController();
  final quantityController = TextEditingController();
  final titleController = TextEditingController();
  final procedureController = TextEditingController();
  final notesController = TextEditingController();
  bool waitingForApiCallBack = false;
  @override
  Widget build(BuildContext context) {
    const double spaceBetweenBoxes = 0.04;
    const String ingredientsMissingText = "Please add at least one ingredient";
    const String titleMissingText = "Please add a title";
    const String ingredientErrorText = "Please make a valid ingredient";
    const double edgePadding = 30.0;
    const double bottomPadding = 30.0;
    const double topPadding = 10;
    const double ingredientInputRadius = 6;
    const TextStyle headingStyle = TextStyle(
      fontSize: 30,
      color: constants.lightBlue,
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
              top: topPadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                missingInputText.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            missingInputText,
                            style: const TextStyle(
                                color: Colors.red, fontStyle: FontStyle.italic),
                          )
                        ],
                      )
                    : Container(),
                const Row(
                  children: [
                    Text("Title",
                        style: headingStyle),
                  ],
                ),
                TextField(
                  maxLines: null,
                  controller: titleController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(inputBoxRadius),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'enter recipe title',
                  ),
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Ingredients",
                        style: headingStyle),
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
                                const BorderSide(color: constants.greyColor),
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
                        controller: ingredientsController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(ingredientInputRadius),
                            borderSide:
                                const BorderSide(color: constants.greyColor),
                          ),
                          hintText: '',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () => addIngredient(),
                        icon: const Icon(Icons.check, size: 22)),
                  ],
                ),
                if (_ingredientError)
                  const Text(
                    ingredientErrorText,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          addIngredient();
                        },
                        icon: const Icon(Icons.format_list_bulleted_add))
                  ],
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Procedure",
                        style: headingStyle),
                  ],
                ),
                TextField(
                  controller: procedureController,
                  maxLines: null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.format_list_bulleted),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(inputBoxRadius),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'outline the steps of this recipe',
                  ),
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Notes",
                        style: headingStyle),
                  ],
                ),
                TextField(
                  maxLines: null,
                  controller: notesController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.notes),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(inputBoxRadius),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'any notes on this recipe',
                  ),
                ),
                SizedBox(height: spaceBetweenBoxes * 500),
                waitingForApiCallBack
                    ? const SpinKitWave(color: constants.lightBlue, size: 50)
                    : ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            setState(() => missingInputText = titleMissingText);
                            return;
                          }
                          if (ingredientsAddedController.isEmpty) {
                            setState(() =>
                                missingInputText = ingredientsMissingText);
                            return;
                          }
                          setState(() => missingInputText = "");
                          final prefs = await SharedPreferences.getInstance();
                          final String? key = prefs.getString("token");
                          if (key == null) throw ("Unable to get auth token");
                          setState(() => waitingForApiCallBack = true);
                          final List<String> ingredientList = ingredientsAddedController.map((i) => i.toString()).toList();
                          var res = await createRecipe(
                              key,
                              titleController.text,
                              ingredientList,
                              [procedureController.text],
                              notesController.text);
                          print(res.body);
                          setState(() => waitingForApiCallBack = false);
                          if(res.statusCode >= 300){
                            setState(() => missingInputText = "Creating recipe failed");
                            return;
                          }
                        },
                        child: const Text(
                          "Create Recipe",
                          style: TextStyle(
                              color: constants.lightBlue,
                              fontWeight: FontWeight.bold),
                        ))
              ],
            ),
          ),
        ));
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

  void addIngredient() {
    if (ingredientsController.text.isEmpty ||
        quantityController.text.isEmpty ||
        unitController == null) {
      setState(() {
        _ingredientError = true;
      });
      return;
    }
    double? q = double.tryParse(quantityController.text);
    if (q == null) {
      setState(() => _ingredientError = true);
      return;
    }
    final Ingredient i =
        Ingredient(q, unitController!, ingredientsController.text);
    setState(() {
      ingredientsAddedController.add(i);
      print(ingredientsAddedController);
      quantityController.text = "";
      ingredientsController.text = "";
      unitController = null;
      _ingredientError = false;
    });
  }
}
