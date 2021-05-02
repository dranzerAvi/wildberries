class ProdProducts {
  String productImage;
  String name;
  String brand;
  double price;
  double totalPrice;
  String desc;
  String moreDesc;
  String foodType;
  String lifeStage;
  String flavor;
  String weight;
  String ingredients;
  String directions;
  String size;
  String productID;
  String pet;
  String category;
  String subCategory;
  String service;
  String tag;
  int quantity;
  int discount;
  List<dynamic> nameSearch;
  List<dynamic> catSearch;
  List<dynamic> variants;
  String color;

  ProdProducts.fromMap(Map<String, dynamic> data) {
    productImage = data["productImage"];
    name = data["name"];
    brand = data["brand"];
    price = data["price"];
    totalPrice = data["totalPrice"];
    desc = data["desc"];
    moreDesc = data["moreDesc"];
    foodType = data["foodType"];
    lifeStage = data["lifeStage"];
    flavor = data["flavor"];
    weight = data["weight"];
    ingredients = data["ingredients"];
    directions = data["directions"];
    size = data["size"];
    productID = data["productID"];
    pet = data["pet"];
    category = data["category"];
    subCategory = data["subCategory"];
    service = data["service"];
    tag = data["tag"];
    quantity = data["quantity"];
    nameSearch = data["nameSearch"];
    catSearch = data["categorySearch"];
    discount = data["discount"];
    variants=data['variants'];
    color='';
  }

  Map<String, dynamic> toMap() {
    return {
      'productImage': productImage,
      'name': name,
      'brand': brand,
      'price': price,
      'totalPrice': totalPrice,
      'desc': desc,
      'moreDesc': moreDesc,
      'foodType': foodType,
      'lifeStage': lifeStage,
      'flavor': flavor,
      'weight': weight,
      'ingredients': ingredients,
      'directions': directions,
      'size': size,
      'productID': productID,
      'pet': pet,
      'category': category,
      'subCategory': subCategory,
      'service': service,
      'tag': tag,
      'quantity': quantity,
      'nameSearch': nameSearch,
      'categorySearch': catSearch,
      'discount': discount,
      'variants':variants,
      'color':color,
    };
  }
}

class Cat {
  String productImage;
  String name;
  List sCat;
  Cat.fromMap(Map<String, dynamic> data) {
    productImage = data["imageURL"];
    name = data["catName"];
    sCat = data["sCatDetails"];
  }

  Map<String, dynamic> toMap() {
    return {'imageURL': productImage, 'catName': name, 'sCatDetails': sCat};
  }
}
