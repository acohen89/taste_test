import 'dart:convert';

class Recipe {
  final int id;
  final String title;
  final bool beginningRecipe;
  final int? parentRID;
  final String created;
  final String last_edited;
  final List ingredients;
  final String? image_url;
  final List procedure;
  final String? notes;
  final bool in_progress;
  final List iteration_ids;

  Recipe(
      this.id,
      this.title,
      this.beginningRecipe,
      this.parentRID,
      this.created,
      this.last_edited,
      this.ingredients,
      this.image_url,
      this.procedure,
      this.notes,
      this.in_progress,
      this.iteration_ids);


   Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "beginningRecipe": beginningRecipe,
      "parentRID": parentRID,
      "created": created,
      "last_edited": last_edited,
      "ingredients": ingredients,
      "image_url": image_url,
      "procedure": procedure,
      "notes": notes,
      "in_progress": in_progress,
      "iteration_ids": iteration_ids
    };
  }
  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        beginningRecipe = json['beginningRecipe'] as bool,
        parentRID = json['parentRID'] as int?,
        created = json['created'] as String,
        last_edited = json['last_edited'] as String,
        ingredients = json['ingredients'] as List,
        image_url = json['image_url'] as String?,
        procedure = json['procedure'] as List,
        notes = json['notes'] as String?,
        in_progress = json['in_progress'] as bool,
        iteration_ids = json['iteration_ids'] as List;


  static List<Recipe>? stringsToRecipes(List<String> strRecipes){
    List<dynamic> mapRecipes = [for (var rec in strRecipes) jsonDecode(rec)]; 
      try {
        List<Recipe> recipeList =
            mapRecipes.map((rec) => Recipe.fromJson(rec)).toList();
        return recipeList; 
      } catch (e) {
        print("$e, trying to decode recipes");
      }
      return null;
  }
  @override
  String toString() {
    return title;
  }

   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  

}

