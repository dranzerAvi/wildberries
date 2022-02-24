import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../main.dart';

//factcheck,rule
List<PersistentBottomNavBarItem> navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ("Home"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
  PersistentBottomNavBarItem(
    icon: Container(
        child: Stack(
      children: [
        Icon(Icons.shopping_bag_outlined),
        PreferenceBuilder<String>(
            preference: preferences.getString(
              'cart',
              defaultValue: '',
            ),
            builder: (BuildContext context, String counter) {
              print(counter);
              var cartTotal = 0;

              List<Cart> cartList = [];
              if (counter != '') cartList = Cart.decode(counter);
              cartList.forEach((element) {
                cartTotal =
                    cartTotal + (element.cartQuantity * element.selling_price);
              });
              if (cartList.length == 0) cartTotal = 0;

              return Material(
                  color: Colors.transparent,
                  child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        color: Colors.red,
                      ),
                      child: Center(
                          child: Text(
                        cartList.length.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ))));
            }),
      ],
    )),
    title: ("Cart"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
  // PersistentBottomNavBarItem(
  //   icon: Icon(Icons.category_outlined),
  //   title: ("Categories"),
  //   activeColor: Colors.white,
  //   inactiveColor: Colors.white.withOpacity(0.5),
  // ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.person),
    title: ("Settings"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
];
