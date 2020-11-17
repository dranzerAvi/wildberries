import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/productDetailsScreen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';

class SearchTabWidget extends StatefulWidget {
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final Iterable<ProdProducts> prods;

  SearchTabWidget({
    Key key,
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
    this.prods,
  }) : super(key: key);

  @override
  _SearchTabWidgetState createState() => _SearchTabWidgetState(
        cartNotifier,
        productsNotifier,
        cartProdID,
        prods,
      );
}

class _SearchTabWidgetState extends State<SearchTabWidget> {
  _SearchTabWidgetState(
    this.cartNotifier,
    this.productsNotifier,
    this.cartProdID,
    this.prods,
  );
  CartNotifier cartNotifier;
  ProductsNotifier productsNotifier;
  Iterable<String> cartProdID;
  Iterable<ProdProducts> prods;
  var cleanList;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> dialogKey = GlobalKey<ScaffoldState>();
  bool showSort;
  int choice;
  @override
  void initState() {
    showSort = false;
    choice = 0;
    cleanList = prods.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height) / 2.5;
    final double itemWidth = size.width / 2;
    double _picHeight;

    if (itemHeight >= 315) {
      _picHeight = itemHeight / 2;
    } else if (itemHeight <= 315 && itemHeight >= 280) {
      _picHeight = itemHeight / 2.2;
    } else if (itemHeight <= 280 && itemHeight >= 200) {
      _picHeight = itemHeight / 2.7;
    } else {
      _picHeight = 30;
    }

    // void showDialog() async {
    //   await showCupertinoDialog(
    //       context: context,
    //       builder: (context) {
    //         var choice = 0;
    //         return CupertinoAlertDialog(
    //           content: Container(
    //             height: 100,
    //             child: Scaffold(
    //               key: dialogKey,
    //               backgroundColor: Colors.transparent,
    //               body: Center(
    //                 child: Column(
    //                   children: [
    //                     InkWell(
    //                       onTap: () {
    //                         dialogKey.currentState.setState(() {
    //                           print(choice);
    //                           choice = 0;
    //                           print(choice);
    //                         });
    //                       },
    //                       child: Container(
    //                         color: choice == 0
    //                             ? MColors.mainColor
    //                             : MColors.primaryWhiteSmoke,
    //                         child: Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Text(
    //                             "Price- Highest to Lowest",
    //                             style: normalFont(MColors.textDark, null),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                     InkWell(
    //                       onTap: () {
    //                         dialogKey.currentState.setState(() {
    //                           print(choice);
    //                           choice = 1;
    //                           print(choice);
    //                         });
    //                       },
    //                       child: Container(
    //                         color: choice == 1
    //                             ? MColors.mainColor
    //                             : MColors.primaryWhiteSmoke,
    //                         child: Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Text(
    //                             "Price- Lowest to Highest",
    //                             style: normalFont(MColors.textDark, null),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //           actions: <Widget>[
    //             CupertinoDialogAction(
    //               child: Text(
    //                 "Cancel",
    //                 style: normalFont(Colors.red, null),
    //               ),
    //               onPressed: () async {
    //                 getCart(cartNotifier);
    //
    //                 Navigator.of(context).pop();
    //               },
    //             ),
    //             CupertinoDialogAction(
    //               isDefaultAction: true,
    //               child: Text(
    //                 "Yes",
    //                 style: normalFont(Colors.blue, null),
    //               ),
    //               onPressed: () {
    //                 Navigator.of(context).pop();
    //               },
    //             ),
    //           ],
    //         );
    //       });
    // }

    return Scaffold(
      key: scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () => getProdProducts(productsNotifier),
        child: Column(
          children: [
            Container(
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (showSort == false) {
                            setState(() {
                              showSort = true;
                            });
                            print(showSort);
                          } else if (showSort == true) {
                            setState(() {
                              showSort = false;
                            });
                            print(showSort);
                          } else if (showSort == null) {
                            print(showSort);
                          }
                        },
                        child: Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [Icon(Icons.sort), Text('Sort')],
                        )),
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [Icon(Icons.filter_alt), Text('Filter')],
                      )),
                    ),
                  ],
                )),
            showSort == true
                ? Container(
                    height: 100,
                    child: Center(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              var newList = prods.toList();

                              newList
                                  .sort((a, b) => b.price.compareTo(a.price));
                              setState(() {
                                cleanList = newList;

                                choice = 0;
                                print(choice);
                              });
                              for (var v in cleanList) {
                                print(v.name);
                              }
                            },
                            child: Container(
                              color: choice == 0
                                  ? MColors.mainColor
                                  : MColors.primaryWhiteSmoke,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Price- Highest to Lowest",
                                  style: normalFont(MColors.textDark, null),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () {
                              var newList = prods.toList();

                              newList
                                  .sort((a, b) => a.price.compareTo(b.price));
                              setState(() {
                                cleanList = newList;

                                choice = 1;
                                print(choice);
                              });
                              for (var v in cleanList) {
                                print(v.name);
                              }
                            },
                            child: Container(
                              color: choice == 1
                                  ? MColors.mainColor
                                  : MColors.primaryWhiteSmoke,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Price- Lowest to Highest",
                                  style: normalFont(MColors.textDark, null),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            Expanded(
              child: primaryContainer(GridView.count(
                physics: BouncingScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: (itemWidth / itemHeight),
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                children: List<Widget>.generate(prods.length, (i) {
                  var product = cleanList[i];

                  return GestureDetector(
                    onTap: () async {
                      var navigationResult = await Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) =>
                              ProductDetailsProv(product, prods),
                        ),
                      );
                      if (navigationResult == true) {
                        setState(() {
                          getCart(cartNotifier);
                        });
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
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Hero(
                                child: FadeInImage.assetNetwork(
                                  image: product.productImage,
                                  fit: BoxFit.fill,
                                  height: _picHeight,
                                  placeholder: "assets/images/placeholder.jpg",
                                  placeholderScale:
                                      MediaQuery.of(context).size.height / 2,
                                ),
                                tag: product.productID,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: normalFont(MColors.textGrey, 14.0),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    "\$${product.price}",
                                    style:
                                        boldFont(MColors.primaryPurple, 20.0),
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () => () {
                                    addToBagshowDialog(product);
                                    HapticFeedback.heavyImpact();
                                  }(),
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: MColors.dashPurple,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/images/icons/basket.svg",
                                      height: 22.0,
                                      color: MColors.textGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void addToBagshowDialog(
    _product,
  ) async {
    await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text(
              "Sure you want to add to Bag?",
              style: normalFont(MColors.textDark, null),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  "Cancel",
                  style: normalFont(Colors.red, null),
                ),
                onPressed: () async {
                  setState(() {
                    getCart(cartNotifier);
                  });
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(
                  "Yes",
                  style: normalFont(Colors.blue, null),
                ),
                onPressed: () {
                  setState(() {
                    getCart(cartNotifier);
                  });
                  if (cartProdID.contains(_product.productID)) {
                    showSimpleSnack(
                      "Product already in bag",
                      Icons.error_outline,
                      Colors.amber,
                      scaffoldKey,
                    );
                  } else {
                    addProductToCart(_product);
                    showSimpleSnack(
                      "Product added to bag",
                      Icons.check_circle_outline,
                      Colors.green,
                      scaffoldKey,
                    );
                    setState(() {
                      getCart(cartNotifier);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
