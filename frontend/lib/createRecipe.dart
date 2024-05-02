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
  Unit? _ingredientUnit;
  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final ingredientsController = TextEditingController();
    final procedureController = TextEditingController();
    final notesController = TextEditingController();
    final quantityController = TextEditingController();

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("New Recipe"),
        ),
        body: Container(
          padding: const EdgeInsets.all(30),
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
              SizedBox(height: MediaQuery.of(context).size.width * 0.22),
              const Row(
                children: [
                  Text("Ingredients",
                      style: TextStyle(
                        fontSize: 30,
                        color: constants.lightBlue,
                      )),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: quantityController,
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
                  DropdownButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    value: _ingredientUnit,
                    onChanged: (newValue) {
                      setState(() {
                        _ingredientUnit = newValue;
                      });
                    },
                    items: Unit.values.map((Unit classType) {
                      return DropdownMenuItem<Unit>(
                          value: classType, child: Text(classType.name));
                    }).toList(),
                  ),
                  Expanded(
                    child: TextField(
                      // controller: quantityController,
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
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.width * 0.22),
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
              SizedBox(height: MediaQuery.of(context).size.width * 0.22),
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
        ));
  }
}
