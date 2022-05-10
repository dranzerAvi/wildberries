// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getflutter/getflutter.dart';
// import 'package:location/location.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/leafCategory.dart';
import 'package:wildberries/model/data/subCategory.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/screens/getstarted_screens/intro_screen.dart';
import 'package:wildberries/screens/tab_screens/allCategories.dart';
import 'package:wildberries/screens/tab_screens/history.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:wildberries/screens/tab_screens/settings.dart';
import 'package:wildberries/screens/wishlistScreen.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/utils/navbarController.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../main.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class CustomDrawer extends StatefulWidget {
  UserDataProfile user;
  List<ProdProducts> products;
  Map<String, List<SubCategory>> subCats;
  Map<String, List<LeafCategory>> leafCats;
  CustomDrawer(this.user, this.products, this.subCats, this.leafCats);
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List categories = [];
  // Map<String, List<Widget>> subCats = {
  //   'Eggs': [],
  //   'Fish': [],
  //   'Chicken': [],
  //   'Mutton': []
  // };
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  getCategories() {
    //TODO:Check
    // Firestore.instance.collection('Categories').getDocuments().then((value) {
    //   for (var v in value.documents) {
    //     print('----------------$v');
    //     categories.add(v);
    //   }
    // });
  }

  // Location loc = new Location();
  // LocationData _currentPosition;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  String currentAddress = 'Enter Address';
  Future<Position> _getCurrentLocation() async {
    // _currentPosition = await loc.getLocation();
//    Position position = await geolocator.getCurrentPosition(
//        desiredAccuracy: LocationAccuracy.high);
//    print(position);
//    geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//        .then((Position position) {
//      setState(() {
//        _currentPosition = position;
//      });
//     print(_currentPosition);
    _getAddressFromLatLng();
    // print(_currentPosition);
  }

  _getAddressFromLatLng() async {
    try {
      // List<Placemark> p = await geolocator.placemarkFromCoordinates(
      //     _currentPosition.latitude, _currentPosition.longitude);
      //
      // Placemark place = p[0];
      //
      // setState(() {
      //   currentAddress = "${place.subLocality}, ${place.locality}";
      //   // print(currentAddress);
      //   location = currentAddress;
      //   pass.text = currentAddress;
      // });
    } catch (e) {
      print(e);
    }
  }

  var location = 'Kolkata, West Bengal';
  final pass = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future profileFuture;
  Future addressFuture;
  UserDataProfile user;
  // getSubCats(subCategoryNotifier) async {
  //   await getSubCategories(subCategoryNotifier);
  //   setState(() {});
  //   await subCategoryNotifier.subCatsList.forEach((element) {
  //     if (element.parentId == '6112949447d0ee26fc8bc927') {
  //       if (subCats['Eggs'] == null)
  //         subCats['Eggs'] = [
  //           ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ];
  //       else
  //         subCats.update('Eggs', (value) {
  //           value.add(ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ));
  //           return value;
  //         });
  //     } else if (element.parentId == '6128d183f56dad3024e8952f') {
  //       if (subCats['Fish'] == null)
  //         subCats['Fish'] = [
  //           ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ];
  //       else
  //         subCats.update('Fish', (value) {
  //           value.add(ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ));
  //           return value;
  //         });
  //     } else if (element.parentId == '6128d091f56dad3024e89528') {
  //       if (subCats['Chicken'] == null)
  //         subCats['Chicken'] = [
  //           ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ];
  //       else
  //         subCats.update('Chicken', (value) {
  //           value.add(ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ));
  //           return value;
  //         });
  //     } else if (element.parentId == '612f45928c1629001622a97b') {
  //       if (subCats['Mutton'] == null)
  //         subCats['Mutton'] = [
  //           ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ];
  //       else
  //         subCats.update('Mutton', (value) {
  //           value.add(ListTile(
  //             title: Row(
  //               children: [
  //                 Container(
  //                   width: 18,
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 10.0, vertical: 10),
  //                   child: Text(
  //                     element.name,
  //                     style: boldFont(MColors.mainColor, 18),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ));
  //           return value;
  //         });
  //     }
  //   });
  //   print('Subcats');
  //   print(subCats);
  // }

  getProfile() async {
    final Preference<String> userData =
        preferences.getString('user', defaultValue: '');
    // userData.listen((value) {
    //   print('User $value');
    // });

    userData.listen((value) {
      if (value != '') {
        user = UserDataProfile.fromMap(json.decode(value));
        setState(() {
          print(user.imgURL);
        });
        return UserDataProfile.fromMap(json.decode(value));
      }

      setState(() {});
    });
    CategoryNotifier categoryNotifier =
        Provider.of<CategoryNotifier>(context, listen: false);
    getCat(categoryNotifier);
    setState(() {});
  }

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);

                  UserDataAddressNotifier addressNotifier =
                      Provider.of<UserDataAddressNotifier>(context,
                          listen: false);
                  addressFuture = getAddress(addressNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    SubCategoryNotifier subCategoryNotifier = new SubCategoryNotifier();

    getProfile();
    // getSubCats(subCategoryNotifier);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        profileFuture,
        addressFuture,
      ]),
      builder: (c, s) {
        switch (s.connectionState) {
          case ConnectionState.active:
            return Container();
            break;
          case ConnectionState.done:
            return retNavDrawer(user, context);

            break;
          case ConnectionState.waiting:
            return retNavDrawer(user, context);
            break;
          default:
            return retNavDrawer(user, context);
        }
      },
    );
  }

  Widget retNavDrawer(UserDataProfile user, context) {
    CategoryNotifier categoryNotifier =
        Provider.of<CategoryNotifier>(context, listen: false);

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);

    List<Widget> catTiles = [];
    categoryNotifier.catList.forEach((element) {
      catTiles.add(Column(
        children: [
          ListTile(
            title: Text(
              element.name,
              style: boldFont(MColors.textDark, 16.0),
            ),
          ),
        ],
      ));
    });
    Widget categoryTiles = Container(
      child: ListView(
        children: catTiles,
      ),
    );

    return GFDrawer(
      color: MColors.secondaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SafeArea(
              child: user != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        // alignment: Alignment.center,
                        height: 80,
                        decoration: BoxDecoration(
                            color: MColors.mainColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(user.imgURL ==
                                        null
                                    ? 'https://firebasestorage.googleapis.com/v0/b/wildberries-3387f.appspot.com/o/unnamed.png?alt=media&token=2c39a045-ff4a-4f12-8071-13f82a71b426'
                                    : 'https://wild-grocery.herokuapp.com/${user.imgURL}'
                                        .replaceAll('\\', '/')),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${user.firstName} ${user.lastName}',
                                    style: normalFont(
                                        MColors.secondaryColor, 16.0),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    user.phone == null
                                        ? ''
                                        : '+${user.phone.toString()}',
                                    style: normalFont(
                                        MColors.secondaryColor, 16.0),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        pushNewScreen(
                          context,
                          screen: IntroScreen(),
                          withNavBar: false, // OPTIONAL VALUE. True by default.
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      child: Container(
                        color: MColors.mainColor,
                        height: 80,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                              ),
                              Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text('Sign In/Sign Up',
                                  style: boldFont(Colors.white, 17)),
                              SizedBox(
                                width: 40,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
          ListTile(
            tileColor: MColors.secondaryColor,
            title: Row(
              children: [
                Icon(
                  Icons.home_filled,
                  color: MColors.mainColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20),
                  child: Text(
                    'Home',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                Controller.controller.index = 0;
              });
              Navigator.of(context).pop();
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       Icon(
          //         Icons.category_outlined,
          //         color: MColors.mainColor,
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(
          //             horizontal: 10.0, vertical: 10),
          //         child: Text(
          //           'Shop by Category',
          //           style: boldFont(MColors.mainColor, 18),
          //         ),
          //       ),
          //     ],
          //   ),
          //   onTap: () {
          //     pushNewScreen(context,
          //         screen: AllCategories(
          //           from: 'drawer',
          //         ));
          //   },
          // ),
          //
          //
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          ExpansionTile(
            title: Row(
              children: [
                Container(
                    width: 30,
                    child: Image.asset('assets/images/icons/eggsIcon.png')
                    // FaIcon(
                    //   FontAwesomeIcons.egg,
                    //   color: Color(0xFFFFCC5F),
                    // ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Eggs',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            children: List.generate(
                widget.subCats['Eggs'].length,
                (index) => Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                    ),
                                    Text(
                                      widget.subCats['Eggs'][index].name,
                                      style: boldFont(MColors.mainColor, 18),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  ProductsNotifier productsNotifier =
                                      Provider.of<ProductsNotifier>(context,
                                          listen: false);

                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => SeeMoreScreen(
                                        title: 'Eggs',
                                        products: productsNotifier.productsList
                                            .where((ele) =>
                                                ele.subCategory != null &&
                                                ele.subCategory['name'] ==
                                                    widget
                                                        .subCats['Eggs'][index]
                                                        .name)
                                            .toList(),
                                        productsNotifier: productsNotifier,
                                        cartNotifier: cartNotifier,
                                        cartProdID: cartProdID,
                                        categoryId: '6112949447d0ee26fc8bc927',
                                      ),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    getCart(cartNotifier);
                                  }
                                }),
                            ...List.generate(
                                widget.leafCats[
                                            widget.subCats['Eggs'][index].id] !=
                                        null
                                    ? widget
                                        .leafCats[
                                            widget.subCats['Eggs'][index].id]
                                        .length
                                    : 0,
                                (ind) => InkWell(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 55,
                                            ),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                '-  ${widget.leafCats[widget.subCats['Eggs'][index].id][ind].name}',
                                                style: normalFont(
                                                    MColors.mainColor, 18),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      ProductsNotifier productsNotifier =
                                          Provider.of<ProductsNotifier>(context,
                                              listen: false);

                                      var navigationResult =
                                          await Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => SeeMoreScreen(
                                            title: 'Eggs',
                                            products: productsNotifier
                                                .productsList
                                                .where((ele) =>
                                                    ele.leafCategory != null &&
                                                    ele.leafCategory['name'] ==
                                                        widget
                                                            .leafCats[widget
                                                                .subCats['Eggs']
                                                                    [index]
                                                                .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: widget
                                                .leafCats[widget
                                                    .subCats['Eggs'][index]
                                                    .id][ind]
                                                .id,
                                          ),
                                        ),
                                      );
                                      if (navigationResult == true) {
                                        getCart(cartNotifier);
                                      }
                                    }))
                          ],
                        ),
                      ),
                    )),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ExpansionTile(
            title: Row(
              children: [
                Container(
                    width: 30,
                    child: Image.asset('assets/images/icons/fishIcon.png')
                    // FaIcon(FontAwesomeIcons.fish, color: Colors.grey)
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Fish',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            children: List.generate(
                widget.subCats['Fish'].length,
                (index) => Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                    ),
                                    Text(
                                      widget.subCats['Fish'][index].name,
                                      style: boldFont(MColors.mainColor, 18),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  ProductsNotifier productsNotifier =
                                      Provider.of<ProductsNotifier>(context,
                                          listen: false);

                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => SeeMoreScreen(
                                        title: 'Fish',
                                        products: productsNotifier.productsList
                                            .where((ele) =>
                                                ele.subCategory != null &&
                                                ele.subCategory['name'] ==
                                                    widget
                                                        .subCats['Fish'][index]
                                                        .name)
                                            .toList(),
                                        productsNotifier: productsNotifier,
                                        cartNotifier: cartNotifier,
                                        cartProdID: cartProdID,
                                        categoryId: '6128d183f56dad3024e8952f',
                                      ),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    getCart(cartNotifier);
                                  }
                                }),
                            ...List.generate(
                                widget.leafCats[
                                            widget.subCats['Fish'][index].id] !=
                                        null
                                    ? widget
                                        .leafCats[
                                            widget.subCats['Fish'][index].id]
                                        .length
                                    : 0,
                                (ind) => InkWell(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 55,
                                            ),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                '-  ${widget.leafCats[widget.subCats['Fish'][index].id][ind].name}',
                                                style: normalFont(
                                                    MColors.mainColor, 18),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      ProductsNotifier productsNotifier =
                                          Provider.of<ProductsNotifier>(context,
                                              listen: false);

                                      var navigationResult =
                                          await Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => SeeMoreScreen(
                                            title: 'Fish',
                                            products: productsNotifier
                                                .productsList
                                                .where((ele) =>
                                                    ele.leafCategory != null &&
                                                    ele.leafCategory['name'] ==
                                                        widget
                                                            .leafCats[widget
                                                                .subCats['Fish']
                                                                    [index]
                                                                .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: widget
                                                .leafCats[widget
                                                    .subCats['Fish'][index]
                                                    .id][ind]
                                                .id,
                                          ),
                                        ),
                                      );
                                      if (navigationResult == true) {
                                        getCart(cartNotifier);
                                      }
                                    }))
                          ],
                        ),
                      ),
                    )),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ExpansionTile(
            title: Row(
              children: [
                Container(
                    width: 30,
                    child: Image.asset('assets/images/icons/chickenIcon.png')
                    // child: FaIcon(
                    //   FontAwesomeIcons.drumstickBite,
                    //   color: Color(0xFFa13c1a),
                    // ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Chicken',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            children: List.generate(
                widget.subCats['Chicken'].length,
                (index) => Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                    ),
                                    Text(
                                      widget.subCats['Chicken'][index].name,
                                      style: boldFont(MColors.mainColor, 18),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  ProductsNotifier productsNotifier =
                                      Provider.of<ProductsNotifier>(context,
                                          listen: false);

                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => SeeMoreScreen(
                                        title: 'Chicken',
                                        products: productsNotifier.productsList
                                            .where((ele) =>
                                                ele.subCategory != null &&
                                                ele.subCategory['name'] ==
                                                    widget
                                                        .subCats['Chicken']
                                                            [index]
                                                        .name)
                                            .toList(),
                                        productsNotifier: productsNotifier,
                                        cartNotifier: cartNotifier,
                                        cartProdID: cartProdID,
                                        categoryId: '6128d091f56dad3024e89528',
                                      ),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    getCart(cartNotifier);
                                  }
                                }),
                            ...List.generate(
                                widget.leafCats[widget
                                            .subCats['Chicken'][index].id] !=
                                        null
                                    ? widget
                                        .leafCats[
                                            widget.subCats['Chicken'][index].id]
                                        .length
                                    : 0,
                                (ind) => InkWell(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 55,
                                            ),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                '-  ${widget.leafCats[widget.subCats['Chicken'][index].id][ind].name}',
                                                style: normalFont(
                                                    MColors.mainColor, 18),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      ProductsNotifier productsNotifier =
                                          Provider.of<ProductsNotifier>(context,
                                              listen: false);

                                      var navigationResult =
                                          await Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => SeeMoreScreen(
                                            title: 'Chicken',
                                            products: productsNotifier
                                                .productsList
                                                .where((ele) =>
                                                    ele.leafCategory != null &&
                                                    ele.leafCategory['name'] ==
                                                        widget
                                                            .leafCats[widget
                                                                .subCats[
                                                                    'Chicken']
                                                                    [index]
                                                                .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: widget
                                                .leafCats[widget
                                                    .subCats['Chicken'][index]
                                                    .id][ind]
                                                .id,
                                          ),
                                        ),
                                      );
                                      if (navigationResult == true) {
                                        getCart(cartNotifier);
                                      }
                                    }))
                          ],
                        ),
                      ),
                    )),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ExpansionTile(
            title: Row(
              children: [
                Container(
                    width: 30,
                    child: Image.asset('assets/images/icons/muttonIcon.png')
                    // child: FaIcon(
                    //   FontAwesomeIcons.bacon,
                    //   color: Color(0xFFdf3f32),
                    // ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'Mutton',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            children: List.generate(
                widget.subCats['Mutton'].length,
                (index) => Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 55,
                                    ),
                                    Text(
                                      widget.subCats['Mutton'][index].name,
                                      style: boldFont(MColors.mainColor, 18),
                                    ),
                                  ],
                                ),
                                onTap: () async {
                                  ProductsNotifier productsNotifier =
                                      Provider.of<ProductsNotifier>(context,
                                          listen: false);

                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => SeeMoreScreen(
                                        title: 'Mutton',
                                        products: productsNotifier.productsList
                                            .where((ele) =>
                                                ele.subCategory != null &&
                                                ele.subCategory['name'] ==
                                                    widget
                                                        .subCats['Mutton']
                                                            [index]
                                                        .name)
                                            .toList(),
                                        productsNotifier: productsNotifier,
                                        cartNotifier: cartNotifier,
                                        cartProdID: cartProdID,
                                        categoryId: '6128d091f56dad3024e89528',
                                      ),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    getCart(cartNotifier);
                                  }
                                }),
                            ...List.generate(
                                widget.leafCats[widget
                                            .subCats['Mutton'][index].id] !=
                                        null
                                    ? widget
                                        .leafCats[
                                            widget.subCats['Mutton'][index].id]
                                        .length
                                    : 0,
                                (ind) => InkWell(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 55,
                                            ),
                                            Container(
                                              width: 200,
                                              child: Text(
                                                '-  ${widget.leafCats[widget.subCats['Mutton'][index].id][ind].name}',
                                                style: normalFont(
                                                    MColors.mainColor, 18),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      ProductsNotifier productsNotifier =
                                          Provider.of<ProductsNotifier>(context,
                                              listen: false);

                                      var navigationResult =
                                          await Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => SeeMoreScreen(
                                            title: 'Mutton',
                                            products: productsNotifier
                                                .productsList
                                                .where((ele) =>
                                                    ele.leafCategory != null &&
                                                    ele.leafCategory['name'] ==
                                                        widget
                                                            .leafCats[widget
                                                                .subCats[
                                                                    'Mutton']
                                                                    [index]
                                                                .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: widget
                                                .leafCats[widget
                                                    .subCats['Mutton'][index]
                                                    .id][ind]
                                                .id,
                                          ),
                                        ),
                                      );
                                      if (navigationResult == true) {
                                        getCart(cartNotifier);
                                      }
                                    }))
                          ],
                        ),
                      ),
                    )),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       FaIcon(
          //         FontAwesomeIcons.egg,
          //         color: MColors.mainColor,
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(
          //             horizontal: 10.0, vertical: 10),
          //         child: Text(
          //           'Eggs',
          //           style: boldFont(MColors.mainColor, 18),
          //         ),
          //       ),
          //     ],
          //   ),
          //   // onTap: () async {
          //   //   ProductsNotifier productsNotifier =
          //   //       Provider.of<ProductsNotifier>(context, listen: false);
          //   //
          //   //   var navigationResult = await Navigator.of(context).push(
          //   //     CupertinoPageRoute(
          //   //       builder: (context) => SeeMoreScreen(
          //   //         title: 'Eggs',
          //   //         products: widget.products
          //   //             .where(
          //   //                 (element) => element.category['name'] == 'Eggs')
          //   //             .toList(),
          //   //         productsNotifier: productsNotifier,
          //   //         cartNotifier: cartNotifier,
          //   //         cartProdID: cartProdID,
          //   //         categoryId: '6112949447d0ee26fc8bc927',
          //   //       ),
          //   //     ),
          //   //   );
          //   //   if (navigationResult == true) {
          //   //     getCart(cartNotifier);
          //   //   }
          //   // }
          // ),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          // ListTile(
          //     title: Row(
          //       children: [
          //         FaIcon(
          //           FontAwesomeIcons.fish,
          //           color: MColors.mainColor,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 10.0, vertical: 10),
          //           child: Text(
          //             'Fish',
          //             style: boldFont(MColors.mainColor, 18),
          //           ),
          //         ),
          //       ],
          //     ),
          //     onTap: () async {
          //       ProductsNotifier productsNotifier =
          //           Provider.of<ProductsNotifier>(context, listen: false);
          //
          //       var navigationResult = await Navigator.of(context).push(
          //         CupertinoPageRoute(
          //           builder: (context) => SeeMoreScreen(
          //             title: 'Fish',
          //             products: widget.products
          //                 .where(
          //                     (element) => element.category['name'] == 'Fish')
          //                 .toList(),
          //             productsNotifier: productsNotifier,
          //             cartNotifier: cartNotifier,
          //             cartProdID: cartProdID,
          //             categoryId: '6128d183f56dad3024e8952f',
          //           ),
          //         ),
          //       );
          //       if (navigationResult == true) {
          //         getCart(cartNotifier);
          //       }
          //     }),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          // ListTile(
          //     title: Row(
          //       children: [
          //         FaIcon(
          //           FontAwesomeIcons.drumstickBite,
          //           color: MColors.mainColor,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 10.0, vertical: 10),
          //           child: Text(
          //             'Chicken',
          //             style: boldFont(MColors.mainColor, 18),
          //           ),
          //         ),
          //       ],
          //     ),
          //     onTap: () async {
          //       ProductsNotifier productsNotifier =
          //           Provider.of<ProductsNotifier>(context, listen: false);
          //
          //       var navigationResult = await Navigator.of(context).push(
          //         CupertinoPageRoute(
          //           builder: (context) => SeeMoreScreen(
          //             title: 'Chicken',
          //             products: widget.products
          //                 .where((element) =>
          //                     element.category['name'] == 'Chicken')
          //                 .toList(),
          //             productsNotifier: productsNotifier,
          //             cartNotifier: cartNotifier,
          //             cartProdID: cartProdID,
          //             categoryId: '6128d091f56dad3024e89528',
          //           ),
          //         ),
          //       );
          //       if (navigationResult == true) {
          //         getCart(cartNotifier);
          //       }
          //     }),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          // ListTile(
          //   title: Row(
          //     children: [
          //       FaIcon(
          //         FontAwesomeIcons.bacon,
          //         color: MColors.mainColor,
          //       ),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(
          //             horizontal: 10.0, vertical: 10),
          //         child: Text(
          //           'Mutton',
          //           style: boldFont(MColors.mainColor, 18),
          //         ),
          //       ),
          //     ],
          //   ),
          //   onTap: () async {
          //     ProductsNotifier productsNotifier =
          //         Provider.of<ProductsNotifier>(context, listen: false);
          //
          //     var navigationResult = await Navigator.of(context).push(
          //       CupertinoPageRoute(
          //         builder: (context) => SeeMoreScreen(
          //           title: 'Mutton',
          //           products: widget.products
          //               .where(
          //                   (element) => element.category['name'] == 'Mutton')
          //               .toList(),
          //           productsNotifier: productsNotifier,
          //           cartNotifier: cartNotifier,
          //           cartProdID: cartProdID,
          //           categoryId: '612f45928c1629001622a97b',
          //         ),
          //       ),
          //     );
          //     if (navigationResult == true) {
          //       getCart(cartNotifier);
          //     }
          //   },
          // ),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          ListTile(
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.solidHeart,
                  color: MColors.mainColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'My Wishlist',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            onTap: () {
              pushNewScreen(context, screen: WishlistScr());
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ListTile(
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.gift,
                  color: MColors.mainColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'My Orders',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            onTap: () {
              Preference<String> orderString =
                  preferences.getString('user', defaultValue: '');
              orderString.listen((value) {
                if (value != '') {
                  UserDataProfile currentUser =
                      UserDataProfile.fromMap(json.decode(value));
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => HistoryScreen(currentUser),
                    ),
                  );
                }
              });
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          // ListTile(
          //     title: Row(
          //       children: [
          //         FaIcon(
          //           FontAwesomeIcons.cog,
          //           color: MColors.mainColor,
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.symmetric(
          //               horizontal: 10.0, vertical: 10),
          //           child: Text(
          //             'On Sale',
          //             style: boldFont(MColors.mainColor, 18),
          //           ),
          //         ),
          //       ],
          //     ),
          //     onTap: () async {
          //       Iterable<ProdProducts> popular =
          //           prods.where((e) => e.selling_price != null);
          //       var _prods = popular.toList();
          //       var title = "Best Sellers";
          //
          //       var navigationResult = await Navigator.of(context).push(
          //         CupertinoPageRoute(
          //           builder: (context) => SeeMoreScreen(
          //             title: title,
          //             products: prods,
          //             productsNotifier: productsNotifier,
          //             cartNotifier: cartNotifier,
          //             cartProdID: cartProdID,
          //           ),
          //         ),
          //       );
          //       if (navigationResult == true) {
          //         getCart(cartNotifier);
          //       }
          //     }),
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          //   height: 0.5,
          //   color: Colors.black26,
          // ),
          ListTile(
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.cog,
                  color: MColors.mainColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Text(
                    'App Settings',
                    style: normalFont(MColors.mainColor, 18),
                  ),
                ),
              ],
            ),
            onTap: () {
              pushNewScreen(context, screen: SettingsScreen());
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          user != null
              ? ListTile(
                  title: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.signOutAlt,
                        color: MColors.mainColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Text(
                          'Log Out',
                          style: normalFont(MColors.mainColor, 18),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showLogOutDialog();
                  },
                )
              : Container(),
          user != null
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  height: 0.5,
                  color: Colors.black26,
                )
              : Container(),
          ListTile(
            title: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        height: 50,
                        width: 50,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.all(Radius.circular(25)),
                        //     border:
                        //         Border.all(color: MColors.mainColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(
                          FontAwesomeIcons.whatsappSquare,
                          color: Colors.green,
                          size: 50,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                        height: 50,
                        width: 50,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.all(Radius.circular(25)),
                        //     border:
                        //         Border.all(color: MColors.mainColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(
                          FontAwesomeIcons.instagramSquare,
                          color: Color(0xFFE1306C),
                          size: 50,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                        height: 50,
                        width: 50,
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.all(Radius.circular(25)),
                        //     border:
                        //         Border.all(color: MColors.mainColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(
                          FontAwesomeIcons.facebookSquare,
                          color: Colors.blue,
                          size: 50,
                        ))
                  ],
                )),
          )
        ],
      ),
    );
  }

  // User user;

  String name = ' ',
      email = ' ',
      url =
          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/user%20.png?alt=media&token=4f8258f6-a74f-47b4-856e-f0c493179d67';
  getUserDetails() async {
    // user = await FirebaseAuth.instance.currentUser;
    //TODO:Check
    // Firestore.instance
    //     .collection('Users')
    //     .where('id', isEqualTo: user.uid)
    //     .getDocuments()
    //     .then((value) {
    //   value.documents.forEach((element) {
    //     setState(() {
    //       name = element['Name'];
    //       email = element['mail'];
    //       url = element['pUrl'];
    //     });
    //   });
    // });
  }

  void _showLogOutDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              "Are you sure you want to sign out?",
              style: normalFont(MColors.textGrey, 14.0),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  try {
                    AuthService auth = MyProvider.of(context).auth;
                    // googleSignIn.signOut();
                    auth.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (_) => MyApp(),
                      ),
                    );
                    // print("Signed out.");
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text(
                  "Sign out",
                  style: normalFont(Colors.redAccent, 14.0),
                ),
              ),
            ],
          );
        });
  }
}
