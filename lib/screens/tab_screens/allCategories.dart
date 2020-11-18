import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/custom_floating_button.dart';
import 'package:mrpet/widgets/navDrawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'homeScreen_pages/seeAllInCategory.dart';

class AllCategories extends StatefulWidget {
  String from;
  AllCategories({this.from});
  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

final GlobalKey<ScaffoldState> _primaryscaffoldKey = GlobalKey<ScaffoldState>();

class _AllCategoriesState extends State<AllCategories> {
  _AllCategoriesState();
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

  @override
  Widget build(BuildContext context) {
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.productID);
    return Scaffold(
        key: _primaryscaffoldKey,
        floatingActionButton: CustomFloatingButton(
            CurrentScreen(currentScreen: AllCategories(), tab_no: 0)),
        drawer: CustomDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 20,
            color: MColors.secondaryColor,
          ),
          backgroundColor: MColors.mainColor,
          leading: widget.from != null
              ? InkWell(
                  child: Icon(Icons.arrow_back_ios),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              : IconButton(
                  icon: Icon(Icons.menu),
                  color: MColors.secondaryColor,
                  onPressed: () {
                    _primaryscaffoldKey.currentState.openDrawer();
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
//                print(1);
                  launch(
                      'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
                },
                child: Icon(
                  Icons.mail,
                )),
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
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            Iterable<ProdProducts> allProducts =
                                productsNotifier.productsList;
                            Iterable<ProdProducts> categorySpecificProducts;

                            categorySpecificProducts =
                                allProducts.where((e) => e.pet == 'dog');

                            for (var v in allProducts) {
                              print(v.pet);
                              // print(product.name);
                            }
                            var _prods = categorySpecificProducts.toList();

                            var navigationResult =
                                await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => SeeAllInCategory(
                                  title: 'DOGS',
                                  products: _prods,
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
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/mrpet-3387f.appspot.com/o/Categories%2FDog%20-%20Category.jpg?alt=media&token=36f005d0-4b3c-4ccc-9794-0cecfa514fe9'),
                                  ),
                                ),
                              ),
                              Text(
                                'FOR DOGS',
                                style: boldFont(MColors.textDark, 16.0),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () async {
                            Iterable<ProdProducts> allProducts =
                                productsNotifier.productsList;
                            Iterable<ProdProducts> categorySpecificProducts;

                            categorySpecificProducts =
                                allProducts.where((e) => e.pet == 'cat');

                            for (var v in allProducts) {
                              print(v.pet);
                              // print(product.name);
                            }
                            var _prods = categorySpecificProducts.toList();

                            var navigationResult =
                                await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => SeeAllInCategory(
                                  title: 'CATS',
                                  products: _prods,
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
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/mrpet-3387f.appspot.com/o/Categories%2FCat%20-%20Category.jpg?alt=media&token=9d01fcb2-2152-47a1-899c-3edd377fde99'),
                                  ),
                                ),
                              ),
                              Text(
                                'FOR CATS',
                                style: boldFont(MColors.textDark, 16.0),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Iterable<ProdProducts> allProducts =
                              productsNotifier.productsList;
                          Iterable<ProdProducts> categorySpecificProducts;

                          categorySpecificProducts =
                              allProducts.where((e) => e.pet == 'rabbit');

                          for (var v in allProducts) {
                            print(v.pet);
                            // print(product.name);
                          }
                          var _prods = categorySpecificProducts.toList();

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeAllInCategory(
                                title: 'RABBITS',
                                products: _prods,
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
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.network(
                                      'https://i.pinimg.com/originals/32/00/3b/32003bd128bebe99cb8c655a9c0f00f5.jpg'),
                                ),
                              ),
                            ),
                            Text(
                              'FOR RABBITS',
                              style: boldFont(MColors.textDark, 16.0),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Iterable<ProdProducts> allProducts =
                              productsNotifier.productsList;
                          Iterable<ProdProducts> categorySpecificProducts;

                          categorySpecificProducts =
                              allProducts.where((e) => e.pet == 'bird');

                          for (var v in allProducts) {
                            print(v.pet);
                            // print(product.name);
                          }
                          var _prods = categorySpecificProducts.toList();

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeAllInCategory(
                                title: 'BIRDS',
                                products: _prods,
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
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.network(
                                      'https://firebasestorage.googleapis.com/v0/b/mrpet-3387f.appspot.com/o/Categories%2FBird%20-%20Category.jpg?alt=media&token=16681749-72a9-4b02-b4ab-d078eed8bb61'),
                                ),
                              ),
                            ),
                            Text(
                              'FOR BIRDS',
                              style: boldFont(MColors.textDark, 16.0),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Iterable<ProdProducts> allProducts =
                              productsNotifier.productsList;
                          Iterable<ProdProducts> categorySpecificProducts;

                          categorySpecificProducts =
                              allProducts.where((e) => e.pet == 'hamster');

                          for (var v in allProducts) {
                            print(v.pet);
                            // print(product.name);
                          }
                          var _prods = categorySpecificProducts.toList();

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeAllInCategory(
                                title: 'HAMSTERS',
                                products: _prods,
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
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.network(
                                      'https://i.dailymail.co.uk/i/pix/scaled/2014/08/19/1408408144228_wps_2_BEXAYR_Hamster.jpg'),
                                ),
                              ),
                            ),
                            Text(
                              'FOR HAMSTERS',
                              style: boldFont(MColors.textDark, 16.0),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Iterable<ProdProducts> allProducts =
                              productsNotifier.productsList;
                          Iterable<ProdProducts> categorySpecificProducts;

                          categorySpecificProducts =
                              allProducts.where((e) => e.pet == 'other');

                          for (var v in allProducts) {
                            print(v.pet);
                            // print(product.name);
                          }
                          var _prods = categorySpecificProducts.toList();

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeAllInCategory(
                                title: 'OTHER PRODUCTS',
                                products: _prods,
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
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.network(
                                      'https://shop-cdn-m.mediazs.com/bilder/perfect/maxi/small/pet/cage/5/400/57498_pla_kleintierkaefig_mit_57499_pla_zwischenebene_fg_1235_5.jpg'),
                                ),
                              ),
                            ),
                            Text(
                              'OTHER PRODUCTS',
                              style: boldFont(MColors.textDark, 16.0),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              )
            ],
          ),
        ));
  }
}
