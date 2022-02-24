import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/brands_notifier.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/productDetailsScreen.dart';
import 'package:wildberries/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:string_similarity/string_similarity.dart';

import '../../../main.dart';
import '../dynamic_link_controller.dart';

class Search extends StatefulWidget {
  bool showDrawer;
  Search(this.showDrawer);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProductsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => BrandsNotifier(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartNotifier(),
        ),
      ],
      child: SearchScreen(
        showDrawer: this.widget.showDrawer,
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  bool showDrawer;

  SearchScreen({Key key, this.showDrawer}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
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
    getData();
    getUser();

    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  // BrandsNotifier brandsNotifier =
                  //     Provider.of<BrandsNotifier>(context, listen: false);
                  // getBrands(brandsNotifier);
                  CategoryNotifier categoryNotifier =
                      Provider.of<CategoryNotifier>(context, listen: false);
                  getCat(categoryNotifier);
                  ProductsNotifier productsNotifier =
                      Provider.of<ProductsNotifier>(context, listen: false);
                  getProdProducts(productsNotifier);

                  CartNotifier cartNotifier =
                      Provider.of<CartNotifier>(context, listen: false);
                  getCart(cartNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    _tabController = TabController(
      length: _tabItems.length,
      vsync: this,
    );

    super.initState();
  }

  List<Widget> dogCardsList1 = [];
  List<ProdProducts> dogList1 = [];

  void getData1() async {
    //TODO:Check
    dogCardsList1 = [];
    dogList1 = [];
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);
    await getProdProducts(productsNotifier);
    dogList1 = productsNotifier.productsList;
    print('started loading');
    // await databaseReference
    //     .collection("food")
    //     .getDocuments()
    //     .then((QuerySnapshot snapshot) {
    //   snapshot.documents.forEach((f) async {
    //     ProdProducts dp = ProdProducts.fromMap(f.data());
    //     await dogList1.add(dp);
    //     // await dogCardsList1.add(MyDogCard(dp, width, height));
    //     print('Dog added');
    //     print(f['imageLinks'].toString());
    //   });
    // });
    setState(() {
      // print(dogList1.length.toString());
      // print(dogCardsList1.length.toString());
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _primaryscaffoldKey =
      GlobalKey<ScaffoldState>();
  List<ProdProducts> dogList = [];
  //TODO:Check
  List<ProdProducts> docList = [];

  final PageStorageBucket searchBucket = PageStorageBucket();

  TabController _tabController;
  final _tabItems = [
    "All",
    "Dogs",
    "Cats",
    "Fish",
    "Birds",
    "Reptiles",
    "Others",
  ];
  TextEditingController searchController = TextEditingController();
  final DynamicLinkController _dynamicLinkController = DynamicLinkController();

  @override
  Widget build(BuildContext context) {
    CategoryNotifier categoryNotifier =
        Provider.of<CategoryNotifier>(context, listen: false);
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);

    //Tab Items
    final _tabBody = [
      buildAllBody(prods, cartProdID),
      buildDogBody(prods, cartProdID),
      buildCatBody(prods, cartProdID),
      buildDogBody(prods, cartProdID),
      buildCatBody(prods, cartProdID),
      buildDogBody(prods, cartProdID),
      buildCatBody(prods, cartProdID),
    ];

    return Scaffold(
      key: _primaryscaffoldKey,
      appBar: AppBar(
          brightness: Brightness.light,
          elevation: 0.0,
          backgroundColor: MColors.mainColor,
          leading: widget.showDrawer == true
              ? IconButton(
                  icon: Icon(Icons.menu),
                  color: MColors.secondaryColor,
                  onPressed: () {
                    _primaryscaffoldKey.currentState.openDrawer();
                  },
                )
              : IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: MColors.secondaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          title: Container(
            height: 40.0,
            child: searchTextField(
              true,
              searchController,
              null,
              "Search for products...",
              null,
              (String query) {
                getCaseDetails(query);
              },
              true,
              null,
              false,
              false,
              true,
              TextInputType.text,
              null,
              SvgPicture.asset(
                "assets/images/icons/Search.svg",
                color: MColors.textGrey,
                height: 16.0,
              ),
              0.0,
            ),
          ),
          // bottom: TabBar(
          //   unselectedLabelColor: MColors.textGrey,
          //   unselectedLabelStyle: normalFont(MColors.textGrey, 16.0),
          //   labelColor: MColors.primaryPurple,
          //   labelStyle: boldFont(MColors.primaryPurple, 20.0),
          //   indicatorWeight: 0.01,
          //   isScrollable: true,
          //   tabs: _tabItems.map((e) {
          //     return Tab(
          //       child: Text(
          //         e,
          //       ),
          //     );
          //   }).toList(),
          //   controller: _tabController,
          // ),
          centerTitle: false),
      drawer: CustomDrawer(user, prods.toList(), {}),
      body: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: searchController.text == ''
                      ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: categoryNotifier.catList.length,
                          itemBuilder: (BuildContext, index) {
                            var item = categoryNotifier.catList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: InkWell(
                                onTap: () async {
                                  // var navigationResult =
                                  // await Navigator.of(context).push(
                                  //   CupertinoPageRoute(
                                  //     builder: (context) =>
                                  //         ProductDetailsProv(item, dogList),
                                  //   ),
                                  // );
                                  // if (navigationResult == true) {
                                  //   getCart(cartNotifier);
                                  // }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        new BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 5.0,
                                            offset: Offset.lerp(
                                                Offset.fromDirection(5),
                                                Offset.zero,
                                                5)),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Container(
                                                child: Text(
                                                  '${item.name}',
                                                  style: normalFont(
                                                      MColors.mainColor, 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.call_made_sharp,
                                            color: MColors.mainColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: dogList.length,
                          itemBuilder: (BuildContext, index) {
                            var item = dogList[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: InkWell(
                                onTap: () async {
                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => ProductDetailsProv(
                                          item,
                                          dogList,
                                          _dynamicLinkController),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    getCart(cartNotifier);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      boxShadow: [
                                        new BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 5.0,
                                            offset: Offset.lerp(
                                                Offset.fromDirection(5),
                                                Offset.zero,
                                                5)),
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Container(
                                                child: Text(
                                                  '${item.name} in ${item.category['name']}',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.call_made_sharp,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      // body: Scaffold(
      //   key: _scaffoldKey,
      //   body: PageStorage(
      //     bucket: searchBucket,
      //     child: Container(
      //       color: MColors.primaryWhiteSmoke,
      //       child: prods.isEmpty
      //           ? progressIndicator(MColors.primaryPurple)
      //           : TabBarView(
      //               physics: BouncingScrollPhysics(),
      //               children: _tabBody,
      //               controller: _tabController,
      //             ),
      //     ),
      //   ),
      // ),
    );
  }

  getCaseDetails(String query) async {
    //TODO:Check

    dogList = [];
    setState(() {
      // print('Updated');
    });

    if (query == '') {
      // print(query);
      getData();
      return;
    }
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);
    getProdProducts(productsNotifier);

    List<ProdProducts> allProducts = productsNotifier.productsList;
    allProducts.forEach((element) {
      bool flag = false;
      if (element.name.contains(new RegExp(query, caseSensitive: false)))
        flag = true;
      if (element.category['name']
          .contains(new RegExp(query, caseSensitive: false))) flag = true;
      if (element.description.contains(new RegExp(query, caseSensitive: false)))
        flag = true;
      element.filterValue.forEach((filter) {
        if (filter['value'].contains(new RegExp(query, caseSensitive: false)))
          flag = true;
      });
      element.specs.forEach((spec) {
        if (spec['value'].contains(new RegExp(query, caseSensitive: false)))
          flag = true;
      });
      if (flag == true) {
        dogList.add(element);
        setState(() {
          // print('Updated');
        });
      }
    });

    // if (dogLowerCase.contains(query.toLowerCase()) ||
    //     breedLowerCase.contains(query.toLowerCase()) ||
    //     name.toLowerCase().toString().contains(query.toLowerCase()) ||
    //     name.toString().toLowerCase().similarityTo(query.toLowerCase()) > 0.2) {
    //   print('Match found ${f['name']}');
    //
    //   ProdProducts dog = ProdProducts.fromMap(f.data());
    //
    // }
    // await FirebaseFirestore.instance
    //     .collection('food')
    //     .get()
    //     .then((QuerySnapshot snapshot) {
    //   dogList.clear();
    //   snapshot.docs.forEach((f) {
    //     var name = f['name'].toString().toLowerCase();
    //     List<String> dogName = List<String>.from(f['nameSearch']);
    //     List<String> dogBreed = List<String>.from(f['categorySearch']);
    //     List<String> dogLowerCase = [];
    //     List<String> breedLowerCase = [];
    //     for (var dog in dogName) {
    //       dogLowerCase.add(dog.toLowerCase());
    //     }
    //     for (var breed in dogBreed) {
    //       breedLowerCase.add(breed.toLowerCase());
    //     }
    //   });
    // });
  }

  // final databaseReference = FirebaseFirestore.instance;

  void getData() async {
    //TODO:Check
    dogCardsList1 = [];
    dogList = [];
    // print('started loading');
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);
    await getProdProducts(productsNotifier);
    dogList = productsNotifier.productsList;

    setState(() {
      // print(dogList.length.toString());
      // print(dogCardsList1.length.toString());
    });
  }

  //Build Tabs
  Widget buildAllBody(prods, cartProdID) {
    Iterable<ProdProducts> all = prods.reversed;
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);

    return SearchTabWidget(
      prods: all,
      cartNotifier: cartNotifier,
      productsNotifier: productsNotifier,
      cartProdID: cartProdID,
    );
  }

  Widget buildDogBody(prods, cartProdID) {
    Iterable<ProdProducts> dog = prods.where((e) => e.pet == "dog");
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);

    return SearchTabWidget(
      prods: dog,
      cartNotifier: cartNotifier,
      productsNotifier: productsNotifier,
      cartProdID: cartProdID,
    );
  }

  Widget buildCatBody(prods, cartProdID) {
    Iterable<ProdProducts> cat = prods.where((e) => e.pet == "cat");
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);

    return SearchTabWidget(
      prods: cat,
      cartNotifier: cartNotifier,
      productsNotifier: productsNotifier,
      cartProdID: cartProdID,
    );
  }
}
