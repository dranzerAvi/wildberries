import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:geolocator/geolocator.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/offers_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/notifiers/wishlist_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/model/services/offers_service.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:wildberries/screens/tab_screens/search_screens/search_screen.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import 'allCategories.dart';
import 'dynamic_link_controller.dart';
import 'homeScreen_pages/productDetailsScreen.dart';

class ChoiceCard extends StatelessWidget {
  final Choice choice;

  const ChoiceCard({Key key, this.choice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.display1;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FaIcon(
                choice.icon,
                size: 40.0,
              ),
              Text(choice.title, style: textStyle)
            ],
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Contact Us', icon: FontAwesomeIcons.phone),
  const Choice(title: 'Connect on Whatsapp', icon: FontAwesomeIcons.whatsapp),
  const Choice(title: 'Mail us', icon: FontAwesomeIcons.envelope),
];

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var date2;
  var minOrderValue;
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

  Position _currentPosition;
  String _currentAddress;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  _getCurrentLocation() {
    preferences.setString('status', '').then((value) => print('Changed'));
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print('Pos' + _currentPosition.toString());
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark place = p[0];

      setState(() {
        _currentAddress = "${place.locality}";
      });
    } catch (e) {
      print('error' + e);
    }
  }

  Map<String, List<String>> subCats = {
    'Eggs': [],
    'Fish': [],
    'Chicken': [],
    'Mutton': []
  };

  getSubCats(subCategoryNotifier, cartList, cartProdID, cartNotifier) async {
    await getSubCategories(subCategoryNotifier);
    ProductsNotifier productsNotifier =
        Provider.of<ProductsNotifier>(context, listen: false);

    setState(() {});
    await subCategoryNotifier.subCatsList.forEach((element) {
      if (element.parentId == '6112949447d0ee26fc8bc927') {
        if (subCats['Eggs'] == null)
          subCats['Eggs'] = [element.name];
        else
          subCats.update('Eggs', (value) {
            value.add(element.name);
            return value;
          });
      } else if (element.parentId == '6128d183f56dad3024e8952f') {
        if (subCats['Fish'] == null)
          subCats['Fish'] = [element.name];
        else
          subCats.update('Fish', (value) {
            value.add(element.name);
            return value;
          });
      } else if (element.parentId == '6128d091f56dad3024e89528') {
        if (subCats['Chicken'] == null)
          subCats['Chicken'] = [element.name];
        else
          subCats.update('Chicken', (value) {
            value.add(element.name);
            return value;
          });
      } else if (element.parentId == '612f45928c1629001622a97b') {
        if (subCats['Mutton'] == null)
          subCats['Mutton'] = [element.name];
        else
          subCats.update('Mutton', (value) {
            value.add(element.name);
            return value;
          });
      }
    });
  }

  checkCart() async {
    final Preference<String> userData =
        await preferences.getString('user', defaultValue: '');
    // userData.listen((value) {
    //   print('User $value');
    // });
    userData.listen((value) async {
      if (value == null) {
        user = await UserDataProfile.fromMap(json.decode(value));
      }
      setState(() {
        print(user.token);
      });
    });

    final Preference<String> musicsString =
        await preferences.getString('cart', defaultValue: '');

    musicsString.listen((value) async {
      if (value == null) {
        final String encodedData = Cart.encode(List<Cart>());
        await preferences.setString('cart', encodedData).then((value) {
          // print('Cart Item Updated');
        }).catchError((e) {
          print('Error $e');
        });
      }
    });

    final Preference<String> wishlistString =
        await preferences.getString('wishlist', defaultValue: '');

    musicsString.listen((value) async {
      if (value == null) {
        final String encodedData = ProdProducts.encode(List<ProdProducts>());
        await preferences.setString('wishlist', encodedData).then((value) {
          // print('Cart Item Updated');
        }).catchError((e) {
          print('Error $e');
        });
      }
    });
    // print('User Data $userData');

    //Getting Current cart items
    // final String encodedData = Cart.encode(List<Cart>());
    //
    // await prefs.setString('cart', encodedData).then((value) {
    //   print('Cart Item Updated');
    // }).catchError((e) {
    //   print('Error $e');
    // });
    // print('Encoded Data $encodedData');
  }

  final DynamicLinkController _dynamicLinkController = DynamicLinkController();
  void initDynamicLinks(BuildContext context) async {
    print('Finding link');
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print("deeplink found");
      if (deepLink != null) {
        print(deepLink);
        ProductsNotifier productsNotifier =
            Provider.of<ProductsNotifier>(context, listen: false);
        await getProdProducts(productsNotifier);
        List<ProdProducts> prods = await productsNotifier.productsList;
        int ind = deepLink.toString().lastIndexOf('.link/');
        // print(deepLink.toString().substring(30));

        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => ProductDetailsProv(
                prods
                    .where((element) =>
                        element.id == deepLink.toString().substring(30))
                    .first,
                prods,
                _dynamicLinkController),
          ),
        );
      }
    }, onError: (OnLinkErrorException e) async {
      print("deeplink error");
      print(e.message);
    });
  }

  @override
  void initState() {
    super.initState();
    calculateNextDelivery();
    checkCart();

    _getCurrentLocation();
    // initDynamicLinks(context);
    OffersNotifier offersNotifier =
        Provider.of<OffersNotifier>(context, listen: false);
    getOffers(offersNotifier);
    selectedDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
    dateAddition = 15;
    // addDishParams();
    checkLastSlot();
    time();
    minOrderValue = '50';
    date = DateTime.now();
    date2 = DateTime(date.year, date.month, date.day + dateAddition);

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

                  WishlistNotifier wishlistNotifier =
                      Provider.of<WishlistNotifier>(context, listen: false);
                  getWishlist(wishlistNotifier);
                  // BannerAdNotifier bannerAdNotifier =
                  //     Provider.of<BannerAdNotifier>(context, listen: false);
                  // getBannerAds(bannerAdNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });
    // CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    // var cartList = cartNotifier.cartList;
    SubCategoryNotifier subCategoryNotifier = new SubCategoryNotifier();
    CartNotifier cartNotifier = new CartNotifier();
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);

    getSubCats(subCategoryNotifier, cartList, cartProdID, cartNotifier);
  }

  DateTime date;
  DateTime selectedDate;
  String selectedTime = '';
  int nextDelivery = 8;
  var currentLocationAddress = 'Kolkata, West Bengal';

  var result;
  calculateNextDelivery() async {
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
    //TODO: Place Picker
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
      // print("${first.featureName} : ${first.addressLine}");

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
    //TODO:Check
//     FirebaseFirestore.instance
//         .collection('Timeslots')
//         .snapshots()
//         .forEach((element) {
//       for (int i = 0; i < element.docs[0]['Timeslots'].length; i++) {
//         DateTime dt = DateTime.now();
//
//         if (dt.hour > 12) {
//           String st = element.docs[0]['Timeslots'][i];
//           String s = '';
//           for (int i = 0; i < st.length; i++) {
//             if (st[i] != ' ')
//               s = s + st[i];
//             else
//               break;
//           }
//
//           double d = double.parse(s);
//           if (d > (dt.hour - 12) &&
//               element.docs[0]['Timeslots'][i].contains('PM')) {
//             timeSlots2.add(element.docs[0]['Timeslots'][i]);
//           }
//         } else {
//           String st = element.docs[0]['Timeslots'][i];
//           String s = '';
//           for (int i = 0; i < st.length; i++) {
//             if (st[i] != ' ')
//               s = s + st[i];
//             else
//               break;
//           }
//
//           double d = double.parse(s);
//           if (d > (dt.hour) && element.docs[0]['Timeslots'][i].contains('AM')) {
//             timeSlots2.add(element.docs[0]['Timeslots'][i]);
//           }
//         }
//       }
//       if (timeSlots2.length == 0) {
//         selectedDate = selectedDate.add(new Duration(days: 1));
//         for (int i = 0; i < element.docs[0]['Timeslots'].length; i++) {
//           timeSlots2.add(element.docs[0]['Timeslots'][i]);
//         }
//       }
//       selectedTime = timeSlots2[0];
//     });
// //  if(timeSlots2.length>0){
// //    setState(() {
// //      selectedTime=timeSlots2[0];
// //    });
// //
// //  }
//     select();
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
    //TODO:Check
    // await FirebaseFirestore.instance
    //     .collection('Timeslots')
    //     .snapshots()
    //     .listen((event) {
    //   String st = event.docs[0]['LastSlot'];
    //   String s = '';
    //   for (int i = 0; i < st.length; i++) {
    //     if (st[i] != ' ')
    //       s = s + st[i];
    //     else
    //       break;
    //   }
    //
    //   double d = double.parse(s);
    //   if (st.contains('PM')) d = d + 12;
    //   DateTime dt = DateTime.now();
    //   if (dt.hour > d) {
    //     dateAddition = dateAddition + 1;
    //     print('Date:${dateAddition}');
    //     //run
    //   }
    // });
  }
  TextEditingController cityController = new TextEditingController();
  String city = '';

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
    // print(prods);
    CategoryNotifier categoryNotifier = Provider.of<CategoryNotifier>(context);
    var cats = categoryNotifier.catList;

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.id);

    // BannerAdNotifier bannerAdNotifier = Provider.of<BannerAdNotifier>(context);
    // var bannerAds = bannerAdNotifier.bannerAdsList;
    var bannerAds = [
      'assets/images/2.png',
      'assets/images/3.png',
      'assets/images/4.png',
      'assets/images/5.png'
    ];

    var advBanners = [
      'assets/images/advBanner1.png',
      'assets/images/advBanner2.png',
      'assets/images/advBanner3.png'
    ];

    var testiBanners = [
      'assets/images/testiBanner1.png',
      'assets/images/testiBanner2.png',
    ];
    Choice _selectedChoice = choices[0];

    void _select(Choice choice) {
      setState(() {
        _selectedChoice = choice;
      });
    }

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
//               InkWell(
//                   onTap: () {
//                     launch('tel:+919027553376');
//                   },
//                   child: Icon(
//                     Icons.phone,
//                   )),
//               SizedBox(
//                 width: 8,
//               ),
//               InkWell(
//                   onTap: () {
//                     launchWhatsApp(
//                         phone: '+919027553376',
//                         message: 'Check out this awesome app');
//                   },
//                   child: Container(
//                       alignment: Alignment.center,
//                       child: FaIcon(FontAwesomeIcons.whatsapp))),
//               SizedBox(
//                 width: 8,
//               ),
//               InkWell(
//                   onTap: () {
// //                print(1);
//                     launch(
//                         'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
//                   },
//                   child: Icon(
//                     Icons.mail,
//                   )),
              PopupMenuButton<Choice>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Row(
                        children: [
                          FaIcon(
                            choice.icon,
                            size: 20,
                            color: MColors.mainColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            choice.title,
                            style: boldFont(MColors.mainColor, 14),
                          )
                        ],
                      ),
                      // child: ChoiceCard(
                      //   choice: choice,
                      // )
                    );
                  }).toList();
                },
              ),
              SizedBox(
                width: 14,
              )
            ],
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Wildberries India',
              style: TextStyle(
                  color: MColors.secondaryColor,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
          ),
          drawer: CustomDrawer(
              user != null ? user : getProfile(), prods.toList(), subCats),
          floatingActionButton: CustomFloatingButton(
              CurrentScreen(currentScreen: HomeScreen(), tab_no: 0)),
          key: _scaffoldKey,
          backgroundColor: MColors.primaryWhiteSmoke,
          body: RefreshIndicator(
            onRefresh: () => () async {
              await getProdProducts(productsNotifier);
              await getCart(cartNotifier);
              await getCat(categoryNotifier);
              // await getBannerAds(bannerAdNotifier);
            }(),
            child: _currentAddress != 'Kolkata'
                ? SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Image.asset('assets/images/wb.png'),
                          Center(
                            child: Text(
                              'We are currently not serving your location.',
                              style: TextStyle(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              'Ordering for someone else?',
                              style: boldFont(MColors.mainColor, 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              "Choose Delivery City",
                              style: normalFont(MColors.textGrey, null),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: primaryTextField(
                          //     cityController,
                          //     null,
                          //     "e.g. Kolkata",
                          //     (val) => city = val,
                          //     true,
                          //     null,
                          //     false,
                          //     false,
                          //     true,
                          //     TextInputType.name,
                          //     null,
                          //     null,
                          //     0.50,
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: DropdownButtonFormField(
                              decoration: InputDecoration(
                                hintText: 'Delivery Locations',
                                labelText: "",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              validator: (value) {
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (value) {
                                setState(() {
                                  _currentAddress = value;
                                });
                              },
                              items: ['Kolkata'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: primaryButtonPurple(
                              Text(
                                "Update Location",
                                style: boldFont(
                                  MColors.primaryWhite,
                                  16.0,
                                ),
                              ),
                              () {
                                // _currentAddress = cityController.text;
                                setState(() {});
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 70,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
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
                        ),

//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     color: MColors.mainColor,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: 25,
//                           ),
//                           Icon(Icons.map, color: Colors.white),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           Container(
//                               width: MediaQuery.of(context).size.width * 0.6,
//                               child: currentLocationAddress != null
//                                   ? Text('Deliver to $currentLocationAddress',
//                                       maxLines: 2,
//                                       style: TextStyle(color: Colors.white))
//                                   : Text('Deliver to Kolkata',
//                                       style: TextStyle(color: Colors.white))
//                               // child: Text('Deliver to Kolkata,West Bengal',
//                               //     style: TextStyle(color: Colors.white))
//                               ),
// //                           InkWell(
// //                               onTap: () async {
// //                                 showLocationPicker(
// //                                   context,
// //                                   'AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw',
// //                                   initialCenter: LatLng(31.1975844, 29.9598339),
// //                                   automaticallyAnimateToCurrentLocation: true,
// // //                      mapStylePath: 'assets/mapStyle.json',
// //                                   myLocationButtonEnabled: true,
// //                                   // requiredGPS: true,
// //                                   layersButtonEnabled: true,
// //                                   countries: ['AE'],
// //
// // //                      resultCardAlignment: Alignment.bottomCenter,
// // //                       desiredAccuracy: LocationAccuracy.best,
// //                                 );
// //                                 print("result = $result");
// //                                 setState(() {
// //                                   currentLocationAddress = result;
// //                                   if (currentLocationAddress != null) {
// //                                     minOrderValue = Navigator.of(context).push(
// //                                         MaterialPageRoute(
// //                                             builder: (context) =>
// //                                                 ConfirmAddress(
// //                                                     currentLocationAddress)));
// //
// // //
// //                                   }
// //                                 });
// //                               },
// //                               child: Icon(Icons.edit, color: Colors.white)),
// //                           Container(
// //                               width: MediaQuery.of(context).size.width * 0.1,
// //                               child: Text('${minOrderValue}',
// //                                   style: TextStyle(color: Colors.white))),
// //                           InkWell(
// //                               onTap: () {
// //                                 showPlacePicker();
// //
// // //                              _locationDialog(context);
// //                               },
// //                               child: Icon(Icons.map, color: Colors.white))
//                         ],
//                       ),
//                     ),
//                   ),

                        // Container(
                        //   decoration: BoxDecoration(
                        //       border: Border.all(color: MColors.mainColor),
                        //       borderRadius: BorderRadius.all(Radius.zero)),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Icon(
                        //         Icons.delivery_dining,
                        //         color: MColors.mainColor,
                        //       ),
                        //       SizedBox(width: 5),
                        //       Text(
                        //         'Next Delivery in $nextDelivery hours | Minimum Order Value : ₹ $minOrderValue',
                        //         style: TextStyle(color: Color(0xFF8B0000)),
                        //       ),
                        //
                        //     ],
                        //   ),
                        // ),

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
                              height: 250.0,
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
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: MColors.primaryWhite,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.03),
                                            offset: Offset(0, 10),
                                            blurRadius: 10,
                                            spreadRadius: 0),
                                      ],
                                    ),
                                    child: Image.asset(
                                      banner,
                                      fit: BoxFit.fill,
                                      // placeholder: "assets/images/placeholder.jpg",
                                      // placeholderScale:
                                      //     MediaQuery.of(context).size.width / 2,
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Text(
                                'Best Savings | Fast Delivery | Sealed and Sanatized',
                                style: normalFont(MColors.secondaryColor, 15),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        //FOR YOU BLOCK
                        Builder(
                          builder: (BuildContext context) {
                            Iterable<Cat> cat = cats;
                            var _cats = cat.toList();

                            return cat.length == 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'SHOP BY CATEGORY',
                                              style: boldFont(
                                                  MColors.textDark, 16.0),
                                            ),
                                            // Container(
                                            //   height: 17.0,
                                            //   child: RawMaterialButton(
                                            //     onPressed: seeMore,
                                            //     child: Text(
                                            //       "See more",
                                            //       style: boldFont(MColors.mainColor, 14.0),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          height: 390,
                                          child: Center(
                                              child: progressIndicator(
                                                  MColors.primaryPurple))),
                                    ],
                                  )
                                : blockWigdet2(
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
                                    prods, () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            AllCategories(from: 'home'),
                                      ),
                                    );
                                  }, Icons.category_outlined);
                          },
                        ),

                        SizedBox(height: 20),
                        //NEW BLOCK
                        Builder(
                          builder: (BuildContext context) {
                            Iterable<ProdProducts> newP = prods;
                            var _prods = newP.toList();
                            // print('products');
                            // print(prods);
                            return prods.length == 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Our Sale',
                                              style: boldFont(
                                                  MColors.textDark, 16.0),
                                            ),
                                            Container(
                                              height: 17.0,
                                              child: InkWell(
                                                onTap: () async {
                                                  var title = "SALE";

                                                  var navigationResult =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          SeeMoreScreen(
                                                              title: title,
                                                              products: prods,
                                                              productsNotifier:
                                                                  productsNotifier,
                                                              cartNotifier:
                                                                  cartNotifier,
                                                              cartProdID:
                                                                  cartProdID,
                                                              categoryId: ''),
                                                    ),
                                                  );
                                                  if (navigationResult ==
                                                      true) {
                                                    getCart(cartNotifier);
                                                  }
                                                },
                                                child: Text(
                                                  "See more",
                                                  style: boldFont(
                                                      MColors.mainColor, 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          height: 303,
                                          child: Center(
                                              child: progressIndicator(
                                                  MColors.primaryPurple))),
                                    ],
                                  )
                                : blockWigdet(
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

                                    var navigationResult =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => SeeMoreScreen(
                                          title: title,
                                          products: prods,
                                          productsNotifier: productsNotifier,
                                          cartNotifier: cartNotifier,
                                          cartProdID: cartProdID,
                                          categoryId: '',
                                        ),
                                      ),
                                    );
                                    if (navigationResult == true) {
                                      getCart(cartNotifier);
                                    }
                                  }, profileData, FontAwesomeIcons.checkCircle);
                          },
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 90.0,
                              autoPlay: true,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              viewportFraction: 1,
                              scrollPhysics: BouncingScrollPhysics(),
                            ),
                            items: advBanners.map((banner) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: MColors.primaryWhite,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.03),
                                            offset: Offset(0, 10),
                                            blurRadius: 10,
                                            spreadRadius: 0),
                                      ],
                                    ),
                                    child: Image.asset(
                                      banner,
                                      fit: BoxFit.fill,
                                      // placeholder: "assets/images/placeholder.jpg",
                                      // placeholderScale:
                                      //     MediaQuery.of(context).size.width / 2,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Builder(
                          builder: (BuildContext context) {
                            // Iterable<ProdProducts> newP = prods;
                            var _prods = prods
                                .where((element) =>
                                    element.category['name'] == 'Chicken')
                                .toList();

                            return prods.length == 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Meat',
                                              style: boldFont(
                                                  MColors.textDark, 16.0),
                                            ),
                                            Container(
                                              height: 17.0,
                                              child: InkWell(
                                                onTap: () async {
                                                  var title = "Meat";

                                                  var navigationResult =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          SeeMoreScreen(
                                                        title: title,
                                                        products: _prods,
                                                        productsNotifier:
                                                            productsNotifier,
                                                        cartNotifier:
                                                            cartNotifier,
                                                        cartProdID: cartProdID,
                                                        categoryId: cats
                                                            .where((element) =>
                                                                element.name ==
                                                                'Chicken')
                                                            .first
                                                            .id,
                                                      ),
                                                    ),
                                                  );
                                                  if (navigationResult ==
                                                      true) {
                                                    getCart(cartNotifier);
                                                  }
                                                },
                                                child: Text(
                                                  "See more",
                                                  style: boldFont(
                                                      MColors.mainColor, 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          height: 303,
                                          child: Center(
                                              child: progressIndicator(
                                                  MColors.primaryPurple))),
                                    ],
                                  )
                                : blockWigdet(
                                    "Meat",
                                    "Newly released products",
                                    _picHeight,
                                    itemHeight,
                                    _prods,
                                    cartNotifier,
                                    cartProdID,
                                    _scaffoldKey,
                                    context,
                                    _prods, () async {
                                    var title = "Meat";

                                    var navigationResult =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => SeeMoreScreen(
                                          title: title,
                                          products: _prods,
                                          productsNotifier: productsNotifier,
                                          cartNotifier: cartNotifier,
                                          cartProdID: cartProdID,
                                          categoryId: cats
                                              .where((element) =>
                                                  element.name == 'Chicken')
                                              .first
                                              .id,
                                        ),
                                      ),
                                    );
                                    if (navigationResult == true) {
                                      getCart(cartNotifier);
                                    }
                                  },
                                    profileData, FontAwesomeIcons.drumstickBite,
                                    iconPath:
                                        'assets/images/icons/fishIcon.png');
                          },
                        ),
                        SizedBox(height: 20),
                        Builder(
                          builder: (BuildContext context) {
                            // Iterable<ProdProducts> newP = prods;
                            var _prods = prods
                                .where((element) =>
                                    element.category['name'] == 'Fish')
                                .toList();

                            return prods.length == 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Fish',
                                              style: boldFont(
                                                  MColors.textDark, 16.0),
                                            ),
                                            Container(
                                              height: 17.0,
                                              child: InkWell(
                                                onTap: () async {
                                                  var title = "FISH";

                                                  var navigationResult =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          SeeMoreScreen(
                                                        title: title,
                                                        products: _prods,
                                                        productsNotifier:
                                                            productsNotifier,
                                                        cartNotifier:
                                                            cartNotifier,
                                                        cartProdID: cartProdID,
                                                        categoryId: cats
                                                            .where((element) =>
                                                                element.name ==
                                                                'Fish')
                                                            .first
                                                            .id,
                                                      ),
                                                    ),
                                                  );
                                                  if (navigationResult ==
                                                      true) {
                                                    getCart(cartNotifier);
                                                  }
                                                },
                                                child: Text(
                                                  "See more",
                                                  style: boldFont(
                                                      MColors.mainColor, 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          height: 303,
                                          child: Center(
                                              child: progressIndicator(
                                                  MColors.primaryPurple))),
                                    ],
                                  )
                                : blockWigdet(
                                    "Fish",
                                    "Newly released products",
                                    _picHeight,
                                    itemHeight,
                                    _prods,
                                    cartNotifier,
                                    cartProdID,
                                    _scaffoldKey,
                                    context,
                                    _prods, () async {
                                    var title = "FISH";

                                    var navigationResult =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => SeeMoreScreen(
                                          title: title,
                                          products: _prods,
                                          productsNotifier: productsNotifier,
                                          cartNotifier: cartNotifier,
                                          cartProdID: cartProdID,
                                          categoryId: cats
                                              .where((element) =>
                                                  element.name == 'Fish')
                                              .first
                                              .id,
                                        ),
                                      ),
                                    );
                                    if (navigationResult == true) {
                                      getCart(cartNotifier);
                                    }
                                  }, profileData, FontAwesomeIcons.fish);
                          },
                        ),
                        SizedBox(height: 20),
                        Builder(
                          builder: (BuildContext context) {
                            // Iterable<ProdProducts> newP = prods;
                            var _prods = prods
                                .where((element) =>
                                    element.category['name'] == 'Eggs')
                                .toList();

                            return prods.length == 0
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Eggs',
                                              style: boldFont(
                                                  MColors.textDark, 16.0),
                                            ),
                                            Container(
                                              height: 17.0,
                                              child: InkWell(
                                                onTap: () async {
                                                  var title = "EGGS";

                                                  var navigationResult =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    CupertinoPageRoute(
                                                      builder: (context) =>
                                                          SeeMoreScreen(
                                                        title: title,
                                                        products: _prods,
                                                        productsNotifier:
                                                            productsNotifier,
                                                        cartNotifier:
                                                            cartNotifier,
                                                        cartProdID: cartProdID,
                                                      ),
                                                    ),
                                                  );
                                                  if (navigationResult ==
                                                      true) {
                                                    getCart(cartNotifier);
                                                  }
                                                },
                                                child: Text(
                                                  "See more",
                                                  style: boldFont(
                                                      MColors.mainColor, 14.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5.0),
                                      Container(
                                          height: 303,
                                          child: Center(
                                              child: progressIndicator(
                                                  MColors.primaryPurple))),
                                    ],
                                  )
                                : blockWigdet(
                                    "Eggs",
                                    "Newly released products",
                                    _picHeight,
                                    itemHeight,
                                    _prods,
                                    cartNotifier,
                                    cartProdID,
                                    _scaffoldKey,
                                    context,
                                    prods, () async {
                                    var title = "EGGS";

                                    var navigationResult =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => SeeMoreScreen(
                                          title: title,
                                          products: _prods,
                                          productsNotifier: productsNotifier,
                                          cartNotifier: cartNotifier,
                                          cartProdID: cartProdID,
                                        ),
                                      ),
                                    );
                                    if (navigationResult == true) {
                                      getCart(cartNotifier);
                                    }
                                  }, profileData, FontAwesomeIcons.egg);
                          },
                        ),
                        // SizedBox(height: 10),
                        // Builder(
                        //   builder: (BuildContext context) {
                        //     // Iterable<ProdProducts> newP = prods;
                        //     var _prods = prods
                        //         .where(
                        //             (element) => element.category['name'] == 'Mutton')
                        //         .toList();
                        //
                        //     return blockWigdet(
                        //         "Mutton",
                        //         "Newly released products",
                        //         _picHeight,
                        //         itemHeight,
                        //         _prods,
                        //         cartNotifier,
                        //         cartProdID,
                        //         _scaffoldKey,
                        //         context,
                        //         prods, () async {
                        //       var title = "MUTTON";
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
                        //     }, profileData);
                        //   },
                        // ),
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
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 150.0,
                              autoPlay: true,
                              enableInfiniteScroll: false,
                              initialPage: 0,
                              viewportFraction: 1,
                              scrollPhysics: BouncingScrollPhysics(),
                            ),
                            items: testiBanners.map((banner) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    decoration: BoxDecoration(
                                      color: MColors.primaryWhite,
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.03),
                                            offset: Offset(0, 10),
                                            blurRadius: 10,
                                            spreadRadius: 0),
                                      ],
                                    ),
                                    child: Image.asset(
                                      banner,
                                      fit: BoxFit.fill,
                                      // placeholder: "assets/images/placeholder.jpg",
                                      // placeholderScale:
                                      //     MediaQuery.of(context).size.width / 2,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 10),
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
                padding: const EdgeInsets.all(10.0), //TODO:Check
//                 child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('Timeslots')
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snap) {
//                       if (snap.hasData && !snap.hasError && snap.data != null) {
//                         timeSlots.clear();
//                         for (int i = 0;
//                             i < snap.data.docs[0]['Timeslots'].length;
//                             i++) {
//                           DateTime dt = DateTime.now();
//
//                           if (dt.hour > 12) {
//                             String st = snap.data.docs[0]['Timeslots'][i];
//                             String s = '';
//                             for (int i = 0; i < st.length; i++) {
//                               if (st[i] != ' ')
//                                 s = s + st[i];
//                               else
//                                 break;
//                             }
//
//                             double d = double.parse(s);
//                             if (d > (dt.hour - 12) &&
//                                 snap.data.docs[0]['Timeslots'][i]
//                                     .contains('PM')) {
//                               timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                             }
//                           } else {
//                             String st = snap.data.docs[0]['Timeslots'][i];
//                             String s = '';
//                             for (int i = 0; i < st.length; i++) {
//                               if (st[i] != ' ')
//                                 s = s + st[i];
//                               else
//                                 break;
//                             }
//
//                             double d = double.parse(s);
//                             if (d > (dt.hour) &&
//                                 snap.data.docs[0]['Timeslots'][i]
//                                     .contains('AM')) {
//                               timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                             }
//                           }
//                         }
//                         if (timeSlots.length == 0) {
//                           selectedDate =
//                               selectedDate.add(new Duration(days: 1));
//                           for (int i = 0;
//                               i < snap.data.docs[0]['Timeslots'].length;
//                               i++) {
//                             timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                           }
//                         }
//
//                         if (selectedDate.difference(DateTime.now()).inDays >=
//                             1) {
//                           timeSlots.clear();
//                           for (int i = 0;
//                               i < snap.data.docs[0]['Timeslots'].length;
//                               i++) {
//                             timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                           }
//                         }
//                         return timeSlots.length != 0
//                             ? Column(
//                                 children: [
//                                   Container(
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.9,
//                                     child: DropdownButtonHideUnderline(
//                                       child:
//                                           new DropdownButtonFormField<String>(
//                                         validator: (value) => value == null
//                                             ? 'field required'
//                                             : null,
//                                         hint: Text('Time Slots'),
//                                         value: timeSlots[0],
//                                         items: timeSlots.map((String value) {
//                                           return new DropdownMenuItem<String>(
//                                             value: value,
//                                             child: new Text(value),
//                                           );
//                                         }).toList(),
//                                         onChanged: (String newValue) {
//                                           setState(() {
//                                             selectedTime = newValue;
//
// //                      Navigator.pop(context);
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Container();
//                       } else {
//                         return Container();
//                       }
//                     }),
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
//TODO:Check
  // final db = FirebaseFirestore.instance;
  //
  // addDishParams() {
  //   db.collection('food').getDocuments().then((value) {
  //     value.documents.forEach((element) {
  //       db.collection('food').document(element.documentID).updateData({
  //         'nameSearch': setSearchParam(element['name']),
  //         'categorySearch': setSearchParam(element['category']),
  //       });
  //     });
  //   });
  // }
  //
  // setSearchParam(String caseString) {
  //   List<String> caseSearchList = List();
  //   String temp = "";
  //   for (int i = 0; i < caseString.length; i++) {
  //     temp = temp + caseString[i];
  //     caseSearchList.add(temp);
  //   }
  //   return caseSearchList;
  // }
}
