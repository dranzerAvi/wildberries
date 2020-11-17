import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/bannerAd_notifier.dart';
import 'package:mrpet/model/notifiers/brands_notifier.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/brandProductsScreen.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_screen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/internetConnectivity.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/custom_floating_button.dart';
import 'package:mrpet/widgets/navDrawer.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../credentials.dart';
import 'homeScreen_pages/bag.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  getUserCurrentLocation();
                  ProductsNotifier productsNotifier =
                      Provider.of<ProductsNotifier>(context, listen: false);
                  getProdProducts(productsNotifier);
                  CategoryNotifier categoryNotifier =
                      Provider.of<CategoryNotifier>(context, listen: false);
                  getCat(categoryNotifier);

                  CartNotifier cartNotifier =
                      Provider.of<CartNotifier>(context, listen: false);
                  getCart(cartNotifier);

                  BannerAdNotifier bannerAdNotifier =
                      Provider.of<BannerAdNotifier>(context, listen: false);
                  getBannerAds(bannerAdNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    super.initState();
  }

  var currentLocationAddress = 'Dubai, UAE';

  getUserCurrentLocation() async {
    String error;

    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final coordinates = Coordinates(position.latitude, position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");

      setState(() {
        currentLocationAddress = '${first.locality}, ${first.adminArea}';
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        Navigator.pop(context);
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        Navigator.pop(context);

        error = 'permission denied- please enable it from app settings';
        print(error);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageStorageBucket searchBucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height) / 2.5;
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

    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;
    CategoryNotifier categoryNotifier = Provider.of<CategoryNotifier>(context);
    var cats = categoryNotifier.catList;

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.productID);

    BannerAdNotifier bannerAdNotifier = Provider.of<BannerAdNotifier>(context);
    var bannerAds = bannerAdNotifier.bannerAdsList;

    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              size: 25,
              color: MColors.secondaryColor,
            ),
            backgroundColor: MColors.mainColor,
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
                  fontSize: 28,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
          ),
          drawer: CustomDrawer(),
          floatingActionButton: CustomFloatingButton(
              CurrentScreen(currentScreen: HomeScreen(), tab_no: 0)),
          key: _scaffoldKey,
          backgroundColor: MColors.primaryWhiteSmoke,
          body: RefreshIndicator(
            onRefresh: () => () async {
              await getProdProducts(productsNotifier);
              await getCart(cartNotifier);
              await getCat(categoryNotifier);
              await getBannerAds(bannerAdNotifier);
            }(),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => Search(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              height: 40.0,
                              decoration: BoxDecoration(
                                  color: MColors.primaryWhite,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  )),
                              child: Row(
                                children: [
                                  Text(
                                    "Search for products",
                                    style: normalFont(MColors.textGrey, 14.0),
                                  ),
                                  Spacer(),
                                  SvgPicture.asset(
                                    "assets/images/icons/Search.svg",
                                    color: MColors.textGrey,
                                    height: 20.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => Search(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.category_rounded,
                            color: Colors.black38,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border:
                              Border.all(color: MColors.mainColor, width: 2)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.map,
                                    color: MColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Deliver to ',
                                        style: myFont(MColors.textDark, 15),
                                      ),
                                      Text('$currentLocationAddress',
                                          style:
                                              normalFont(MColors.textGrey, 15)),
                                    ],
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.edit,
                                color: MColors.textGrey,
                              ),
                            ]),
                      ),
                    ),
                  ),
                  //BANNER ADS
                  Container(
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 150.0,
                        autoPlay: true,
                        enableInfiniteScroll: false,
                        initialPage: 0,
                        viewportFraction: 1,
                        scrollPhysics: BouncingScrollPhysics(),
                      ),
                      items: bannerAds.map((banner) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
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
                                child: FadeInImage.assetNetwork(
                                  image: banner.bannerAd,
                                  fit: BoxFit.fill,
                                  placeholder: "assets/images/placeholder.jpg",
                                  placeholderScale:
                                      MediaQuery.of(context).size.width / 2,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: MColors.mainColor,
                    child: Center(
                      child: Text(
                        'Your love...Our Care...Their Comfort',
                        style: normalFont(MColors.secondaryColor, 15),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //FOR YOU BLOCK
                  Builder(
                    builder: (BuildContext context) {
                      Iterable<Cat> cat = cats;
                      var _cats = cat.toList();

                      return blockWigdet2(
                        "SHOP BY CATEGORY",
                        "",
                        _picHeight,
                        itemHeight,
                        _cats,
                        cartNotifier,
                        productsNotifier,
                        cartProdID,
                        _scaffoldKey,
                        context,
                        prods,
                        () async {
                          var title = "Best Sellers";

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeMoreScreen(
                                title: title,
                                products: prods,
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
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  //POPULAR BLOCK
                  Builder(
                    builder: (BuildContext context) {
                      Iterable<ProdProducts> popular =
                          prods.where((e) => e.tag == "popular");
                      var _prods = popular.toList();

                      return blockWigdet(
                        "BEST SELLING IN SHOP",
                        "Sought after products",
                        _picHeight,
                        itemHeight,
                        _prods,
                        cartNotifier,
                        cartProdID,
                        _scaffoldKey,
                        context,
                        prods,
                        () async {
                          var title = "Best Sellers";

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeMoreScreen(
                                title: title,
                                products: prods,
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
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  //NEW BLOCK
                  Builder(
                    builder: (BuildContext context) {
                      Iterable<ProdProducts> newP =
                          prods.where((e) => e.tag == "new");
                      var _prods = newP.toList();

                      return blockWigdet(
                        "NEW",
                        "Newly released products",
                        _picHeight,
                        itemHeight,
                        _prods,
                        cartNotifier,
                        cartProdID,
                        _scaffoldKey,
                        context,
                        prods,
                        () async {
                          var title = "New";

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeMoreScreen(
                                title: title,
                                products: prods,
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
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  //BRANDS
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            "POPULAR BRANDS",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  //OFFERS
                  Builder(
                    builder: (BuildContext context) {
                      Iterable<ProdProducts> offers =
                          prods.where((e) => e.tag == "offers");
                      var _prods = offers.toList();

                      return blockWigdet(
                        "OFFERS",
                        "Slashed prices just for you",
                        _picHeight,
                        itemHeight,
                        _prods,
                        cartNotifier,
                        cartProdID,
                        _scaffoldKey,
                        context,
                        prods,
                        () async {
                          var title = "Offers";

                          var navigationResult =
                              await Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => SeeMoreScreen(
                                title: title,
                                products: prods,
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
