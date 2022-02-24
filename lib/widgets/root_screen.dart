import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/screens/tab_screens/allCategories.dart';
import 'package:wildberries/screens/tab_screens/home.dart';
import 'package:wildberries/screens/tab_screens/homeScreen_pages/bag.dart';

import 'package:wildberries/screens/tab_screens/search_screens/search_screen.dart';
import 'package:wildberries/screens/tab_screens/settings.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/navbarController.dart';

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../main.dart';
import 'custom_floating_button.dart';
import 'navbar_items.dart';

class RootScreen extends StatefulWidget {
  RootScreen({this.currentScreen});

  final CurrentScreen currentScreen;

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message = '';

  _registerOnFirebase() {
    _firebaseMessaging.requestNotificationPermissions();

    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen;
  int currentTab;
  // AnimationController _controller;

//  final double pi = math.pi;
//   final double tilt90Degrees = 90;
//   double angle = 0;

  // bool get _isPanelVisible {
  //   return angle == tilt90Degrees ? true : false;
  // }

  @override
  initState() {
    super.initState();
    _registerOnFirebase();
    getMessage();
    print("init runs");
    currentScreen = widget.currentScreen?.currentScreen ?? HomeScreen();
    currentTab = widget.currentScreen?.tab_no ?? 0;
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
// //      value: 1,
//       vsync: this,
//     );
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('received message');
      setState(() => _message = message["data"]["body"]);
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["data"]["body"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["data"]["body"]);
    });
  }

  // @override
  // dispose() {
  //   // _controller.dispose();
  //   super.dispose();
  // }

  changeScreen({
    @required Widget currentScreen,
    @required int currentTab,
  }) {
    setState(() {
      this.currentScreen = currentScreen;
      this.currentTab = currentTab;
    });
  }

  // void changeAngle() {
  //   if (angle == 0) {
  //     setState(() {
  //       angle = tilt90Degrees;
  //     });
  //   } else {
  //     setState(() {
  //       angle = 0;
  //     });
  //   }
  // }

  // PersistentTabController _controllerTab =
  //     PersistentTabController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      backgroundColor: MColors.mainColor,

      controller: Controller.controller,
      items: navBarItems,
      screens: _buildScreens(),
//      showElevation: true,
//      navBarCurve: NavBarCurve.upperCorners,
      confineInSafeArea: true,
      handleAndroidBackButtonPress: true,
      iconSize: 26.0,
      navBarStyle:
          NavBarStyle.style12, // Choose the nav bar style with this property
      onItemSelected: (index) {
        print(index);
      },
    );
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      Bag(),
      // Search(true),
      SettingsScreen(),
    ];
  }
}
