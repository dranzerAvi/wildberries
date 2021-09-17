import 'package:flutter/material.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

//factcheck,rule
List<PersistentBottomNavBarItem> navBarItems = [
  PersistentBottomNavBarItem(
    icon: Icon(Icons.home),
    title: ("Home"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.category),
    title: ("Categories"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.search),
    title: ("Search"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
  PersistentBottomNavBarItem(
    icon: Icon(Icons.person),
    title: ("Settings"),
    activeColor: Colors.white,
    inactiveColor: Colors.white.withOpacity(0.5),
  ),
];
