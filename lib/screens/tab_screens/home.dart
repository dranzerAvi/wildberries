import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geolocator/geolocator.dart' as gl;
import 'package:geolocator/geolocator.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/bannerAd_notifier.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/notifiers/userData_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:mrpet/screens/tab_screens/search_screens/search_screen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/internetConnectivity.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/custom_floating_button.dart';
import 'package:mrpet/widgets/navDrawer.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'allCategories.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // addDishParams();
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

  var result;

  void showPlacePicker() async {
    result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
    setState(() {
      currentLocationAddress = result.formattedAddress;
    });
    // Handle the result in your way
    print(currentLocationAddress);
  }

  getUserCurrentLocation() async {
    String error;

    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high);
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
    UserDataProfileNotifier userNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var profileData = userNotifier.userDataProfile;

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
              size: 20,
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
                                  builder: (context) => Search(false),
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
                                builder: (context) =>
                                    AllCategories(from: 'home'),
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
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height: 22,
                                        child: Text('$currentLocationAddress',
                                            style: normalFont(
                                                MColors.textGrey, 15)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: showPlacePicker,
                                child: Icon(
                                  Icons.edit,
                                  color: MColors.textGrey,
                                ),
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
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.03),
                                      offset: Offset(0, 10),
                                      blurRadius: 10,
                                      spreadRadius: 0),
                                ],
                              ),
                              child: FadeInImage.assetNetwork(
                                image: banner.bannerAd,
                                fit: BoxFit.fill,
                                placeholder: "assets/images/placeholder.jpg",
                                placeholderScale:
                                    MediaQuery.of(context).size.width / 2,
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
                        categoryNotifier,
                        cartProdID,
                        _scaffoldKey,
                        context,
                        prods,
                        () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => AllCategories(from: 'home'),
                            ),
                          );
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
                          prods, () async {
                        var title = "Best Sellers";

                        var navigationResult = await Navigator.of(context).push(
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
                      }, profileData);
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
                          "Our Sale",
                          "Newly released products",
                          _picHeight,
                          itemHeight,
                          _prods,
                          cartNotifier,
                          cartProdID,
                          _scaffoldKey,
                          context,
                          prods, () async {
                        var title = "SALE";

                        var navigationResult = await Navigator.of(context).push(
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
                      }, profileData);
                    },
                  ),

                  //BRANDS
                  // Container(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  //         child: Text(
                  //           "POPULAR BRANDS",
                  //           style: boldFont(MColors.textDark, 16.0),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: MColors.primaryWhite,
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.03),
                            offset: Offset(0, 10),
                            blurRadius: 10,
                            spreadRadius: 0),
                      ],
                    ),
                    child: FadeInImage.assetNetwork(
                      image:
                          'https://firebasestorage.googleapis.com/v0/b/mrpet-3387f.appspot.com/o/Banners%2F02-winter-1.jpg?alt=media&token=4a817f15-9e32-4946-8dfd-43dc32928fca',
                      fit: BoxFit.fill,
                      placeholder: "assets/images/placeholder.jpg",
                      placeholderScale: MediaQuery.of(context).size.width / 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  //OFFERS
                  Builder(
                    builder: (BuildContext context) {
                      Iterable<ProdProducts> offers =
                          prods.where((e) => e.tag == "offers");
                      var _prods = offers.toList();

                      return blockWigdet(
                          "New Products In Shop",
                          "Slashed prices just for you",
                          _picHeight,
                          itemHeight,
                          _prods,
                          cartNotifier,
                          cartProdID,
                          _scaffoldKey,
                          context,
                          prods, () async {
                        var title = "NEW";

                        var navigationResult = await Navigator.of(context).push(
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
                      }, profileData);
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

  final db = FirebaseFirestore.instance;

  addDishParams() {
    db.collection('food').getDocuments().then((value) {
      value.documents.forEach((element) {
        db.collection('food').document(element.documentID).updateData({
          'nameSearch': setSearchParam(element['name']),
          'categorySearch': setSearchParam(element['category']),
        });
      });
    });
  }

  setSearchParam(String caseString) {
    List<String> caseSearchList = List();
    String temp = "";
    for (int i = 0; i < caseString.length; i++) {
      temp = temp + caseString[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}
