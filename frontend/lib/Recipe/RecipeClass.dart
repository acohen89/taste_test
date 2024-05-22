class Recipe {
  final int id;
  final String title;
  final bool beginningRecipe;
  final String? parentRID;
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

  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        title = json['title'] as String,
        beginningRecipe = json['beginningRecipe'] as bool,
        parentRID = json['parentRID'] as String?,
        created = json['created'] as String,
        last_edited = json['last_edited'] as String,
        ingredients = json['ingredients'] as List,
        image_url = json['image_url'] as String?,
        procedure = json['procedure'] as List,
        notes = json['notes'] as String?,
        in_progress = json['in_progress'] as bool,
        iteration_ids = json['iteration_ids'] as List;

  @override
  String toString() {
    return title;
  }
}

