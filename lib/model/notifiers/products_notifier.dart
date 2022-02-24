import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/data/leafCategory.dart';
import 'package:wildberries/model/data/subCategory.dart';

class ProductsNotifier with ChangeNotifier {
  List<ProdProducts> _prodProductsList = [];
  ProdProducts _currentProdProduct;

  UnmodifiableListView<ProdProducts> get productsList =>
      UnmodifiableListView(_prodProductsList);

  ProdProducts get currentProdProduct => _currentProdProduct;

  set productsList(List<ProdProducts> prodProductsList) {
    _prodProductsList = prodProductsList;
    notifyListeners();
  }

  set currentProdProduct(ProdProducts prodProducts) {
    _currentProdProduct = prodProducts;
    notifyListeners();
  }
}

class CategoryNotifier with ChangeNotifier {
  List<Cat> _catList = [];
  Cat _cat;

  UnmodifiableListView<Cat> get catList => UnmodifiableListView(_catList);

  Cat get currentProdProduct => _cat;

  set productsList(List<Cat> catList) {
    _catList = catList;
    notifyListeners();
  }

  set currentProdProduct(Cat cat) {
    _cat = cat;
    notifyListeners();
  }
}

class SubCategoryNotifier with ChangeNotifier {
  List<SubCategory> _subCatsList = [];

  UnmodifiableListView<SubCategory> get subCatsList =>
      UnmodifiableListView(_subCatsList);

  // Brands get brands => _brands;

  set subCatsList(List<SubCategory> subCatsList) {
    _subCatsList = subCatsList;
    notifyListeners();
  }
}

class LeafCategoryNotifier with ChangeNotifier {
  List<LeafCategory> _leafCatsList = [];

  UnmodifiableListView<LeafCategory> get leafCatsList =>
      UnmodifiableListView(_leafCatsList);

  // Brands get brands => _brands;

  set leafCatsList(List<LeafCategory> leafCatsList) {
    _leafCatsList = leafCatsList;
    notifyListeners();
  }
}
// class LeafCategoryNotifier with ChangeNotifier {
//   List<Filter> _filtersList = [];
//
//   UnmodifiableListView<Filter> get filtersList =>
//       UnmodifiableListView(_filtersList);
//
//   // Brands get brands => _brands;
//
//   set filtersList(List<Filter> filtersList) {
//     _filtersList = filtersList;
//     notifyListeners();
//   }
//
// // set brands(Brands brands) {
// //   _brands = brands;
// //   notifyListeners();
// // }
// }
