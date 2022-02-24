import 'dart:convert';

class Cart {
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
  List prices;
  List tablespecs;
  List specs;
  String image;
  int __v;
  String productQuantity;
  int cartQuantity;

  Cart({
    this.id,
    this.name,
    this.selling_price,
    this.category,
    this.specs,
    this.productQuantity,
    this.original_price,
    this.quantity,
    this.imgcollection,
    this.filterValue,
    this.description,
    this.image,
    this.prices,
    this.cartQuantity,
    this.sold,
    this.tablespecs,
    this.varientID,
  });

  Cart.fromMap(Map<String, dynamic> data) {
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
    prices = data["prices"];
    tablespecs = data["tablespecs"];
    specs = data["specs"];
    image = data["image"].toString().replaceAll('\\', '/');
    __v = data["__v"];
    productQuantity = data["productQuantity"];
    cartQuantity = data["cartQuantity"];
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
      'name': name,
      'prices': prices,
      'tablespecs': tablespecs,
      'specs': specs,
      'image': image,
      '__v': __v,
      'productQuantity': productQuantity,
      'cartQuantity': cartQuantity
    };
  }

  static String encode(List<Cart> cartItems) => json.encode(
        cartItems
            .map<Map<String, dynamic>>((cartItem) => cartItem.toMap())
            .toList(),
      );

  static List<Cart> decode(String cartItems) =>
      (json.decode(cartItems) as List<dynamic>)
          .map<Cart>((item) => Cart.fromMap(item))
          .toList();
}
