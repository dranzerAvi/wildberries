class OrderProduct {
  int product;
  String name;
  int price;
  int count;
  String imgURL;
  String quantity;

  OrderProduct({
    this.product,
    this.price,
    this.name,
    this.count,
    this.quantity,
    this.imgURL,
  });

  OrderProduct.fromMap(Map<String, dynamic> data) {
    product = data["product"];
    price = data["price"];
    name = data["name"];
    quantity = data["quantity"];
    imgURL = data["imgURL"];
    count = data["count"];
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product,
      'price': price,
      'name': name,
      'imgURL': imgURL,
      'quantity': quantity,
      'count': count,
    };
  }

// static String encode(UserDataProfile userData) => json.encode(
//       userData.toMap(),
//     );
//
// static UserDataProfile decode(String cartItems) => (json.decode(cartItems))
//     .map<UserDataProfile>((item) => UserDataProfile.fromMap(item));
}
