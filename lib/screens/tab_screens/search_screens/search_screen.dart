import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/brands_notifier.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/productDetailsScreen.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/internetConnectivity.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/navDrawer.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class Search extends StatelessWidget {
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
      child: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    getData();
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  // BrandsNotifier brandsNotifier =
                  //     Provider.of<BrandsNotifier>(context, listen: false);
                  // getBrands(brandsNotifier);

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
    dogCardsList1.clear();
    dogList1.clear();
    print('started loading');
    await databaseReference
        .collection("food")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        ProdProducts dp = ProdProducts.fromMap(f.data());
        await dogList1.add(dp);
        // await dogCardsList1.add(MyDogCard(dp, width, height));
        print('Dog added');
        print(f['imageLinks'].toString());
      });
    });
    setState(() {
      print(dogList1.length.toString());
      print(dogCardsList1.length.toString());
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _primaryscaffoldKey =
      GlobalKey<ScaffoldState>();
  List<ProdProducts> dogList = [];
  List<DocumentSnapshot> docList = [];

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

  @override
  Widget build(BuildContext context) {
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.productID);

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
          backgroundColor: MColors.primaryWhiteSmoke,
          leading: IconButton(
            icon: Icon(Icons.menu),
            color: MColors.secondaryColor,
            onPressed: () {
              _primaryscaffoldKey.currentState.openDrawer();
            },
          ),
          title: Container(
            height: 40.0,
            child: searchTextField(
              true,
              null,
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
      drawer: CustomDrawer(),
      body: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: dogList.length,
                    itemBuilder: (BuildContext, index) {
                      var item = dogList[index];
                      return InkWell(
                        onTap: () async {
                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  ProductDetailsProv(item, dogList),
                            ),
                          );
                          if (navigationResult == true) {
                            getCart(cartNotifier);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              children: <Widget>[
                                // Container(
                                //   height: 50,
                                //   width: 50,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.all(
                                //       Radius.circular(25),
                                //     ),
                                //   ),
                                //   child: ClipRRect(
                                //     borderRadius: BorderRadius.circular(25.0),
                                //     child: CachedNetworkImage(
                                //       height: 50,
                                //       width: 50,
                                //       imageUrl: item.url,
                                //       imageBuilder: (context, imageProvider) =>
                                //           Container(
                                //         decoration: BoxDecoration(
                                //           image: DecorationImage(
                                //               image: imageProvider,
                                //               fit: BoxFit.fill),
                                //         ),
                                //       ),
                                //       placeholder: (context, url) => GFLoader(
                                //         type: GFLoaderType.ios,
                                //       ),
                                //       errorWidget: (context, url, error) =>
                                //           Icon(Icons.error),
                                //     ),
                                //   ),
                                // ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Container(
                                      child: Text(
                                        '${item.name} in ${item.category}',
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
    docList.clear();
    dogList.clear();
    setState(() {
      print('Updated');
    });

    if (query == '') {
      print(query);
      getData();
      return;
    }

    await FirebaseFirestore.instance
        .collection('food')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      docList.clear();
      dogList.clear();
      snapshot.documents.forEach((f) {
        List<String> dogName = List<String>.from(f['nameSearch']);
        List<String> dogBreed = List<String>.from(f['categorySearch']);
        List<String> dogLowerCase = [];
        List<String> breedLowerCase = [];
        for (var dog in dogName) {
          dogLowerCase.add(dog.toLowerCase());
        }
        for (var breed in dogBreed) {
          breedLowerCase.add(breed.toLowerCase());
        }
        if (dogLowerCase.contains(query.toLowerCase()) ||
            breedLowerCase.contains(query.toLowerCase())) {
          print('Match found ${f['name']}');
          docList.add(f);
          ProdProducts dog = ProdProducts.fromMap(f.data());
          dogList.add(dog);
          setState(() {
            print('Updated');
          });
        }
      });
    });
  }

  final databaseReference = FirebaseFirestore.instance;

  void getData() async {
    await databaseReference
        .collection("food")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        dogList.add(ProdProducts.fromMap(f.data()));
        print('Dog added');
        print(f['profileImage'].toString());
      });
    });
    setState(() {
      print(dogList.length.toString());
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
