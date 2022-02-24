import 'package:flutter/foundation.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/wishlist.dart';

class WishlistNotifier with ChangeNotifier {
  List<ProdProducts> _wishList = [];

  List<ProdProducts> get wishList => _wishList;

  set wishList(List<ProdProducts> wishList) {
    _wishList = wishList;
    notifyListeners();
  }
}
