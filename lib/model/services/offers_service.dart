//Getting products
import 'dart:convert';

import 'package:wildberries/model/data/offer.dart';
import 'package:wildberries/model/notifiers/offers_notifier.dart';
import 'package:http/http.dart' as http;

String offersAPIUrl = 'https://wild-grocery.herokuapp.com/api/offer';
List<Offer> offersListIUniv = [];
getOffers(OffersNotifier offersNotifier) async {
  var result = await http.get(offersAPIUrl);
  var data = json.decode(result.body);

  List<Offer> offersList = [];
  data.toList().forEach((prodData) {
    Offer offer = Offer.fromMap(prodData);
    if (offer.active == true) offersList.add(offer);
  });
  offersListIUniv = offersList;
  offersNotifier.offersList = offersList;

  // print(offersNotifier.offersList.length);
}
