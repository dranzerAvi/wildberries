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
import 'package:mrpet/screens/tab_screens/homeScreen_pages/sizeSelectorScreen.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/custom_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bag.dart';

class SeeSubCategories extends StatefulWidget {
  final String title;
  final Cat category;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  SeeSubCategories({
    Key key,
    this.title,
    this.category,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
  }) : super(key: key);

  @override
  _SeeSubCategoriesState createState() => _SeeSubCategoriesState(
      title, category, cartNotifier, productsNotifier, cartProdID);
}

class _SeeSubCategoriesState extends State<SeeSubCategories> {
  final String title;
  final Cat category;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;

  _SeeSubCategoriesState(
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
            CurrentScreen(currentScreen: SeeSubCategories(), tab_no: 0)),
        body: widget.category.sCat != null
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: primaryContainer(GridView.count(
                    physics: BouncingScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 15.0,
                    crossAxisSpacing: 15.0,
                    children:
                        List<Widget>.generate(widget.category.sCat.length, (i) {
                      return GestureDetector(
                        onTap: () async {
                          var title = category.name.toUpperCase();
                          Iterable<ProdProducts> allProducts =
                              productsNotifier.productsList;
                          Iterable<ProdProducts> categorySpecificProducts;
                          if (category.name == 'Dogs') {
                            categorySpecificProducts =
                                allProducts.where((e) => e.pet == 'dog');
                          } else if (category.name == 'Cats') {
                            categorySpecificProducts =
                                allProducts.where((e) => e.pet == 'cat');
                          } else if (category.name == 'Birds') {
                            categorySpecificProducts =
                                allProducts.where((e) => e.pet == 'bird');
                          }

                          for (var v in allProducts) {
                            print(v.pet);
                            print(category.name);
                          }

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SizeSelection(
                                title: title,
                                category: category,
                                productsNotifier: productsNotifier,
                                subCategory: widget.category.sCat[i],
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
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: FadeInImage.assetNetwork(
                                      image: widget.category.sCat[i]['sCatURL'],
                                      fit: BoxFit.fill,
                                      // height: 200,
                                      placeholder:
                                          "assets/images/placeholder.jpg",
                                      placeholderScale:
                                          MediaQuery.of(context).size.height /
                                              2,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Container(
                                child: Text(
                                  widget.category.sCat[i]['sCatName'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: boldFont(MColors.textDark, 16.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  )),
                ))
            : Container());
  }
}
