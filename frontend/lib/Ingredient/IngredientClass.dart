import 'package:string_validator/string_validator.dart';
enum Unit { g, ml, cup, tsp, tbs, gal, L, oz }

Unit strToUnit(String s) {
  return Unit.values.firstWhere((e) => e.toString() == 'Unit.$s');
}

class Ingredient {
  double? quantity;
  Unit? unit;
  String food;

  Ingredient(this.quantity, this.unit, this.food);

  @override
  String toString() {
    String qStr = quantity != null ? "${quantity.toString()} " : "";
    String uStr = unit != null ? "${unit!.name} " : ""; 
    return "$qStr$uStr$food";
  }

  static Ingredient? fromString(String? i) {
    if(i == null || i.isEmpty) return null; 
    try {
      if(!isNumeric(i[0])) return Ingredient(null, null, i); 
      String qAndU = i.split(" ")[0];
      int m = 0;
      String quantity = "";
      for (m; m < qAndU.length; m++) {
        if (qAndU[m].toUpperCase().contains(RegExp(r'[A-Z]'), 0)) break;
        quantity += qAndU[m];
      }
      String unit = qAndU.substring(m,);
      List ingList = i.split(" ").sublist(1,);
      String ingredient = [for (var k in ingList) k].join(" ");
      return Ingredient(double.parse(quantity), strToUnit(unit), ingredient);
    } catch (e) {
      return Ingredient(null, null, i); 
    }
  }
}
