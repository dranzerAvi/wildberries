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
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/bannerAd_notifier.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/notifiers/userData_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/screens/address/confirm_address.dart';
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
  var date2;
  var minOrderValue;

  @override
  void initState() {
    calculateNextDelivery();
    selectedDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
    dateAddition = 15;
    // addDishParams();
    checkLastSlot();
    time();
    minOrderValue = '50';
    date = DateTime.now();
    date2 = DateTime(date.year, date.month, date.day + dateAddition);
    print('Date2:${date2}');
    print('Date:${selectedDate}');
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

  DateTime date;
  DateTime selectedDate;
  String selectedTime = '';
  int nextDelivery = 8;
  var currentLocationAddress = 'Bareilly, Uttar Pradesh';

  var result;
  calculateNextDelivery() {
    int hour = DateTime.now().hour;

    if (hour < 9) {
      setState(() {
        nextDelivery = 9 - hour;
      });
    }
    if (hour > 9 && hour < 13) {
      setState(() {
        nextDelivery = 14 - hour;
      });
    }
    if (hour > 13 && hour < 18) {
      setState(() {
        nextDelivery = 19 - hour;
      });
    }
  }

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
        currentLocationAddress = '${first.subLocality}, ${first.locality}';
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

  List<String> timeSlots2 = [];
  void time() {
    FirebaseFirestore.instance
        .collection('Timeslots')
        .snapshots()
        .forEach((element) {
      for (int i = 0; i < element.docs[0]['Timeslots'].length; i++) {
        DateTime dt = DateTime.now();

        if (dt.hour > 12) {
          String st = element.docs[0]['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour - 12) &&
              element.docs[0]['Timeslots'][i].contains('PM')) {
            timeSlots2.add(element.docs[0]['Timeslots'][i]);
          }
        } else {
          String st = element.docs[0]['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour) && element.docs[0]['Timeslots'][i].contains('AM')) {
            timeSlots2.add(element.docs[0]['Timeslots'][i]);
          }
        }
      }
      if (timeSlots2.length == 0) {
        selectedDate = selectedDate.add(new Duration(days: 1));
        for (int i = 0; i < element.docs[0]['Timeslots'].length; i++) {
          timeSlots2.add(element.docs[0]['Timeslots'][i]);
        }
      }
      selectedTime = timeSlots2[0];
    });
//  if(timeSlots2.length>0){
//    setState(() {
//      selectedTime=timeSlots2[0];
//    });
//
//  }
    select();
  }

  void select() {
    if (timeSlots2.length > 0) {
      setState(() {
        selectedTime = timeSlots2[0];
      });
    }
  }

  int dateAddition;
  checkLastSlot() async {
    await FirebaseFirestore.instance
        .collection('Timeslots')
        .snapshots()
        .listen((event) {
      String st = event.docs[0]['LastSlot'];
      String s = '';
      for (int i = 0; i < st.length; i++) {
        if (st[i] != ' ')
          s = s + st[i];
        else
          break;
      }

      double d = double.parse(s);
      if (st.contains('PM')) d = d + 12;
      DateTime dt = DateTime.now();
      if (dt.hour > d) {
        dateAddition = dateAddition + 1;
        print('Date:${dateAddition}');
        //run
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _pickTime() async {
      var today = DateTime.now();
      DateTime t = await showDatePicker(
        context: context,
        initialDate:
            DateTime(today.year, today.month, today.day + dateAddition),
        lastDate: DateTime(today.year, today.month, today.day + 21),
        firstDate: DateTime(
            today.year, DateTime.now().month, today.day + dateAddition),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark(),
            child: child,
          );
        },
      );
      if (t != null)
        setState(() {
          date = t;
        });
      return date;
    }

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
                        phone: '+919027553376',
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
            title: Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: Text(
                'Budget Mart',
                style: TextStyle(
                    color: MColors.secondaryColor,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold),
              ),
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
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: MColors.mainColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 25,
                          ),
                          Icon(Icons.map, color: Colors.white),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: currentLocationAddress != null
                                  ? Text('Deliver to $currentLocationAddress',
                                      maxLines: 2,
                                      style: TextStyle(color: Colors.white))
                                  : Text('Deliver to Bareilly, UP',
                                      style: TextStyle(color: Colors.white))),

//                          InkWell(
//                              onTap: () async {
//                                showLocationPicker(
//                                  context,
//                                  'AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw',
//                                  initialCenter: LatLng(31.1975844, 29.9598339),
//                                  automaticallyAnimateToCurrentLocation: true,
////                      mapStylePath: 'assets/mapStyle.json',
//                                  myLocationButtonEnabled: true,
//                                  // requiredGPS: true,
//                                  layersButtonEnabled: true,
//                                  countries: ['AE'],
//
////                      resultCardAlignment: Alignment.bottomCenter,
////                       desiredAccuracy: LocationAccuracy.best,
//                                );
//                                print("result = $result");
//                                setState(() {
//                                  currentLocationAddress = result;
//                                  if (currentLocationAddress != null) {
//                                    minOrderValue = Navigator.of(context).push(
//                                        MaterialPageRoute(
//                                            builder: (context) =>
//                                                ConfirmAddress(
//                                                    currentLocationAddress)));
//
////
//                                  }
//                                });
//                              },
//                              child: Icon(Icons.edit, color: Colors.white)),
//                            Container(
//                                width: MediaQuery.of(context).size.width * 0.1,
//                                child: Text('${minOrderValue}',
//                                    style: TextStyle(color: Colors.white))),
//                            InkWell(
//                                onTap: () {
//                                  showPlacePicker();
//
////                              _locationDialog(context);
//                                },
//                                child: Icon(Icons.map, color: Colors.white))
                        ],
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: MColors.mainColor),
                        borderRadius: BorderRadius.all(Radius.zero)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          color: MColors.mainColor,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Next Delivery in $nextDelivery hours | Minimum Order Value : ₹ $minOrderValue',
                          style: TextStyle(color: Color(0xFF8B0000)),
                        ),

//                        InkWell(
//                            onTap: () {
//                              _pickTime().then((value) {
//                                setState(() {
//                                  selectedDate = value;
//                                });
//                              });
//                            },
//                            child: selectedDate != null
//                                ? Text(
//                                    '${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()} ',
//                                    style: TextStyle(color: Color(0xFF6b3600)),
//                                  )
//                                : Text(
//                                    '${date2.day.toString()}/${date2.month.toString()}/${date2.year.toString()} ',
//                                    style: TextStyle(color: Color(0xFF6b3600)),
//                                  )),
//                        Text(' at '),
//                        Icon(
//                          Icons.timer,
//                          size: 19,
//                          color: MColors.secondaryColor,
//                        ),
//                        SizedBox(width: 5),
//                        InkWell(
//                            onTap: () {
//                              _timeDialog(context);
//                            },
//                            child: Text(
//                              '$selectedTime ',
//                              style: TextStyle(color: Color(0xFF6b3600)),
//                            )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                      ],
                    ),
                  ),

//                    HeadingRow(
//                      title: StringConst.OFFERS,
//                      number: '',
//                      onTapOfNumber: () => R.Router.navigator
//                          .pushNamed(R.Router.trendingRestaurantsScreen),
//                    ),
//                  Padding(
//                    padding: const EdgeInsets.all(10.0),
//                    child: Container(
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.all(Radius.circular(8)),
//                          border:
//                              Border.all(color: MColors.mainColor, width: 2)),
//                      child: Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: [
//                              Row(
//                                children: [
//                                  Icon(
//                                    Icons.map,
//                                    color: MColors.secondaryColor,
//                                  ),
//                                  SizedBox(
//                                    width: 10,
//                                  ),
//                                  Row(
//                                    children: [
//                                      Text(
//                                        'Deliver to ',
//                                        style: myFont(MColors.textDark, 15),
//                                      ),
//                                      Container(
//                                        width:
//                                            MediaQuery.of(context).size.width *
//                                                0.45,
//                                        height: 22,
//                                        child: Text('$currentLocationAddress',
//                                            style: normalFont(
//                                                MColors.textGrey, 15)),
//                                      ),
//                                    ],
//                                  ),
//                                ],
//                              ),
//                              InkWell(
//                                onTap: showPlacePicker,
//                                child: Icon(
//                                  Icons.edit,
//                                  color: MColors.textGrey,
//                                ),
//                              ),
//                            ]),
//                      ),
//                    ),
//                  ),
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
                        'Best Savings | Fast Delivery | Sealed and Sanatized',
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

  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }

  List<String> timeSlots = [];
  String timeSlot;

  Widget _buildTimeDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var hintTextStyle = textTheme.subtitle.copyWith(color: Colors.grey);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: Colors.grey);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          0,
          36,
          0,
          0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        content: Container(
          height: 160,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Change delivery time',
                    style: textTheme.title.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Timeslots')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        timeSlots.clear();
                        for (int i = 0;
                            i < snap.data.docs[0]['Timeslots'].length;
                            i++) {
                          DateTime dt = DateTime.now();

                          if (dt.hour > 12) {
                            String st = snap.data.docs[0]['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour - 12) &&
                                snap.data.docs[0]['Timeslots'][i]
                                    .contains('PM')) {
                              timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
                            }
                          } else {
                            String st = snap.data.docs[0]['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour) &&
                                snap.data.docs[0]['Timeslots'][i]
                                    .contains('AM')) {
                              timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
                            }
                          }
                        }
                        if (timeSlots.length == 0) {
                          selectedDate =
                              selectedDate.add(new Duration(days: 1));
                          for (int i = 0;
                              i < snap.data.docs[0]['Timeslots'].length;
                              i++) {
                            timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
                          }
                        }

                        if (selectedDate.difference(DateTime.now()).inDays >=
                            1) {
                          timeSlots.clear();
                          for (int i = 0;
                              i < snap.data.docs[0]['Timeslots'].length;
                              i++) {
                            timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
                          }
                        }
                        return timeSlots.length != 0
                            ? Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: DropdownButtonHideUnderline(
                                      child:
                                          new DropdownButtonFormField<String>(
                                        validator: (value) => value == null
                                            ? 'field required'
                                            : null,
                                        hint: Text('Time Slots'),
                                        value: timeSlots[0],
                                        items: timeSlots.map((String value) {
                                          return new DropdownMenuItem<String>(
                                            value: value,
                                            child: new Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            selectedTime = newValue;

//                      Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container();
                      } else {
                        return Container();
                      }
                    }),
              ),
              Spacer(flex: 1),
              FlatButton(
                  child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Change',
                            style: TextStyle(color: MColors.secondaryColor)),
                      ))),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop(true);
                  })
            ],
          ),
        ),
      ),
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
