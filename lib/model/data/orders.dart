// import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  List products;
  String transaction_id;
  String status;
  String id;
  int amount;
  Map address;
  String user;
  String orderType;
  String deliveryType;
  String expectedDelivery;
  double tax;
  int deliveryCharge;
  double offPrice;
  String createdAt;
  String updatedAt;
  String offerApplied;
  Order.fromMap(Map<String, dynamic> data) {
    products = data["products"];
    transaction_id = data["transaction_id"];
    status = data["status"];
    id = data["_id"];
    amount = data["amount"];
    address = data["address"];
    user = data["user"];
    orderType = data["orderType"];
    deliveryType = data["deliveryType"];
    expectedDelivery = data["expectedDelivery"];
    offerApplied = data["offerApplied"];
    tax = data['tax'] * 1.0;
    // tax = data['tax'].runtimeType == 'double'
    //     ? int.parse(data['tax'])
    //     : data['tax'];
    deliveryCharge = data["deliveryCharge"];
    offPrice = data["offPrice"] * 1.0;
    createdAt = data["createdAt"];
    updatedAt = data["updatedAt"];
  }
  Map<String, dynamic> toMap() {
    return {
      'products': products,
      'transaction_id': transaction_id,
      'status': status,
      '_id': id,
      'amount': amount,
      'address': address,
      'offerApplied': offerApplied,
      'user': user,
      'orderType': orderType,
      'deliveryType': deliveryType,
      'expectedDelivery': expectedDelivery,
      'tax': tax,
      'deliveryCharge': deliveryCharge,
      'offPrice': offPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
