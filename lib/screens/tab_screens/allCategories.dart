import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeSubCategories.dart';
import 'package:wildberries/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'homeScreen_pages/seeAllInCategory.dart';
import 'homeScreen_pages/sizeSelectorScreen.dart';

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

  UserDataProfile user;

  getUser() async {
    final Preference<String> userData =
        await preferences.getString('user', defaultValue: '');
    // userData.listen((value) {
    //   print('User $value');
    // });
    userData.listen((value) async {
      if (value == null) {
        user = UserDataProfile.fromMap(json.decode(value));
      }
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    CategoryNotifier categoriesNotifier =
        Provider.of<CategoryNotifier>(context);

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);
    return Scaffold(
        key: _primaryscaffoldKey,
        floatingActionButton: CustomFloatingButton(
            CurrentScreen(currentScreen: AllCategories(), tab_no: 0)),
        drawer: CustomDrawer(user, productsNotifier.productsList, {}, {}),
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
            'Wildberries',
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
                            getCat(categoriesNotifier);
                            Iterable<Cat> categories =
                                await categoriesNotifier.catList;
                            categorySpecificProducts = await allProducts
                                .where((e) => e.category['name'] == 'Fish');
                            print('-------${categorySpecificProducts}');
                            for (var v in allProducts) {
                              print(v.category);
                            }
                            var _prods = categorySpecificProducts.toList();
                            var currentCategory;
                            List<Cat> catList = categories.toList();

                            for (var v in catList) {
                              if (v.name == 'Dogs') {
                                currentCategory = await v;
                              }
                            }
                            var navigationResult =
                                await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => SeeSubCategories(
                                  category: currentCategory,
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
                                        'https://firebasestorage.googleapis.com/v0/b/wildberries-3387f.appspot.com/o/Categories%2FDog%20-%20Category.jpg?alt=media&token=36f005d0-4b3c-4ccc-9794-0cecfa514fe9'),
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
                            getCat(categoriesNotifier);
                            Iterable<Cat> categories =
                                await categoriesNotifier.catList;
                            categorySpecificProducts = await allProducts
                                .where((e) => e.category['name'] == 'Fish');
                            print('-------${categorySpecificProducts}');
                            for (var v in allProducts) {
                              print(v.category);
                            }
                            var _prods = categorySpecificProducts.toList();
                            var currentCategory;
                            List<Cat> catList = categories.toList();

                            for (var v in catList) {
                              if (v.name == 'Cats') {
                                currentCategory = await v;
                              }
                            }
                            var navigationResult =
                                await Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => SeeSubCategories(
                                  category: currentCategory,
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
                                        'https://firebasestorage.googleapis.com/v0/b/wildberries-3387f.appspot.com/o/Categories%2FCat%20-%20Category.jpg?alt=media&token=9d01fcb2-2152-47a1-899c-3edd377fde99'),
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
                          getCat(categoriesNotifier);
                          Iterable<Cat> categories =
                              await categoriesNotifier.catList;
                          categorySpecificProducts = await allProducts
                              .where((e) => e.category['name'] == 'Fish');
                          print('-------${categorySpecificProducts}');
                          for (var v in allProducts) {
                            print(v.category);
                          }
                          var _prods = categorySpecificProducts.toList();
                          var currentCategory;
                          List<Cat> catList = categories.toList();

                          for (var v in catList) {
                            if (v.name == 'Rabbits') {
                              currentCategory = await v;
                            }
                          }
                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeSubCategories(
                                category: currentCategory,
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
                          getCat(categoriesNotifier);
                          Iterable<Cat> categories =
                              await categoriesNotifier.catList;
                          categorySpecificProducts = await allProducts
                              .where((e) => e.category['name'] == 'Fish');
                          print('-------${categorySpecificProducts}');
                          for (var v in allProducts) {
                            print(v.category);
                          }
                          var _prods = categorySpecificProducts.toList();
                          var currentCategory;
                          List<Cat> catList = categories.toList();

                          for (var v in catList) {
                            if (v.name == 'Birds') {
                              currentCategory = await v;
                            }
                          }
                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeSubCategories(
                                category: currentCategory,
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
                                      'https://firebasestorage.googleapis.com/v0/b/wildberries-3387f.appspot.com/o/Categories%2FBird%20-%20Category.jpg?alt=media&token=16681749-72a9-4b02-b4ab-d078eed8bb61'),
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
                          getCat(categoriesNotifier);
                          Iterable<Cat> categories =
                              await categoriesNotifier.catList;
                          categorySpecificProducts = await allProducts
                              .where((e) => e.category['name'] == 'Fish');
                          print('-------${categorySpecificProducts}');
                          for (var v in allProducts) {
                            print(v.category);
                          }
                          var _prods = categorySpecificProducts.toList();
                          var currentCategory;
                          List<Cat> catList = categories.toList();

                          for (var v in catList) {
                            if (v.name == 'Hamsters') {
                              currentCategory = await v;
                            }
                          }
                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeSubCategories(
                                category: currentCategory,
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
                          getCat(categoriesNotifier);
                          Iterable<Cat> categories =
                              await categoriesNotifier.catList;
                          categorySpecificProducts = await allProducts
                              .where((e) => e.category['name'] == 'Fish');
                          print('-------${categorySpecificProducts}');
                          for (var v in allProducts) {
                            print(v.category);
                          }
                          var _prods = categorySpecificProducts.toList();
                          var currentCategory;
                          List<Cat> catList = categories.toList();

                          for (var v in catList) {
                            if (v.name == 'Others') {
                              currentCategory = await v;
                            }
                          }
                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeSubCategories(
                                category: currentCategory,
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
