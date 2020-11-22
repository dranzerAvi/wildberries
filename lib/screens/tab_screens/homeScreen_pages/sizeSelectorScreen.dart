import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/seeAllInCategory.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/seeSubCategories.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/custom_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bag.dart';

class SizeSelection extends StatefulWidget {
  final String title;
  final Cat category;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  SizeSelection({
    Key key,
    this.title,
    this.category,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
  }) : super(key: key);

  @override
  _SizeSelectionState createState() => _SizeSelectionState(
      title, category, cartNotifier, productsNotifier, cartProdID);
}

class _SizeSelectionState extends State<SizeSelection> {
  final String title;
  final Cat category;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  _SizeSelectionState(
    this.title,
    this.category,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
  );
  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?   phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  List cats = [];

  void initState() {
    // cats = widget.categories.toList();
    // print('---------------${widget.categories}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cartList = cartNotifier.cartList;

    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 20,
            color: MColors.secondaryColor,
          ),
          backgroundColor: MColors.mainColor,
          leading: InkWell(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            InkWell(
                onTap: () {
                  launch('tel:+919027553376');
                },
                child: Icon(
                  Icons.phone,
                )),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
                  launchWhatsApp(
                      phone: '7060222315',
                      message: 'Check out this awesome app');
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp))),
            SizedBox(
              width: 8,
            ),
            InkWell(
              onTap: () {
                launch(
                    'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
              },
              child: Icon(
                Icons.mail,
              ),
            ),
            SizedBox(
              width: 14,
            )
          ],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Misterpet.ae',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: CustomFloatingButton(
            CurrentScreen(currentScreen: SizeSelection(), tab_no: 0)),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Choose Product Size',
                      style: TextStyle(
                          color: MColors.secondaryColor,
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: GridView.count(
                          physics: BouncingScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 15.0,
                          crossAxisSpacing: 15.0,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'XS',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'S',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'M',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'L',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'XL',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => SeeSubCategories(
                                      title: title,
                                      category: category,
                                      productsNotifier: productsNotifier,
                                      cartNotifier: cartNotifier,
                                      cartProdID: cartProdID,
                                    ),
                                  ),
                                );
                                if (navigationResult == true) {
                                  getCart(cartNotifier);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.03),
                                        offset: Offset(0, 10),
                                        blurRadius: 10,
                                        spreadRadius: 0),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Text(
                                      'XXL',
                                      style: TextStyle(
                                          color: MColors.secondaryColor,
                                          fontSize: 25,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              )),
        ));
  }
}
