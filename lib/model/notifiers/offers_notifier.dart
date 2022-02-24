import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:wildberries/model/data/offer.dart';

class OffersNotifier with ChangeNotifier {
  List<Offer> _offersList = [];

  UnmodifiableListView<Offer> get offersList =>
      UnmodifiableListView(_offersList);

  // Brands get brands => _brands;

  set offersList(List<Offer> offersList) {
    _offersList = offersList;
    notifyListeners();
  }

// set brands(Brands brands) {
//   _brands = brands;
//   notifyListeners();
// }
}
