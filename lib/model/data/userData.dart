import 'dart:convert';

import 'package:wildberries/model/data/cart.dart';

class UserDataProfile {
  String firstName;
  String lastName;
  int phone;
  String email;
  String subscriptionID;
  String subscriptionTime;
  String imgURL;
  int role;
  int coins;
  String id;
  String token;
  int __v;
  List address;
  List copounsused;
  String subscription;
  String subscriptionDiscount;

  UserDataProfile(
      {this.firstName,
      this.lastName,
      this.phone,
      this.email,
      this.id,
      this.imgURL,
      this.role,
      this.coins,
      this.token,
      this.copounsused,
      this.subscription,
      this.subscriptionID,
      this.subscriptionDiscount,
      this.subscriptionTime});

  UserDataProfile.fromMap(Map<String, dynamic> data) {
    firstName = data["firstName"];
    lastName = data["lastName"];
    phone = data["phone"];
    email = data["email"];
    imgURL = data["imgURL"];
    role = data["role"];
    coins = data["coins"];
    id = data["_id"];
    token = data["token"];
    copounsused = data["copounsused"];
    subscription = data["subscription"];
    subscriptionID = data["subscriptionID"];
    subscriptionTime = data["subscriptionTime"];
    subscriptionDiscount = data["subscriptionDiscount"];
    __v = data["__v"];
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'imgURL': imgURL,
      'copounsused': copounsused,
      'subscription': subscription,
      'subscriptionID': subscriptionID,
      'subscriptionTime': subscriptionTime,
      'subscriptionDiscount': subscriptionDiscount,
      'role': role,
      'coins': coins,
      '_id': id,
      'token': token,
      '__v': __v,
    };
  }

  // static String encode(UserDataProfile userData) => json.encode(
  //       userData.toMap(),
  //     );
  //
  // static UserDataProfile decode(String cartItems) => (json.decode(cartItems))
  //     .map<UserDataProfile>((item) => UserDataProfile.fromMap(item));
}

class UserDataAddress {
  String id;
  String city;
  String address;
  int zip;

  UserDataAddress(this.id, this.city, this.address, this.zip);

  UserDataAddress.fromMap(Map<String, dynamic> data) {
    id = data["_id"];
    city = data["city"];
    address = data["address"];
    zip = data["zip"];
  }

  Map<String, dynamic> toMap() {
    return {'zip': zip, 'address': address, 'city': city, '_id': id};
  }

  static String encode(List<UserDataAddress> cartItems) => json.encode(
        cartItems
            .map<Map<String, dynamic>>((cartItem) => cartItem.toMap())
            .toList(),
      );

  static List<UserDataAddress> decode(String cartItems) =>
      (json.decode(cartItems) as List<dynamic>)
          .map<UserDataAddress>((item) => UserDataAddress.fromMap(item))
          .toList();
}

class UserDataCard {
  String cardHolder;
  String cardNumber;
  String validThrough;
  String securityCode;

  UserDataCard.fromMap(Map<String, dynamic> data) {
    cardHolder = data["cardHolder"];
    cardNumber = data["cardNumber"];
    validThrough = data["validThrough"];
    securityCode = data["securityCode"];
  }

  Map<String, dynamic> toMap() {
    return {
      'cardHolder': cardHolder,
      'cardNumber': cardNumber,
      'validThrough': validThrough,
      'securityCode': securityCode,
    };
  }
}
