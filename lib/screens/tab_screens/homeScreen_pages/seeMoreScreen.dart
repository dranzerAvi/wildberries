import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/drawer/gf_drawer.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
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
import 'package:wildberries/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/utils/navbarController.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:wildberries/widgets/provider.dart';

import '../../../main.dart';
import '../../wishlistScreen.dart';
import '../history.dart';
import '../settings.dart';
import 'bag.dart';

class SeeMoreScreen extends StatefulWidget {
  final String title;
  Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final String categoryId;

  SeeMoreScreen(
      {Key key,
      this.title,
      this.products,
      this.cartNotifier,
      this.productsNotifier,
      this.cartProdID,
      this.categoryId})
      : super(key: key);

  @override
  _SeeMoreScreenState createState() => _SeeMoreScreenState(
      title, products, cartNotifier, productsNotifier, cartProdID, categoryId);
}

class _SeeMoreScreenState extends State<SeeMoreScreen> {
  final String title;
  final Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final String categoryId;

  _SeeMoreScreenState(this.title, this.products, this.cartNotifier,
      this.productsNotifier, this.cartProdID, this.categoryId);
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

  UserDataProfile user = UserDataProfile();
  UserDataProfile getProfile() {
    final Preference<String> userData =
        preferences.getString('user', defaultValue: '');
    // userData.listen((value) {
    //   print('User $value');
    // });

    userData.listen((value) {
      if (value != '') {
        user = UserDataProfile.fromMap(json.decode(value));
        return UserDataProfile.fromMap(json.decode(value));
      }

      setState(() {
        print(user.token);
      });
    });
  }

  Map<String, List<SubCategory>> subCats = {
    'Eggs': [],
    'Fish': [],
    'Chicken': [],
    'Mutton': []
  };
  Map<String, List<LeafCategory>> leafCats = {};
  getLeafCats(LeafCategoryNotifier leafCategoryNotifier, cartList, cartProdID,
      cartNotifier) async {
    await getLeafCategories(leafCategoryNotifier);
    // ProductsNotifier productsNotifier =
    // Provider.of<ProductsNotifier>(context, listen: false);

    await leafCategoryNotifier.leafCatsList.forEach((element) {
      if (leafCats[element.parentId] == null)
        leafCats[element.parentId] = [element];
      else
        leafCats.update(element.parentId, (value) {
          value.add(element);
          return value;
        });
    });

    setState(() {});
  }

  getSubCats(SubCategoryNotifier subCategoryNotifier, cartList, cartProdID,
      cartNotifier) async {
    await getSubCategories(subCategoryNotifier);
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);

    setState(() {});
    await subCategoryNotifier.subCatsList.forEach((element) {
      if (element.parentId == '6112949447d0ee26fc8bc927') {
        if (subCats['Eggs'] == null)
          subCats['Eggs'] = [element];
        else
          subCats.update('Eggs', (value) {
            value.add(element);
            return value;
          });
      } else if (element.parentId == '6128d183f56dad3024e8952f') {
        if (subCats['Fish'] == null)
          subCats['Fish'] = [element];
        else
          subCats.update('Fish', (value) {
            value.add(element);
            return value;
          });
      } else if (element.parentId == '6128d091f56dad3024e89528') {
        if (subCats['Chicken'] == null)
          subCats['Chicken'] = [element];
        else
          subCats.update('Chicken', (value) {
            value.add(element);
            return value;
          });
      } else if (element.parentId == '612f45928c1629001622a97b') {
        if (subCats['Mutton'] == null)
          subCats['Mutton'] = [element];
        else
          subCats.update('Mutton', (value) {
            value.add(element);
            return value;
          });
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  ProductsNotifier productsNotifier =
                      Provider.of<ProductsNotifier>(context, listen: false);
                  getProdProducts(productsNotifier);
                  CategoryNotifier categoryNotifier =
                      Provider.of<CategoryNotifier>(context, listen: false);
                  getCat(categoryNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    // CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    // var cartList = cartNotifier.cartList;
    SubCategoryNotifier subCategoryNotifier = new SubCategoryNotifier();
    LeafCategoryNotifier leafCategoryNotifier = new LeafCategoryNotifier();
    CartNotifier cartNotifier = new CartNotifier();
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);

    getSubCats(subCategoryNotifier, cartList, cartProdID, cartNotifier);
    getLeafCats(leafCategoryNotifier, cartList, cartProdID, cartNotifier);
  }

  Future profileFuture;
  Future addressFuture;

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
            child: ExpansionTile(
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
                  subCats['Eggs'].length,
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
                                        subCats['Eggs'][index].name,
                                        style: boldFont(MColors.mainColor, 18),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    ProductsNotifier productsNotifier =
                                        Provider.of<ProductsNotifier>(context,
                                            listen: false);

                                    widget.products = productsNotifier
                                        .productsList
                                        .where((ele) =>
                                            ele.subCategory != null &&
                                            ele.subCategory['name'] ==
                                                subCats['Eggs'][index].name)
                                        .toList();
                                    Navigator.pop(context);
                                  }),
                              ...List.generate(
                                  leafCats[subCats['Eggs'][index].id] != null
                                      ? leafCats[subCats['Eggs'][index].id]
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
                                                  '-  ${leafCats[subCats['Eggs'][index].id][ind].name}',
                                                  style: normalFont(
                                                      MColors.mainColor, 18),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        ProductsNotifier productsNotifier =
                                            Provider.of<ProductsNotifier>(
                                                context,
                                                listen: false);
                                        widget.products = productsNotifier
                                            .productsList
                                            .where((ele) =>
                                                ele.leafCategory != null &&
                                                ele.leafCategory['name'] ==
                                                    leafCats[subCats['Eggs']
                                                                [index]
                                                            .id][ind]
                                                        .name)
                                            .toList();
                                        Navigator.pop(context);
                                      }))
                            ],
                          ),
                        ),
                      )),
            ),
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
                subCats['Fish'].length,
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
                                      subCats['Fish'][index].name,
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
                                                    subCats['Fish'][index].name)
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
                                leafCats[subCats['Fish'][index].id] != null
                                    ? leafCats[subCats['Fish'][index].id].length
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
                                                '-  ${leafCats[subCats['Fish'][index].id][ind].name}',
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
                                                        leafCats[subCats['Fish']
                                                                    [index]
                                                                .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: leafCats[subCats['Fish']
                                                        [index]
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
                subCats['Chicken'].length,
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
                                      subCats['Chicken'][index].name,
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
                                                    subCats['Chicken'][index]
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
                                leafCats[subCats['Chicken'][index].id] != null
                                    ? leafCats[subCats['Chicken'][index].id]
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
                                                '-  ${leafCats[subCats['Chicken'][index].id][ind].name}',
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
                                                        leafCats[
                                                                subCats['Chicken']
                                                                        [index]
                                                                    .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: leafCats[
                                                    subCats['Chicken'][index]
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
                subCats['Mutton'].length,
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
                                      subCats['Mutton'][index].name,
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
                                                    subCats['Mutton'][index]
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
                                leafCats[subCats['Mutton'][index].id] != null
                                    ? leafCats[subCats['Mutton'][index].id]
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
                                                '-  ${leafCats[subCats['Mutton'][index].id][ind].name}',
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
                                                        leafCats[
                                                                subCats['Mutton']
                                                                        [index]
                                                                    .id][ind]
                                                            .name)
                                                .toList(),
                                            productsNotifier: productsNotifier,
                                            cartNotifier: cartNotifier,
                                            cartProdID: cartProdID,
                                            categoryId: leafCats[
                                                    subCats['Mutton'][index]
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var cartList = cartNotifier.cartList;
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;
    return Scaffold(
      key: _scaffoldKey,
      drawer: FutureBuilder(
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
      ),
      // drawer: SeeMoreDrawer(user != null ? user : getProfile(), prods.toList(),
      //     subCats, leafCats),
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 20,
          color: MColors.secondaryColor,
        ),
        backgroundColor: MColors.mainColor,
        // leading: InkWell(
        //   child: Icon(Icons.arrow_back_ios),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
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
                    phone: '7060222315', message: 'Check out this awesome app');
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
      floatingActionButton: CustomFloatingButton(
          CurrentScreen(currentScreen: SeeMoreScreen(), tab_no: 0)),
      body: SearchTabWidget(
        prods: products,
        cartNotifier: cartNotifier,
        productsNotifier: productsNotifier,
        cartProdID: cartProdID,
        categoryId: categoryId,
      ),
    );
  }
}
