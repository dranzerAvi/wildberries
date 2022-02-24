import 'package:flutter/foundation.dart';
import 'package:wildberries/model/data/orders.dart';

class OrderListNotifier with ChangeNotifier {
  List<Order> _ordersListList = [];

  List<Order> get orderListList => _ordersListList;

  set orderListList(List<Order> ordersListList) {
    _ordersListList = ordersListList;
    notifyListeners();
  }
}
