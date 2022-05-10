import 'dart:convert';
import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:wildberries/model/services/pushNotification_service.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/screens/getstarted_screens/intro_screen.dart';
import 'package:wildberries/screens/settings_screens/cards.dart';
import 'package:wildberries/screens/settings_screens/editProfile.dart';
import 'package:wildberries/screens/settings_screens/passwordSecurity.dart';
import 'package:wildberries/screens/settings_screens/subscriptions.dart';
import 'package:wildberries/screens/tab_screens/history.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:wildberries/widgets/navDrawer.dart';
import 'package:wildberries/widgets/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/screens/address/myaddresses.dart';

import 'checkout_screens/enterAddress.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future profileFuture;
  Future addressFuture;
  UserDataProfile user = UserDataProfile();
  List<UserDataAddress> addresses = [];
  getUserAdresses() async {
    Preference<String> addressesString =
        preferences.getString('addresses', defaultValue: '');
    addressesString.listen((value) {
      if (value != '') {
        addresses = UserDataAddress.decode(value);
      }
    });
  }

  // User user;
  @override
  void initState() {
    getUserAdresses();
    // user = FirebaseAuth.instance.currentUser;
    // checkInternetConnectivity().then((value) => {
    //       value == true
    //           ? () {
    //               UserDataProfileNotifier profileNotifier =
    //                   Provider.of<UserDataProfileNotifier>(context,
    //                       listen: false);
    //               profileFuture = getProfile(profileNotifier);
    //               user = profileNotifier.userDataProfile;
    //
    //               UserDataAddressNotifier addressNotifier =
    //                   Provider.of<UserDataAddressNotifier>(context,
    //                       listen: false);
    //               addressFuture = getAddress(addressNotifier);
    //             }()
    //           : showNoInternetSnack(_scaffoldKey)
    //     });

    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var addressList;

    return PreferenceBuilder<String>(
        preference: preferences.getString(
          'user',
          defaultValue: '',
        ),
        builder: (BuildContext context, String userString) {
          // print(userString);
          var cartTotal = 0;
          if (userString != '')
            user = UserDataProfile.fromMap(json.decode(userString));

          return userString == ''
              ? showLoggedOutSettings()
              : showSettings(user, addresses);
        });
  }

  Widget showLoggedOutSettings() {
    List listTileIcons, listTileNames, listTileActions;

    listTileIcons = [
      " ",
      " ",
      " ",
      " ",
      " ",
      "assets/images/logout.svg",
    ];

    listTileNames = [
      "Terms and Conditions",
      "Return Policy",
      "Cancellation Policy",
      "Privacy Policy",
      "Refund Policy",
      "Sign in",
    ];

    listTileActions = [
      () {
        launch('https://www.misterpet.ae/terms-and-conditions/');
      },
      () {
        launch('https://www.misterpet.ae/return-policy/');
      },
      () {
        launch('https://www.misterpet.ae/cancellation-policy/');
      },
      () {
        launch('https://www.misterpet.ae/privacy-policy/');
      },
      () {
        launch('https://www.misterpet.ae/refund-policy/');
      },
      () {
        pushNewScreen(
          context,
          screen: IntroScreen(),
          withNavBar: false, // OPTIONAL VALUE. True by default.
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
    ];

    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
      key: _scaffoldKey,
      floatingActionButton: CustomFloatingButton(
          CurrentScreen(currentScreen: SettingsScreen(), tab_no: 0)),
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
          'Wildberries    ',
          style: TextStyle(
              color: MColors.secondaryColor,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: primaryContainer(
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(),
                SizedBox(height: 20.0),
                Divider(
                  height: 1.0,
                ),
                Container(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: listTileNames.length,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                          future: addressFuture,
                          builder: (c, s) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  listTileButton(
                                    listTileActions[i],
                                    listTileIcons[i],
                                    listTileNames[i],
                                    i == 9 ? Colors.red : MColors.textDark,
                                  ),
                                  Divider(
                                    height: 1.0,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 20,
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Text(
                  "Version 0.1.4",
                  style: normalFont(MColors.textGrey, 14.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showSettings(UserDataProfile user, addressList) {
    var _checkAddress;
    addressList == null || addressList.isEmpty
        ? _checkAddress = null
        : _checkAddress = addressList.first;
    var _address = _checkAddress;
    List listTileIcons, listTileNames, listTileActions;
    if (user != null) {
      listTileIcons = user.subscription == 'member'
          ? [
              "assets/images/online-order.svg",
              // "assets/images/password.svg",
              // "assets/images/icons/Wallet.svg",
              "assets/images/icons/Location.svg",
              " ",
              " ",
              " ",
              " ",
              " ",
              " ",
              "assets/images/logout.svg",
            ]
          : [
              "assets/images/online-order.svg",
              // "assets/images/password.svg",
              // "assets/images/icons/Wallet.svg",
              "assets/images/icons/Location.svg",
              " ",
              " ",
              " ",
              " ",
              " ",
              " ",
              "assets/images/logout.svg",
            ];

      listTileNames = user.subscription == 'member'
          ? [
              "Your Orders",
              "Address",
              "Subscription Options",
              "Terms and Conditions",
              "Return Policy",
              "Cancellation Policy",
              "Privacy Policy",
              "Refund Policy",
              "Sign Out",
            ]
          : [
              "Your Orders",

              // "Security",
              // "Cards",
              "Address",
              "Subscription Details",
              // "Your Orders",
              "Terms and Conditions",
              "Return Policy",
              "Cancellation Policy",
              "Privacy Policy",
              "Refund Policy",
              "Sign Out",
            ];

      listTileActions = user.subscription == 'member'
          ? [
              () {
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
              // () {
              //   Navigator.of(context).push(
              //     CupertinoPageRoute(
              //       builder: (_) => SecurityScreen(),
              //     ),
              //   );
              // },
              // () {
              //   Navigator.of(context).push(
              //     CupertinoPageRoute(
              //       builder: (_) => Cards1(),
              //     ),
              //   );
              // },

              () async {
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => MyAddresses(addresses),
                  ),
                );
                if (navigationResult == true) {
                  UserDataAddressNotifier addressNotifier =
                      Provider.of<UserDataAddressNotifier>(context,
                          listen: false);

                  setState(() {
                    getAddress(addressNotifier);
                  });
                  showSimpleSnack(
                    "Address has been updated",
                    Icons.check_circle_outline,
                    Colors.green,
                    _scaffoldKey,
                  );
                }
              },
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => SubscriptionsScreen(),
                  ),
                );
              },
              () {
                launch('https://www.misterpet.ae/terms-and-conditions/');
              },
              () {
                launch('https://www.misterpet.ae/return-policy/');
              },
              () {
                launch('https://www.misterpet.ae/cancellation-policy/');
              },
              () {
                launch('https://www.misterpet.ae/privacy-policy/');
              },
              () {
                launch('https://www.misterpet.ae/refund-policy/');
              },
              () {
                _showLogOutDialog();
              },
            ]
          : [
              () {
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
              // () {
              //   Navigator.of(context).push(
              //     CupertinoPageRoute(
              //       builder: (_) => SecurityScreen(),
              //     ),
              //   );
              // },
              // () {
              //   Navigator.of(context).push(
              //     CupertinoPageRoute(
              //       builder: (_) => Cards1(),
              //     ),
              //   );
              // },
              () async {
                var navigationResult = await Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => MyAddresses(addresses),
                  ),
                );
                if (navigationResult == true) {
                  UserDataAddressNotifier addressNotifier =
                      Provider.of<UserDataAddressNotifier>(context,
                          listen: false);

                  setState(() {
                    getAddress(addressNotifier);
                  });
                  showSimpleSnack(
                    "Address has been updated",
                    Icons.check_circle_outline,
                    Colors.green,
                    _scaffoldKey,
                  );
                }
              },
              () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => SubscriptionsScreen(),
                  ),
                );
              },
              () {
                launch('https://www.misterpet.ae/terms-and-conditions/');
              },
              () {
                launch('https://www.misterpet.ae/return-policy/');
              },
              () {
                launch('https://www.misterpet.ae/cancellation-policy/');
              },
              () {
                launch('https://www.misterpet.ae/privacy-policy/');
              },
              () {
                launch('https://www.misterpet.ae/refund-policy/');
              },
              () {
                _showLogOutDialog();
              },
            ];
    } else {
      listTileIcons = [
        " ",
        " ",
        " ",
        " ",
        " ",
        "assets/images/logout.svg",
      ];

      listTileNames = [
        "Terms and Conditions",
        "Return Policy",
        "Cancellation Policy",
        "Privacy Policy",
        "Refund Policy",
        "Sign in",
      ];

      listTileActions = [
        () {
          launch('https://www.misterpet.ae/terms-and-conditions/');
        },
        () {
          launch('https://www.misterpet.ae/return-policy/');
        },
        () {
          launch('https://www.misterpet.ae/cancellation-policy/');
        },
        () {
          launch('https://www.misterpet.ae/privacy-policy/');
        },
        () {
          launch('https://www.misterpet.ae/refund-policy/');
        },
        () {
          pushNewScreen(
            context,
            screen: IntroScreen(),
            withNavBar: false, // OPTIONAL VALUE. True by default.
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
      ];
    }
    // print('User Profile');
    // print('https://wild-grocery.herokuapp.com/${user.imgURL}'
    //     .replaceAll('\\', '/'));

    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
      key: _scaffoldKey,
      floatingActionButton: CustomFloatingButton(
          CurrentScreen(currentScreen: SettingsScreen(), tab_no: 0)),
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
          'Wildberries    ',
          style: TextStyle(
              color: MColors.secondaryColor,
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: primaryContainer(
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                user != null
                    ? Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  UserDataProfileNotifier profileNotifier =
                                      Provider.of<UserDataProfileNotifier>(
                                          context,
                                          listen: false);
                                  var navigationResult =
                                      await Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => EditProfile(user),
                                    ),
                                  );
                                  if (navigationResult == true) {
                                    setState(() {
                                      getProfile(profileNotifier);
                                    });
                                    showSimpleSnack(
                                      "Profile has been updated",
                                      Icons.check_circle_outline,
                                      Colors.green,
                                      _scaffoldKey,
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Hero(
                                    tag: "profileAvatar",
                                    child: user.imgURL == null ||
                                            user.imgURL == ""
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                            child: Image.asset(
                                              "assets/images/Logo-FINAL.png",
                                              height: 90.0,
                                              width: 90.0,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(9.0),
                                            child: FadeInImage.assetNetwork(
                                              image:
                                                  'https://wild-grocery.herokuapp.com/${user.imgURL}'
                                                      .replaceAll('\\', '/'),
                                              fit: BoxFit.fill,
                                              height: 90.0,
                                              width: 90.0,
                                              placeholder:
                                                  "assets/images/WilddberriesIcon.jpeg",
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            RawMaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 0.0,
                              hoverElevation: 0.0,
                              focusElevation: 0.0,
                              highlightElevation: 0.0,
                              onPressed: () async {
                                UserDataProfileNotifier profileNotifier =
                                    Provider.of<UserDataProfileNotifier>(
                                        context,
                                        listen: false);
                                var navigationResult =
                                    await Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => EditProfile(user),
                                  ),
                                );
                                if (navigationResult == true) {
                                  setState(() {
                                    getProfile(profileNotifier);
                                  });
                                  showSimpleSnack(
                                    "Profile has been updated",
                                    Icons.check_circle_outline,
                                    Colors.green,
                                    _scaffoldKey,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            user.firstName != null &&
                                                    user.lastName != null
                                                ? user.firstName + user.lastName
                                                : '',
                                            style: boldFont(
                                                MColors.textDark, 16.0),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 5.0),
                                          user.subscription == 'member'
                                              ? Container()
                                              : Container(
                                                  width: 108,
                                                  height: 18.0,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                2.0)),
                                                    color: MColors.mainColor,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                        "  PRIME MEMBER  ",
                                                        style: normalFont(
                                                            MColors
                                                                .primaryPurple,
                                                            12.0)),
                                                  ),
                                                ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            user.email != null
                                                ? user.email
                                                : '',
                                            style: normalFont(
                                                MColors.textGrey, 14.0),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Container(
                                      width: 100,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        color: MColors.mainColor,
                                      ),
                                      child: Center(
                                        child: Text("EDIT PROFILE",
                                            style: normalFont(
                                                MColors.primaryPurple, 12.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(height: 20.0),
                Divider(
                  height: 1.0,
                ),
                Container(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: listTileNames.length,
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                          future: addressFuture,
                          builder: (c, s) {
                            return Container(
                              child: Column(
                                children: <Widget>[
                                  listTileButton(
                                    listTileActions[i],
                                    listTileIcons[i],
                                    listTileNames[i],
                                    i == 9 ? Colors.red : MColors.textDark,
                                  ),
                                  Divider(
                                    height: 1.0,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 20,
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Text(
                  "Version 0.1.4",
                  style: normalFont(MColors.textGrey, 14.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                    // AuthService auth = MyProvider.of(context).auth;
                    AuthService().signOut();
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
