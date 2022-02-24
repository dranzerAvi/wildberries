import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/bannerAds.dart';
import 'package:wildberries/model/data/brands.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/filter.dart';
import 'package:wildberries/model/data/leafCategory.dart';
import 'package:wildberries/model/data/orders.dart';
import 'package:wildberries/model/data/subCategory.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/data/wishlist.dart';
import 'package:wildberries/model/notifiers/bannerAd_notifier.dart';
import 'package:wildberries/model/notifiers/brands_notifier.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/filter_notifier.dart';
import 'package:wildberries/model/notifiers/orders_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/notifiers/wishlist_notifier.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:wildberries/widgets/allWidgets.dart';

// final db = FirebaseFirestore.instance;
var id = '';
final String productsApiUrl = "https://wild-grocery.herokuapp.com/api/product";

final String filtersApiUrl = "https://wild-grocery.herokuapp.com/api/filters";

String subCategoryAPIUrl = 'https://wild-grocery.herokuapp.com/api/subcategory';
String leafCategoryAPIUrl =
    'https://wild-grocery.herokuapp.com/api/leafcategory';

final String ordersApiUrl =
    "https://wild-grocery.herokuapp.com/api/order/list/";

final String categoriesApiUrl =
    "https://wild-grocery.herokuapp.com/api/category";

Future<void> initPlatformState() async {
  Map<String, dynamic> deviceData;

  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.id}');

      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.model}');
      id = iosInfo.model;
    }
  } on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
  }
}

//Getting products
getProdProducts(ProductsNotifier productsNotifier) async {
  var result = await http.get(productsApiUrl);
  var data = json.decode(result.body);

  // print('API data');
  // print(data.toList()[0]);

  List<ProdProducts> _prodProductsList = [];
  data.toList().forEach((prodData) {
    ProdProducts prodProducts = ProdProducts.fromMap(prodData);

    _prodProductsList.add(prodProducts);
  });

  productsNotifier.productsList = _prodProductsList;
}

getCat(CategoryNotifier categoryNotifier) async {
  var result = await http.get(categoriesApiUrl);
  var data = json.decode(result.body);

  List<Cat> _cat = [];
  data.toList().forEach((catData) {
    Cat c = Cat.fromMap(catData);

    _cat.add(c);
  });

  categoryNotifier.productsList = _cat;
}

getFilters(FiltersNotifier filtersNotifier) async {
  var result = await http.get(filtersApiUrl);
  var data = json.decode(result.body);

  List<Filter> _filters = [];

  data.toList().forEach((filterData) {
    Filter c = Filter.fromMap(filterData);

    _filters.add(c);
  });

  filtersNotifier.filtersList = _filters;
}

getSubCategories(SubCategoryNotifier subCategoryNotifier) async {
  var result = await http.get(subCategoryAPIUrl);
  var data = json.decode(result.body);

  List<SubCategory> _subCats = [];

  data.toList().forEach((subCatData) {
    SubCategory c = SubCategory.fromMap(subCatData);
    print(c.name);
    _subCats.add(c);
    // print('API Result ${_subCats.length}');
  });

  subCategoryNotifier.subCatsList = _subCats;
}

getLeafCategories(LeafCategoryNotifier leafCategoryNotifier) async {
  var result = await http.get(leafCategoryAPIUrl);
  var data = json.decode(result.body);

  List<LeafCategory> _leafCats = [];

  data.toList().forEach((leafCatData) {
    LeafCategory c = LeafCategory.fromMap(leafCatData);

    _leafCats.add(c);
    // print('API Result ${_leafCats.length}');
  });

  leafCategoryNotifier.leafCatsList = _leafCats;
}

//Adding users' product to cart
addProductToCart(Cart cartItem, _scaffoldKey) async {
  analytics.logAddToCart(
    itemId: cartItem.id,
    itemName: cartItem.name,
    itemCategory: cartItem.category['name'],
    quantity: cartItem.cartQuantity,
    price: cartItem.selling_price * 1.0,
    value: cartItem.selling_price * 1.0,
    currency: 'INR',
  );

  //Getting Current cart items
  final Preference<String> musicsString = await preferences.getString(
    'cart',
    defaultValue: '',
  );
  List<Cart> cartItems = [];
  await musicsString.listen((value) {
    if (value != '') cartItems = Cart.decode(value);
  });

  // print('Decoded Data ${cartItems}');
  // print(cartItems);
  bool flag = false;
  for (int i = 0; i < cartItems.length; i++) {
    if (cartItems[i].id == cartItem.id) {
      showSimpleSnack(
        "Product already in bag",
        Icons.warning_amber_rounded,
        Colors.yellow,
        _scaffoldKey,
      );
      flag = true;
    }
  }
  if (flag == false) {
    cartItems.add(cartItem);

    showSimpleSnack(
      "Product added to bag",
      Icons.check_circle_outline,
      Colors.green,
      _scaffoldKey,
    );
  }

  // Encode and store data in SharedPreferences
  final String encodedData = Cart.encode(cartItems);

  await preferences.setString('cart', encodedData).then((value) {
    // print('Cart Item Updated');
  }).catchError((e) {
    print('Error $e');
  });
  // print('Encoded Data $encodedData');
}

addProductToWishlist(ProdProducts product, _scaffoldKey) async {
  //Getting Current cart items
  analytics.logAddToWishlist(
    itemId: product.id,
    itemName: product.name,
    itemCategory: product.category['name'],
    price: product.selling_price * 1.0,
    value: product.selling_price * 1.0,
    currency: 'INR',
  );
  final Preference<String> musicsString = await preferences.getString(
    'wishlist',
    defaultValue: '',
  );
  List<ProdProducts> wishlistItems = [];
  await musicsString.listen((value) {
    if (value != '') wishlistItems = ProdProducts.decode(value);
  });

  // print('Decoded Data ${cartItems}');
  // print(cartItems);
  bool flag = false;
  for (int i = 0; i < wishlistItems.length; i++) {
    if (wishlistItems[i].id == product.id) {
      showSimpleSnack(
        "Product already in wishlist",
        Icons.warning_amber_rounded,
        Colors.yellow,
        _scaffoldKey,
      );
      flag = true;
    }
  }
  if (flag == false) {
    wishlistItems.add(product);

    showSimpleSnack(
      "Product added to wishlist",
      Icons.check_circle_outline,
      Colors.green,
      _scaffoldKey,
    );
  }

  // Encode and store data in SharedPreferences
  final String encodedData = ProdProducts.encode(wishlistItems);

  await preferences.setString('wishlist', encodedData).then((value) {
    // print('Cart Item Updated');
  }).catchError((e) {
    print('Error $e');
  });
  // print('Encoded Data $encodedData');
}

//Getting brands
getBrands(BrandsNotifier brandsNotifier) async {
  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("brands").get();
  //
  // List<Brands> _brandsList = [];
  //
  // snapshot.docs.forEach((document) {
  //   Brands brands = Brands.fromMap(document.data());
  //   _brandsList.add(brands);
  // });
  //
  // brandsNotifier.brandsList = _brandsList;
  // print(_brandsList);
}

//Getting bannersAds
getBannerAds(BannerAdNotifier bannerAdNotifier) async {
  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("bannerAds").get();
  //
  // List<BannerAds> _bannerAdsList = [];
  //
  // snapshot.docs.forEach((document) {
  //   BannerAds bannerAds = BannerAds.fromMap(document.data());
  //   _bannerAdsList.add(bannerAds);
  // });
  //
  // bannerAdNotifier.bannerAdsList = _bannerAdsList;
  // print(_bannerAdsList);
}

//Getting users' cart
getCart(CartNotifier cartNotifier) async {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();

  //Getting Current cart items
  final Preference<String> musicsString =
      await preferences.getString('cart', defaultValue: '');
  musicsString.listen((value) {
    if (value != '') {
      final List<Cart> cartItems = Cart.decode(value);
      cartNotifier.cartList = cartItems;
    }
  });
}

//Getting users' wishlist
getWishlist(WishlistNotifier wishlistNotifier) async {
  final Preference<String> musicsString =
      await preferences.getString('wishlist', defaultValue: '');
  musicsString.listen((value) {
    if (value != '') {
      final List<ProdProducts> wishlistItems = ProdProducts.decode(value);
      wishlistNotifier.wishList = wishlistItems;
    }
  });
}

//Adding item quantity, Price and updating data in cart
addAndUpdateData(Cart cartItem, _scaffoldKey, List<Cart> cartList) async {
  final Preference<String> musicString =
      await preferences.getString('cart', defaultValue: '');
  musicString.listen((value) {
    if (value != '') {
      final List<Cart> cartItems = Cart.decode(value);
      // print(cartItems.length);
    }
  });
  cartList.remove(cartItem);
  int cartQuantity = cartItem.cartQuantity;
  cartItem.cartQuantity = cartQuantity + 1;
  cartList.add(cartItem);
  final String encodedData = Cart.encode(cartList);

  await preferences.setString('cart', encodedData).then((value) {
    // print('Cart Item Updated');
  }).catchError((e) {
    print('Error $e');
  });
  final Preference<String> musicsString =
      await preferences.getString('cart', defaultValue: '');
  musicsString.listen((value) {
    if (value != '') {
      final List<Cart> cartItems = Cart.decode(value);
      // print(cartItems.length);
    }
  });
}

//Adding item quantity, Price and updating data in cart
subAndUpdateData(Cart cartItem, _scaffoldKey, List<Cart> cartList) async {
  final Preference<String> musicString =
      await preferences.getString('cart', defaultValue: '');
  musicString.listen((value) {
    if (value != '') {
      final List<Cart> cartItems = Cart.decode(value);
      // print(cartItems.length);
    }
  });
  cartList.remove(cartItem);
  int cartQuantity = cartItem.cartQuantity;
  cartItem.cartQuantity = cartQuantity - 1;
  cartList.add(cartItem);
  final String encodedData = Cart.encode(cartList);

  await preferences.setString('cart', encodedData).then((value) {
    // print('Cart Item Updated');
  }).catchError((e) {
    print('Error $e');
  });
  final Preference<String> musicsString =
      await preferences.getString('cart', defaultValue: '');
  musicsString.listen((value) {
    if (value != '') {
      final List<Cart> cartItems = Cart.decode(value);
      // print(cartItems.length);
    }
  });
}

//Removing item from cart
removeItemFromCart(Cart cartItem, _scaffoldKey) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  //Getting Current cart items
  final Preference<String> musicsString =
      await preferences.getString('cart', defaultValue: '');
  analytics.logRemoveFromCart(
    itemId: cartItem.id,
    itemName: cartItem.name,
    itemCategory: cartItem.category['name'],
    price: cartItem.selling_price * 1.0,
    value: cartItem.selling_price * 1.0,
    currency: 'INR',
  );
  musicsString.listen((value) async {
    List<Cart> cartItems = [];
    if (value != '') cartItems = Cart.decode(value);
    bool flag = false;
    for (int i = 0; i < cartItems.length; i++) {
      if (cartItems[i].id == cartItem.id) {
        await cartItems.removeWhere((crItem) => crItem.id == cartItem.id);
        // print('cart ${cartItems}');
        showSimpleSnack(
          "Product removed from cart",
          Icons.check_circle_outline,
          Colors.green,
          _scaffoldKey,
        );
        flag = true;
      }
    }
    if (flag == false) {
      // cartItems.add(cartItem);

      showSimpleSnack(
        "Product not found in cart",
        Icons.warning_amber_outlined,
        Colors.yellow,
        _scaffoldKey,
      );
    }
    final String encodedData = Cart.encode(cartItems);
    await preferences.setString('cart', encodedData).then((value) {
      // print('Cart Item Updated');
    }).catchError((e) {
      print('Error $e');
    });
  });

  // print('Decoded Data ${cartItems}');
  // print(cartItems);

  // print('Encoded Data $encodedData');
}

//Removing item from cart
removeItemFromWishlist(ProdProducts product, _scaffoldKey) async {
  //Getting Current cart items
  final Preference<String> musicsString =
      await preferences.getString('wishlist', defaultValue: '');

  musicsString.listen((value) async {
    List<ProdProducts> wishlistItems = [];
    if (value != '') wishlistItems = ProdProducts.decode(value);
    bool flag = false;
    for (int i = 0; i < wishlistItems.length; i++) {
      if (wishlistItems[i].id == product.id) {
        await wishlistItems.removeWhere((crItem) => crItem.id == product.id);
        // print('cart ${cartItems}');
        showSimpleSnack(
          "Product removed from wishlist",
          Icons.check_circle_outline,
          Colors.green,
          _scaffoldKey,
        );
        flag = true;
      }
    }
    if (flag == false) {
      // cartItems.add(cartItem);

      showSimpleSnack(
        "Product not found in wishlist",
        Icons.warning_amber_outlined,
        Colors.yellow,
        _scaffoldKey,
      );
    }
    final String encodedData = ProdProducts.encode(wishlistItems);
    await preferences.setString('wishlist', encodedData).then((value) {
      // print('Wishlist Item Updated');
    }).catchError((e) {
      print('Error $e');
    });
  });

  // print('Decoded Data ${cartItems}');
  // print(cartItems);

  // print('Encoded Data $encodedData');
}

//Clearing users' cart
clearCartAfterPurchase() async {
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // await db
  //     .collection('userCart')
  //     .doc(uEmail)
  //     .collection("cartItems")
  //     .get()
  //     .then((snapshot) {
  //   for (DocumentSnapshot doc in snapshot.docs) {
  //     doc.reference.delete();
  //   }
  // });
}

//Adding users' product to cart
addCartToOrders(cartList, orderID, address, date, orderType, time) async {
  // final uEmail = await AuthService().getCurrentEmail();
  // var orderDate = FieldValue.serverTimestamp();
  //
  // var orderStatus = "processing";
  // var shippingAddress = address;
  //
  // await db
  //     .collection("userOrder")
  //     .doc(uEmail)
  //     .collection("orders")
  //     .doc(orderID)
  //     .set(
  //   {
  //     'orderID': orderID,
  //     'orderDate': orderDate,
  //     'orderStatus': orderStatus,
  //     'shippingAddress': shippingAddress,
  //     'order': cartList.map((i) => i.toMap()).toList(),
  //     'deliveryDate': date,
  //     'deliveryTime': time,
  //     'orderType': orderType
  //   },
  // ).catchError((e) {
  //   print(e);
  // });
  //
  // //Sending orders to merchant
  // await db
  //     .collection("merchantOrder")
  //     .doc(uEmail)
  //     .collection("orders")
  //     .doc(orderID)
  //     .set(
  //   {
  //     'orderID': orderID,
  //     'orderDate': orderDate,
  //     'shippingAddress': shippingAddress,
  //     'order': cartList.map((i) => i.toMap()).toList(),
  //     'deliveryDate': date,
  //     'deliveryTime': time,
  //     'orderType': orderType
  //   },
  // ).catchError((e) {
  //   print(e);
  // });
}

//Getting users' orders
getOrders(OrderListNotifier orderListNotifier, UserDataProfile user) async {
  var result = await http.get('$ordersApiUrl${user.id}',
      headers: {'Authorization': 'Bearer ${user.token}'});
  var data = json.decode(result.body);

  // print('API data');
  // print(data.toList()[0]);

  List<Order> _ordersList = [];
  data.toList().forEach((orderData) {
    Order order = Order.fromMap(orderData);

    _ordersList.add(order);
  });

  orderListNotifier.orderListList = _ordersList;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // QuerySnapshot ordersSnapshot =
  //     await db.collection("userOrder").doc(uEmail).collection("orders").get();
  //
  // List<OrdersList> _ordersListList = [];
  //
  // ordersSnapshot.docs.forEach((document) {
  //   OrdersList ordersList = OrdersList.fromMap(document.data());
  //   _ordersListList.add(ordersList);
  // });
  // orderListNotifier.orderListList = _ordersListList;
}
