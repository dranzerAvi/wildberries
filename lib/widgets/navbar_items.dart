import 'package:flutter/material.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

//factcheck,rule
List<PersistentBottomNavBarItem> navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ("Home"),
    activeColor: MColors.mainColor,
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.category),
    title: ("Categories"),
    activeColor: MColors.mainColor,
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.search),
    title: ("Search"),
    activeColor: MColors.mainColor,
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.notifications),
    title: ("Notifications"),
    activeColor: MColors.mainColor,
    inactiveColor: Colors.white,
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.person),
    title: ("Settings"),
    activeColor: MColors.mainColor,
    inactiveColor: Colors.white,
  ),
];
