import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:wildberries/model/data/brands.dart';
import 'package:wildberries/model/data/filter.dart';

class FiltersNotifier with ChangeNotifier {
  List<Filter> _filtersList = [];

  UnmodifiableListView<Filter> get filtersList =>
      UnmodifiableListView(_filtersList);

  // Brands get brands => _brands;

  set filtersList(List<Filter> filtersList) {
    _filtersList = filtersList;
    notifyListeners();
  }

  // set brands(Brands brands) {
  //   _brands = brands;
  //   notifyListeners();
  // }
}
