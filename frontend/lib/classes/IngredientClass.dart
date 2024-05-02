enum Unit{g, ml, cup, tsp, tbs, gal, L, oz}

class Ingredient{
  double quantity;
  Unit unit; 
  String food;

  Ingredient(this.quantity, this.unit, this.food);

  @override
  String toString() {
    return "$quantity $unit $food";
  }
}