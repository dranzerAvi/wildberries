import 'package:flutter/foundation.dart';
import 'package:mrpet/model/data/cart.dart';
import 'package:mrpet/model/data/wishlist.dart';

class WishlistNotifier with ChangeNotifier {
  List<Wishlist> _wishlistList = [];
  Wishlist _wishlist;

  List<Wishlist> get wishlistList => _wishlistList;
  Wishlist get wishlist => _wishlist;

  set wishlistList(List<Wishlist> wishlistList) {
    _wishlistList = wishlistList;
    notifyListeners();
  }

  set wishlist(Wishlist wishlist) {
    _wishlist = wishlist;
    notifyListeners();
  }
}
