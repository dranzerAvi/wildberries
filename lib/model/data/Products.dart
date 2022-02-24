import 'dart:convert';

class ProdProducts {
  List imgcollection;
  int sold;
  String varientID;
  String id;
  String name;
  int original_price;
  int selling_price;
  int quantity;
  String description;
  List filterValue;
  Map category;
  Map subCategory;
  Map leafCategory;
  List prices;
  List tablespecs;
  List specs;
  String image;
  int __v;
  String productQuantity;

  ProdProducts.fromMap(Map<String, dynamic> data) {
    imgcollection = data["imgcollection"];
    sold = data["sold"];
    name = data["name"];
    varientID = data["varientID"];
    id = data["_id"];
    original_price = data["original_price"];
    selling_price = data["selling_price"];
    quantity = data["quantity"];
    description = data["description"];
    filterValue = data["filterValue"];
    category = data["category"];
    subCategory = data["subCategory"];
    leafCategory = data["leafCategory"];
    prices = data["prices"];
    tablespecs = data["tablespecs"];
    specs = data["specs"];
    image = data["image"].toString().replaceAll('\\', '/');
    __v = data["__v"];
    productQuantity = data["productQuantity"];
  }

  Map<String, dynamic> toMap() {
    return {
      'imgcollection': imgcollection,
      'sold': sold,
      'varientID': varientID,
      '_id': id,
      'original_price': original_price,
      'selling_price': selling_price,
      'quantity': quantity,
      'description': description,
      'filterValue': filterValue,
      'category': category,
      'subCategory': subCategory,
      'leafCategory': leafCategory,
      'name': name,
      'prices': prices,
      'tablespecs': tablespecs,
      'specs': specs,
      'image': image,
      '__v': __v,
      'productQuantity': productQuantity
    };
  }

  static String encode(List<ProdProducts> cartItems) => json.encode(
        cartItems
            .map<Map<String, dynamic>>((cartItem) => cartItem.toMap())
            .toList(),
      );

  static List<ProdProducts> decode(String cartItems) =>
      (json.decode(cartItems) as List<dynamic>)
          .map<ProdProducts>((item) => ProdProducts.fromMap(item))
          .toList();
}

class Cat {
  List filters;
  String id;
  String name;
  bool active;
  String banner;
  int __v;
  String description;
  int upToOff;
  Cat.fromMap(Map<String, dynamic> data) {
    // String altBanner = data['banner'].toString().replaceAll('\\', '/');

    filters = data["filters"];
    id = data["_id"];
    name = data["name"];
    active = data["active"];
    banner = data['banner'].toString().replaceAll('\\', '/');
    __v = data["__v"];
    description = data["description"];
    upToOff = data["upToOff"];
  }

  Map<String, dynamic> toMap() {
    return {
      'filters': filters,
      '_id': id,
      'name': name,
      'active': active,
      'banner': banner,
      '__v': name,
      'description': description,
      'upToOff': upToOff
    };
  }
}
