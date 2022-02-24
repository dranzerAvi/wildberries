// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/filter.dart';
import 'package:wildberries/model/data/leafCategory.dart';
import 'package:wildberries/model/data/subCategory.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/filter_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/productDetailsScreen.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:http/http.dart' as http;

import '../dynamic_link_controller.dart';

class SearchTabWidget extends StatefulWidget {
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final Iterable<ProdProducts> prods;
  final String categoryId;

  SearchTabWidget(
      {Key key,
      this.cartNotifier,
      this.productsNotifier,
      this.cartProdID,
      this.prods,
      this.categoryId})
      : super(key: key);

  @override
  _SearchTabWidgetState createState() => _SearchTabWidgetState(
      cartNotifier, productsNotifier, cartProdID, prods, categoryId);
}

class _SearchTabWidgetState extends State<SearchTabWidget> {
  _SearchTabWidgetState(this.cartNotifier, this.productsNotifier,
      this.cartProdID, this.prods, this.categoryId);
  CartNotifier cartNotifier;
  String categoryId;
  ProductsNotifier productsNotifier;
  Iterable<String> cartProdID;
  Iterable<ProdProducts> prods;
  List<ProdProducts> cleanList;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> dialogKey = GlobalKey<ScaffoldState>();
  bool showSort;
  int choice;
  String filtersAPIUrl = 'https://wild-grocery.herokuapp.com/api/filters';
  String subCategoryAPIUrl =
      'https://wild-grocery.herokuapp.com/api/subcategory';
  String leafCategoryAPIUrl =
      'https://wild-grocery.herokuapp.com/api/leafcategory';
  @override
  void initState() {
    fetchFilters();
    showSort = false;
    choice = 0;
    cleanList = prods.toList();
    super.initState();
  }

  final DynamicLinkController _dynamicLinkController = DynamicLinkController();

  Map<String, List> filterValues = {};
  FiltersNotifier filtersNotifier = new FiltersNotifier();
  SubCategoryNotifier subCategoryNotifier = new SubCategoryNotifier();
  LeafCategoryNotifier leafCategoryNotifier = new LeafCategoryNotifier();
  List<Filter> filters = [];
  List<SubCategory> subCats = [];
  List<LeafCategory> leafCats = [];
  filterProductsList() async {
    await cleanList.clear();
    for (var v in prods) {
      int flag = 0;
      if (!filterValues.isEmpty) {
        if (filterValues['Sub Categories'] != null) {
          if (filterValues['Sub Categories'].contains(v.subCategory['name']))
            flag = 1;
        }

        if (filterValues['Leaf Categories'] != null) {
          if (filterValues['Leaf Categories'].contains(v.leafCategory['name']))
            flag = 1;
        }
        List productFilterValues = v.filterValue;

        productFilterValues.forEach((element) {
          if (filterValues[element['name']] != null) if (filterValues[
                  element['name']]
              .contains(element['value'])) flag = 1;
        });
      } else
        flag = 1;

      if (flag == 1) cleanList.add(v);
    }
  }

  List<String> subCatsNames = [];
  List<String> leafCatsNames = [];

  fetchFilters() async {
    await getFilters(filtersNotifier);
    // await getSubCategories(subCategoryNotifier);
    // await getLeafCategories(leafCategoryNotifier);

    subCats = subCategoryNotifier.subCatsList
        .where((element) => element.parentId == categoryId)
        .toList();
    for (var v in subCats) {
      // print(leafCategoryNotifier.leafCatsList);
      leafCats = leafCategoryNotifier.leafCatsList
          .where((element) => element.parentId == v.id)
          .toList();
    }
    leafCatsNames = await leafCats.map((e) => e.name).toList();
    filters = [
      //TODO:May Implement Category Filters
      // Filter('subCatFilter', 'Sub Categories', subCatsNames, type: 'SubCat'),
      // Filter('leafCatFilter', 'Leaf Categories', leafCatsNames, type: 'LeafCat')
    ];

    filters.addAll(filtersNotifier.filtersList);

    // setState(() {});
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
      drawer: filtersDrawer(),
      body: Column(
        children: [
          Container(
              color: MColors.dashPurple,
              height: 60,
              child: Row(
                children: [
                  // Expanded(
                  //   child: InkWell(
                  //     onTap: () {
                  //       if (showSort == false) {
                  //         setState(() {
                  //           showSort = true;
                  //         });
                  //         // print(showSort);
                  //       } else if (showSort == true) {
                  //         setState(() {
                  //           showSort = false;
                  //         });
                  //         // print(showSort);
                  //       } else if (showSort == null) {
                  //         // print(showSort);
                  //       }
                  //     },
                  //     child: Container(
                  //         child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       children: [
                  //         Icon(
                  //           Icons.sort,
                  //           color: MColors.mainColor,
                  //           size: 25,
                  //         ),
                  //         Text(
                  //           'Sort',
                  //           style: boldFont(MColors.mainColor, 18),
                  //         )
                  //       ],
                  //     )),
                  //   ),
                  // ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        scaffoldKey.currentState.openDrawer();
                      },
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Icon(
                          //   Icons.filter_alt,
                          //   color: MColors.mainColor,
                          //   size: 25,
                          // ),
                          Text(
                            'Filter Options',
                            style: boldFont(MColors.mainColor, 18),
                          )
                        ],
                      )),
                    ),
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

                            newList.sort((a, b) =>
                                b.selling_price.compareTo(a.selling_price));
                            setState(() {
                              cleanList = newList;

                              choice = 0;
                              // print(choice);
                            });
                            for (var v in cleanList) {
                              // print(v.name);
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
                                style: choice == 0
                                    ? normalFont(MColors.dashPurple, null)
                                    : normalFont(MColors.textDark, null),
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

                            newList.sort((a, b) =>
                                a.selling_price.compareTo(b.selling_price));
                            setState(() {
                              cleanList = newList;

                              choice = 1;
                              // print(choice);
                            });
                            for (var v in cleanList) {
                              // print(v.name);
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
                                style: choice == 1
                                    ? normalFont(MColors.dashPurple, null)
                                    : normalFont(MColors.textDark, null),
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
              childAspectRatio: (itemWidth / itemHeight) * 0.95,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              children: List<Widget>.generate(cleanList.length, (i) {
                var product = cleanList[i];

                return GestureDetector(
                  onTap: () async {
                    var navigationResult = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => ProductDetailsProv(
                            product, prods, _dynamicLinkController),
                      ),
                    );
                    if (navigationResult == true) {
                      getCart(cartNotifier);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.all(5.0),
                    width: 150.0,
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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: FadeInImage.assetNetwork(
                                  image:
                                      ('https://wild-grocery.herokuapp.com/${product.image}'),
                                  fit: BoxFit.fill,
                                  height: 150,
                                  placeholder: "assets/images/placeholder.jpg",
                                  placeholderScale:
                                      MediaQuery.of(context).size.height / 2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: MColors.dashPurple,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      '${((product.original_price - product.selling_price) / product.original_price * 100).toInt()}% OFF',
                                      style: boldFont(MColors.mainColor, 13),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: normalFont(MColors.textGrey, 15.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 7),
                              child: Text(
                                product.productQuantity.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: normalFont(MColors.textGrey, 15.0),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: MColors.dashPurple,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Spacer(),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                children: [
                                  Container(
                                    child: Text(
                                      "₹ ${product.selling_price}",
                                      style: boldFont(MColors.textDark, 18.0),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      "₹ ${product.selling_price}",
                                      style: boldFontStriked(
                                          MColors.textGrey, 15.0),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  getCart(cartNotifier);
                                  addProductToCart(
                                      Cart(
                                          id: product.id,
                                          name: product.name,
                                          selling_price: product.selling_price,
                                          category: product.category,
                                          specs: product.specs,
                                          productQuantity:
                                              product.productQuantity,
                                          original_price:
                                              product.original_price,
                                          quantity: product.quantity,
                                          image: product.image,
                                          imgcollection: product.imgcollection,
                                          filterValue: product.filterValue,
                                          description: product.description,
                                          prices: product.prices,
                                          cartQuantity: 1,
                                          sold: product.sold,
                                          tablespecs: product.tablespecs,
                                          varientID: product.varientID),
                                      scaffoldKey);
                                  // addAndApdateData(
                                  //     Cart(
                                  //         id: _product.id,
                                  //         name: _product.name,
                                  //         selling_price: _product.selling_price,
                                  //         category: _product.category,
                                  //         specs: _product.specs,
                                  //         productQuantity: _product.productQuantity,
                                  //         original_price: _product.original_price,
                                  //         quantity: _product.quantity,
                                  //         image: _product.image,
                                  //         imgcollection: _product.imgcollection,
                                  //         filterValue: _product.filterValue,
                                  //         description: _product.description,
                                  //         prices: _product.prices,
                                  //         cartQuantity: 1,
                                  //         sold: _product.sold,
                                  //         tablespecs: _product.tablespecs,
                                  //         varientID: _product.varientID),
                                  //     _scaffoldKey);
                                  getCart(cartNotifier);
                                  // Navigator.of(context).pop();

                                  // if (cartProdID.contains(_product.id)) {
                                  //   showSimpleSnack(
                                  //     "Product already in bag",
                                  //     Icons.error_outline,
                                  //     Colors.amber,
                                  //     scaffoldKey,
                                  //   );
                                  // } else {

                                  //
                                  // }
                                  // addToBagshowDialog(product,
                                  //   cartNotifier, cartProdID, _scaffoldKey);
                                },
                                child: Container(
                                  width: 45.0,
                                  height: 45.0,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: MColors.mainColor,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/images/icons/basket.svg",
                                    height: 20.0,
                                    color: MColors.primaryWhite,
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
                //   GestureDetector(
                //   onTap: () async {
                //     var navigationResult = await Navigator.of(context).push(
                //       CupertinoPageRoute(
                //         builder: (context) => ProductDetailsProv(
                //             product, prods, _dynamicLinkController),
                //       ),
                //     );
                //     if (navigationResult == true) {
                //       setState(() {
                //         getCart(cartNotifier);
                //       });
                //     }
                //   },
                //   child: Container(
                //     padding: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: MColors.primaryWhite,
                //       borderRadius: BorderRadius.all(
                //         Radius.circular(10.0),
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //             color: Color.fromRGBO(0, 0, 0, 0.03),
                //             offset: Offset(0, 10),
                //             blurRadius: 10,
                //             spreadRadius: 0),
                //       ],
                //     ),
                //     child: Column(
                //       children: <Widget>[
                //         Container(
                //           child: ClipRRect(
                //             borderRadius: BorderRadius.circular(10.0),
                //             child: Hero(
                //               child: FadeInImage.assetNetwork(
                //                 image:
                //                     'https://wild-grocery.herokuapp.com/${product.image}',
                //                 fit: BoxFit.fill,
                //                 height: _picHeight,
                //                 placeholder: "assets/images/placeholder.jpg",
                //                 placeholderScale:
                //                     MediaQuery.of(context).size.height / 2,
                //               ),
                //               tag: product.id,
                //             ),
                //           ),
                //         ),
                //         SizedBox(height: 10.0),
                //         Align(
                //           alignment: Alignment.bottomLeft,
                //           child: Container(
                //             child: Text(
                //               product.name,
                //               maxLines: 2,
                //               overflow: TextOverflow.ellipsis,
                //               style: normalFont(MColors.textGrey, 14.0),
                //             ),
                //           ),
                //         ),
                //         Spacer(),
                //         Container(
                //           child: Row(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: <Widget>[
                //               Container(
                //                 child: Text(
                //                   "Rs.${product.selling_price}",
                //                   style: boldFont(MColors.mainColor, 20.0),
                //                 ),
                //               ),
                //               Spacer(),
                //               GestureDetector(
                //                 onTap: () => () {
                //                   getCart(cartNotifier);
                //                   addProductToCart(
                //                       Cart(
                //                           id: product.id,
                //                           name: product.name,
                //                           selling_price:
                //                               product.selling_price,
                //                           category: product.category,
                //                           specs: product.specs,
                //                           productQuantity:
                //                               product.productQuantity,
                //                           original_price:
                //                               product.original_price,
                //                           quantity: product.quantity,
                //                           image: product.image,
                //                           imgcollection:
                //                               product.imgcollection,
                //                           filterValue: product.filterValue,
                //                           description: product.description,
                //                           prices: product.prices,
                //                           cartQuantity: 1,
                //                           sold: product.sold,
                //                           tablespecs: product.tablespecs,
                //                           varientID: product.varientID),
                //                       scaffoldKey);
                //                   // addAndApdateData(
                //                   //     Cart(
                //                   //         id: _product.id,
                //                   //         name: _product.name,
                //                   //         selling_price: _product.selling_price,
                //                   //         category: _product.category,
                //                   //         specs: _product.specs,
                //                   //         productQuantity: _product.productQuantity,
                //                   //         original_price: _product.original_price,
                //                   //         quantity: _product.quantity,
                //                   //         image: _product.image,
                //                   //         imgcollection: _product.imgcollection,
                //                   //         filterValue: _product.filterValue,
                //                   //         description: _product.description,
                //                   //         prices: _product.prices,
                //                   //         cartQuantity: 1,
                //                   //         sold: _product.sold,
                //                   //         tablespecs: _product.tablespecs,
                //                   //         varientID: _product.varientID),
                //                   //     _scaffoldKey);
                //                   getCart(cartNotifier);
                //                   // Navigator.of(context).pop();
                //
                //                   // if (cartProdID.contains(_product.id)) {
                //                   //   showSimpleSnack(
                //                   //     "Product already in bag",
                //                   //     Icons.error_outline,
                //                   //     Colors.amber,
                //                   //     scaffoldKey,
                //                   //   );
                //                   // } else {
                //
                //                   //
                //                   // }
                //                   // addToBagshowDialog(product,
                //                   //   cartNotifier, cartProdID, _scaffoldKey);
                //                 }(),
                //                 child: Container(
                //                   width: 40.0,
                //                   height: 40.0,
                //                   padding: const EdgeInsets.all(8.0),
                //                   decoration: BoxDecoration(
                //                     color: MColors.dashPurple,
                //                     borderRadius: BorderRadius.circular(8.0),
                //                   ),
                //                   child: SvgPicture.asset(
                //                     "assets/images/icons/basket.svg",
                //                     height: 22.0,
                //                     color: MColors.textGrey,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              }),
            )),
          ),
        ],
      ),
    );
  }

  List<Widget> returnOptions(
      List filterOptions, String filterName, Filter filter) {
    List<Widget> filterOptionTiles = [];
    for (var v in filterOptions) {
      filterOptionTiles.add(ListTile(
        onTap: () async {
          if (filterValues[filterName] == null)
            filterValues[filterName] = await [v.toString()];
          else if (filterValues[filterName].contains(v.toString()))
            await filterValues[filterName].remove(v.toString());
          else
            await filterValues[filterName].add(v.toString());

          if (filterValues[filterName].isEmpty) filterValues.remove(filterName);
          await filterProductsList();

          setState(() {});
          // print(filterValues);
        },
        title: Text(
          v.toString(),
          style: normalFont(
              filterValues[filterName] == null
                  ? MColors.textDark
                  : filterValues[filterName].contains(v.toString())
                      ? Colors.white
                      : MColors.textDark,
              13),
        ),
        tileColor: filterValues[filterName] == null
            ? Colors.white
            : filterValues[filterName].contains(v.toString())
                ? MColors.mainColor
                : Colors.white,
      ));
    }

    return filterOptionTiles;
  }

  Widget filtersDrawer() {
    return Drawer(
      child:
          // filters.length != 0
          //     ? Container(
          //         height: 500,
          //         width: 300,
          //         child: Center(
          //           child: Text(filters.length.toString()),
          //         ),
          //         color: Colors.red,
          //       )
          //     : Container(
          //         height: 500,
          //         width: 300,
          //         child: Center(
          //           child: Text(filters.length.toString()),
          //         ),
          //         color: Colors.blue,
          //       )
          ListView.builder(
              itemCount: filters.length,
              itemBuilder: (context, i) {
                return ExpansionTile(
                    title: Text(
                      filters[i].filterName,
                      style: boldFont(MColors.mainColor, 15),
                    ),
                    children: returnOptions(
                        filters[i].options, filters[i].filterName, filters[i]));
                return ListTile(title: Text(filters[i].filterName.toString()));
              }),
    );
  }

  // void addToBagshowDialog( ProdProducts _product,
  // ) async {
  //   await showCupertinoDialog(
  //       context: context,
  //       builder: (context) {
  //         return CupertinoAlertDialog(
  //           content: Text(
  //             "Sure you want to add to Bag?",
  //             style: normalFont(MColors.textDark, null),
  //           ),
  //           actions: <Widget>[
  //             CupertinoDialogAction(
  //               child: Text(
  //                 "Cancel",
  //                 style: normalFont(Colors.red, null),
  //               ),
  //               onPressed: () async {
  //                 setState(() {
  //                   getCart(cartNotifier);
  //                 });
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
  //                 setState(() {
  //                   getCart(cartNotifier);
  //                 });
  //                 if (cartProdID.contains(_product.id)) {
  //                   showSimpleSnack(
  //                     "Product already in bag",
  //                     Icons.error_outline,
  //                     Colors.amber,
  //                     scaffoldKey,
  //                   );
  //                 } else {
  //                   addProductToCart(_product, scaffoldKey);
  //
  //                   setState(() {
  //                     getCart(cartNotifier);
  //                   });
  //                 }
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }
}
