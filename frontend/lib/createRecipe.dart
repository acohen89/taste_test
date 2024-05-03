import 'package:flutter/material.dart';
import "package:googleapis_auth/auth_io.dart";
import "package:http/http.dart" as http;
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

  List<String> ingredientWidgets = ["One"];
  List<Ingredient> ingredientsAddedController = [];
  Unit? unitController;
  final ingredientsController = TextEditingController();
  final quantityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final procedureController = TextEditingController();
    final notesController = TextEditingController();
    final double spaceBetweenBoxes = 0.04;

    const String ingredientErrorText = "Please make a valid ingredient";
    const edgePadding = 30.0;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("New Recipe"),
        ),
        body: Container(
          padding: const EdgeInsets.all(edgePadding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Row(
                  children: [
                    Text("Title",
                        style: TextStyle(
                          fontSize: 30,
                          color: constants.lightBlue,
                        )),
                  ],
                ),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'enter recipe title',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Ingredients",
                        style: TextStyle(
                          fontSize: 30,
                          color: constants.lightBlue,
                        )),
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
                                  deleteFunction: deleteIFromIngredientsAddedController,
                                  index: index
                                  );
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
                            borderRadius: BorderRadius.circular(14.0),
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
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide:
                                const BorderSide(color: constants.greyColor),
                          ),
                          hintText: '',
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () => addIngredient(), icon: Icon(Icons.check, size: 22)),

                  ],
                ),
                if (_ingredientError)
                  const Text(
                    ingredientErrorText,
                    style: TextStyle(color: Colors.red, fontSize: 14, fontStyle: FontStyle.italic),
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
                SizedBox(height: MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Procedure",
                        style: TextStyle(
                          fontSize: 30,
                          color: constants.lightBlue,
                        )),
                  ],
                ),
                TextField(
                  controller: procedureController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'outline the steps of this recipe',
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width * spaceBetweenBoxes),
                const Row(
                  children: [
                    Text("Notes",
                        style: TextStyle(
                          fontSize: 30,
                          color: constants.lightBlue,
                        )),
                  ],
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.title),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: const BorderSide(color: constants.greyColor),
                    ),
                    hintText: 'any notes on this recipe',
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      var res = await createRecipe(
                          "",
                          titleController.text,
                          [ingredientsController.text],
                          [procedureController.text],
                          notesController.text);
                      print(res.body);
                    },
                    child: const Text("Create Recipe"))
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
  void addIngredient(){
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
    final Ingredient i = Ingredient(
        q, unitController!, ingredientsController.text);
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
