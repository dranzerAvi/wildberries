import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getflutter/getflutter.dart';
import 'package:location/location.dart';
import 'package:mrpet/model/data/Products.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/products_notifier.dart';
import 'package:mrpet/model/notifiers/userData_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/model/services/auth_service.dart';
import 'package:mrpet/model/services/user_management.dart';
import 'package:mrpet/screens/getstarted_screens/intro_screen.dart';
import 'package:mrpet/screens/tab_screens/allCategories.dart';
import 'package:mrpet/screens/tab_screens/history.dart';
import 'package:mrpet/screens/tab_screens/homeScreen_pages/seeMoreScreen.dart';
import 'package:mrpet/screens/tab_screens/settings.dart';
import 'package:mrpet/screens/wishlistScreen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/internetConnectivity.dart';
import 'package:mrpet/utils/navbarController.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List categories = [];
  getCategories() {
    Firestore.instance.collection('Categories').getDocuments().then((value) {
      for (var v in value.documents) {
        print('----------------$v');
        categories.add(v);
      }
    });
  }

  Location loc = new Location();
  LocationData _currentPosition;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  String currentAddress = 'Enter Address';
  Future<Position> _getCurrentLocation() async {
    _currentPosition = await loc.getLocation();
//    Position position = await geolocator.getCurrentPosition(
//        desiredAccuracy: LocationAccuracy.high);
//    print(position);
//    geolocator
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
//        .then((Position position) {
//      setState(() {
//        _currentPosition = position;
//      });
    print(_currentPosition);
    _getAddressFromLatLng();
    print(_currentPosition);
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        currentAddress = "${place.subLocality}, ${place.locality}";
        print(currentAddress);
        location = currentAddress;
        pass.text = currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  var location = 'Dubai';
  final pass = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future profileFuture;
  Future addressFuture;

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  UserDataProfileNotifier profileNotifier =
                      Provider.of<UserDataProfileNotifier>(context,
                          listen: false);
                  profileFuture = getProfile(profileNotifier);

                  UserDataAddressNotifier addressNotifier =
                      Provider.of<UserDataAddressNotifier>(context,
                          listen: false);
                  addressFuture = getAddress(addressNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserDataProfileNotifier profileNotifier =
        Provider.of<UserDataProfileNotifier>(context);
    var checkUser = profileNotifier.userDataProfileList;
    var user;
    checkUser.isEmpty || checkUser == null
        ? user = null
        : user = checkUser.first;

    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context);
    var checkaddressList = addressNotifier.userDataAddressList;
    var addressList;
    checkaddressList.isEmpty || checkaddressList == null
        ? addressList = null
        : addressList = checkaddressList;
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
            return checkUser.isEmpty || checkUser == null
                ? retNavDrawer(user, addressList, context)
                : retNavDrawer(user, addressList, context);

            break;
          case ConnectionState.waiting:
            return retNavDrawer(user, addressList, context);
            break;
          default:
            return retNavDrawer(user, addressList, context);
        }
      },
    );
  }

  Widget retNavDrawer(user, addressList, context) {
    ProductsNotifier productsNotifier = Provider.of<ProductsNotifier>(context);
    var prods = productsNotifier.productsList;

    CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    var cartList = cartNotifier.cartList;
    var cartProdID = cartList.map((e) => e.productID);

    var _checkAddress;
    addressList == null || addressList.isEmpty
        ? _checkAddress = null
        : _checkAddress = addressList.first;
    var _address = _checkAddress;

    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SafeArea(
              child: user != null
                  ? Container(
                      // alignment: Alignment.center,
                      height: 80,
                      color: MColors.secondaryColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePhoto ==
                                      null
                                  ? 'https://firebasestorage.googleapis.com/v0/b/mrpet-3387f.appspot.com/o/unnamed.png?alt=media&token=2c39a045-ff4a-4f12-8071-13f82a71b426'
                                  : user.profilePhoto),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  user.name,
                                  style: normalFont(
                                      MColors.primaryWhiteSmoke, 14.0),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  user.email,
                                  style: normalFont(
                                      MColors.primaryWhiteSmoke, 14.0),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ],
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
                        color: MColors.secondaryColor,
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
                              Text(
                                'Sign In/Sign Up',
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
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
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                'Home',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.w600),
              ),
            ),x
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
          ListTile(
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                'Shop by Category',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.w600),
              ),
            ),
            onTap: () {
              pushNewScreen(context,
                  screen: AllCategories(
                    from: 'drawer',
                  ));
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ListTile(
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                'My Wishlist',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.w600),
              ),
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
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                'My Orders',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.w600),
              ),
            ),
            onTap: () {
              pushNewScreen(context, screen: HistoryScreen());
            },
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ListTile(
              title: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Text(
                  'On Sale',
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'nunito',
                      fontWeight: FontWeight.w600),
                ),
              ),
              onTap: () async {
                Iterable<ProdProducts> popular =
                    prods.where((e) => e.discount != null);
                var _prods = popular.toList();
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
              }),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 0.5,
            color: Colors.black26,
          ),
          ListTile(
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Text(
                'App Settings',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'nunito',
                    fontWeight: FontWeight.w600),
              ),
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
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'nunito',
                          fontWeight: FontWeight.w600),
                    ),
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
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all(
                                color: MColors.secondaryColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(FontAwesomeIcons.whatsapp)),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all(
                                color: MColors.secondaryColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(FontAwesomeIcons.instagram)),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            border: Border.all(
                                color: MColors.secondaryColor, width: 2)),
                        alignment: Alignment.center,
                        child: FaIcon(FontAwesomeIcons.facebook))
                  ],
                )),
          )
        ],
      ),
    );
  }

  User user;

  String name = ' ',
      email = ' ',
      url =
          'https://firebasestorage.googleapis.com/v0/b/angadi-9c0e9.appspot.com/o/user%20.png?alt=media&token=4f8258f6-a74f-47b4-856e-f0c493179d67';
  getUserDetails() async {
    user = await FirebaseAuth.instance.currentUser;
    Firestore.instance
        .collection('Users')
        .where('id', isEqualTo: user.uid)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          name = element['Name'];
          email = element['mail'];
          url = element['pUrl'];
        });
      });
    });
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
                    auth.signOut();
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (_) => MyApp(),
                      ),
                    );
                    print("Signed out.");
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
