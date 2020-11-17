import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';

import 'bag.dart';

class SeeAllInCategory extends StatefulWidget {
  final String title;
  final Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  SeeAllInCategory({
    Key key,
    this.title,
    this.products,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
  }) : super(key: key);

  @override
  _SeeAllInCategoryState createState() => _SeeAllInCategoryState(
      title, products, cartNotifier, productsNotifier, cartProdID);
}

class _SeeAllInCategoryState extends State<SeeAllInCategory> {
  final String title;
  final Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  _SeeAllInCategoryState(
    this.title,
    this.products,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
  );

  @override
  Widget build(BuildContext context) {
    var cartList = cartNotifier.cartList;

    return Scaffold(
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MColors.textGrey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          title,
          style: boldFont(MColors.primaryPurple, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        [
          Container(
            width: 50,
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: RawMaterialButton(
              onPressed: () async {
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => Bag(),
                  ),
                );
                if (navigationResult == true) {
                  setState(() {
                    getCart(cartNotifier);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        height: 25,
                        color: MColors.textGrey,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cartList.isNotEmpty
                              ? Colors.redAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 7,
                          minHeight: 7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SearchTabWidget(
        prods: products,
        cartNotifier: cartNotifier,
        productsNotifier: productsNotifier,
        cartProdID: cartProdID,
      ),
    );
  }
}
