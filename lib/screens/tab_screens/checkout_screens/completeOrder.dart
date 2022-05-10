import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/filter.dart';
import 'package:wildberries/model/data/offer.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/offers_notifier.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:wildberries/model/services/offers_service.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/screens/address/myaddresses.dart';
import 'package:wildberries/screens/tab_screens/checkout_screens/addPaymentMethod.dart';
import 'package:uuid/uuid.dart';
import 'package:wildberries/screens/tab_screens/home.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:wildberries/utils/navbarController.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/screens/tab_screens/checkout_screens/enterAddress.dart';
import 'package:http/http.dart' as http;

// import 'package:firebase_auth/firebase_auth.dart';
import 'orderPlaced.dart';
import 'package:wildberries/screens/address/myaddresses2.dart';

class TutorialOverlay extends ModalRoute<void> {
  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(0.2),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)), //this right here
              child: Container(
                height: 400.0,
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Your order has been placed successfully',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text.rich(
                          //   TextSpan(
                          //     text: "Ordered ID:  ",
                          //     style: TextStyle(
                          //       color: Colors.black,
                          //       fontSize: 13,
                          //     ),
                          //     children: [
                          //       TextSpan(
                          //         text: '${o.id}',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Text.rich(
                          //   TextSpan(
                          //     text: "Ordered on:  ",
                          //     style: TextStyle(
                          //       color: Colors.black,
                          //       fontSize: 13,
                          //     ),
                          //     children: [
                          //       TextSpan(
                          //         text:
                          //             '${order.timestamp.toDate().day}-${order.timestamp.toDate().month}-${order.timestamp.toDate().year}',
                          //         style: TextStyle(
                          //           fontWeight: FontWeight.bold,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Text.rich(
                            TextSpan(
                              text: "Status:  ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Order Placed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: 200,
                        child: Lottie.asset('assets/images/order_packed.json')),
                    Spacer(),
                    // Container(
                    //   width: double.infinity,
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 2,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: kPrimaryColor,
                    //     borderRadius: BorderRadius.only(
                    //       bottomLeft: Radius.circular(10),
                    //       bottomRight: Radius.circular(10),
                    //     ),
                    //   ),
                    //   child: FlatButton(
                    //     color: MColors.mainColor,
                    //     child: Text(
                    //       "Order Total - ${or.amount}",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w600,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}

class AddressContainer extends StatefulWidget {
  final List<Cart> cartList;
  String address;
  String savedEmirate;
  AddressContainer(this.cartList, this.address, this.savedEmirate);
  @override
  _AddressContainerState createState() =>
      _AddressContainerState(cartList, address);
}

class AddressScreen extends StatefulWidget {
  final List<Cart> cartList;
  String address;
  AddressScreen(this.cartList, this.address);

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  var currentLocationAddress = 'Bareilly, Uttar Pradesh';

  getUserCurrentLocation() async {
    String error;

    try {
      // Position position = await Geolocator()
      //     .getCurrentPosition(desiredAccuracy: gl.LocationAccuracy.high);
      // final coordinates = Coordinates(position.latitude, position.longitude);
      // var addresses =
      //     await Geocoder.local.findAddressesFromCoordinates(coordinates);
      // var first = addresses.first;
      // print("${first.featureName} : ${first.addressLine}");
      //
      // setState(() {
      //   currentLocationAddress = '${first.subLocality}, ${first.locality}';
      // });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        Navigator.pop(context);
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        Navigator.pop(context);

        error = 'permission denied- please enable it from app settings';
        print(error);
      }
    }
  }

  getUserAddresses() async {}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserDataAddressNotifier>(
            create: (context) => UserDataAddressNotifier(),
          ),
          ChangeNotifierProvider<CartNotifier>(
            create: (context) => CartNotifier(),
          ),
          ChangeNotifierProvider<UserDataCardNotifier>(
            create: (context) => UserDataCardNotifier(),
          ),
          ChangeNotifierProvider<OffersNotifier>(
            create: (context) => OffersNotifier(),
          ),
        ],
        child: AddressContainer(widget.cartList, widget.address, ''),
      ),
    );
  }
}

class _AddressContainerState extends State<AddressContainer> {
  final List<Cart> cartList;
  Future addressFuture,
      cardFuture,
      completeOrderFuture,
      dateFuture,
      offersFuture;
  bool isDateSelected;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<bool> isComplete = Future.value(false);
  DateTime date;
  List<String> timeSlots2 = [];
  // User user;

  int dateAddition;

  var dd;
  _AddressContainerState(this.cartList, address);
  var addresstype = 'House';
  var color1 = false;
  var color2 = true;
  var color3 = false;
  List<UserDataAddress> addressList = [];
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final phncontroller = TextEditingController();
  // final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();
  final additionalcontroller = TextEditingController();
  final hnoController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  double minOrderPrice = 0;
  double deliveryCharge = 0;
  // List<Emirates> savedemirate = [];
  // List<Emirates> allemirates = [];
  String emirate2;
  List<String> emiratesname = [];
  String emirate;
  var date2;
  DateTime selectedDate;
  String selectedTime = '';

  getUserAddresses() async {
    //Getting Current cart items
    final Preference<String> musicsString =
        await preferences.getString('addresses', defaultValue: '');
    await musicsString.listen((value) {
      if (value != '') addressList = UserDataAddress.decode(value);
    });
    addressController.text =
        addressList.length == 0 ? '' : addressList[0].address;
    zipController.text =
        addressList.length == 0 ? '' : addressList[0].zip.toString();
    cityController.text = addressList.length == 0 ? '' : addressList[0].city;
    setState(() {});
  }

  static const platform = const MethodChannel("razorpay_flutter");
  Razorpay _razorpay;
  String random = randomAlpha(10);
  Future<String> generateOrderId(
      String key, String secret, double amount) async {
    var authn = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      'content-type': 'application/json',
      'Authorization': authn,
    };

    var data =
        '{ "amount": $amount, "currency": "INR", "receipt": "receipt#R1", "payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post('https://api.razorpay.com/v1/orders',
        headers: headers, body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    print('ORDER ID response => ${res.body}');

    return json.decode(res.body)['id'].toString();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String snackbarmMessage = '';

    try {
      List<Map> cartProducts = [];
      cartList.forEach((element) {
        cartProducts.add({
          'product': element.id,
          'name': element.name,
          'price': element.selling_price,
          'count': element.cartQuantity,
          'imgURL': element.image,
          'quantity': element.quantity
        });
      });
      var url = Uri.parse(
          'https://wild-grocery.herokuapp.com/api/order/create/${currentUser.id.toString()}');
      String encodedOrderData = json.encode({
        "order": {
          "products": cartProducts,
          "transaction_id": response.paymentId,
          "amount": total.toInt(),
          "address": {
            "address": addressController.text,
            "city": cityController.text,
            "zip": zipController.text
          },
          "user": currentUser.id.toString(),
          "orderType": "Pay Online",
          "deliveryType": deliverySelected,
          "expectedDelivery": date.toString(),
          "tax": (total * 0.02).round(),
          "deliveryCharge": deliverySelected == 'Normal' ? 0 : 40,
          "offerApplied": offerSelected.title,
          "offPrice": (total * offerSelected.discount['valued'] / 100),
          "scheduleTime": selectedSlot
        }
      });
      var apiResponse = await http.post(url,
          headers: {
            'Authorization': 'Bearer ${currentUser.token.toString()}',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: encodedOrderData);
      var data = json.decode(apiResponse.body);
      if (offerSelected.id != '') {
        refreshUserProfile(currentUser);
      }

      List<Cart> emptyCart = [];
      String encodedData = Cart.encode(emptyCart);
      preferences.setString('cart', encodedData);
      // Navigator.pop(context);
      Navigator.pop(context);
    } finally {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarmMessage ?? "Something went wrong"),
        ),
      );
    }
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('SUCCESS: + ${response.paymentId}')));
  }

  void openCheckout(amount, random) async {
    var oid = await generateOrderId(
        'rzp_test_uvifYhgFxSWOdD', '2KKWoxZC9X53SPPNxj4KhL1z', amount * 100);
    var options = await {
      'key': 'rzp_test_uvifYhgFxSWOdD',
      // 'amount': 3500,
      'amount': (amount * 100),
      'name': 'Wildberries India',
      'currency': 'INR',
      "order_id": oid,
      'description': 'Order ID: ${random.toString()}',
      'prefill': {'contact': currentUser.phone, 'email': currentUser.email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    preferences.setString('status', ' ');
    // Navigator.of(context).pop();
    // Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //         'ERROR: + ${response.code.toString()} +  -  + ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    String snackbarmMessage = '';

    try {
      List<Map> cartProducts = [];
      cartList.forEach((element) {
        cartProducts.add({
          'product': element.id,
          'name': element.name,
          'price': element.selling_price,
          'count': element.cartQuantity,
          'imgURL': element.image,
          'quantity': element.quantity
        });
      });
      var url = Uri.parse(
          'https://wild-grocery.herokuapp.com/api/order/create/${currentUser.id.toString()}');
      String encodedOrderData = json.encode({
        "order": {
          "products": cartProducts,
          "transaction_id": response.walletName,
          "amount": total.toInt(),
          "address": {
            "address": addressController.text,
            "city": cityController.text,
            "zip": zipController.text
          },
          "user": currentUser.id.toString(),
          "orderType": "COD",
          "deliveryType": deliverySelected,
          "expectedDelivery": date.toString(),
          "tax": (total * 0.2).round(),
          "deliveryCharge": deliverySelected == 'Normal' ? 40 : 0,
          "offPrice": 0
        }
      });
      var apiResponse = await http.post(url,
          headers: {
            'Authorization': 'Bearer ${currentUser.token.toString()}',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: encodedOrderData);
      var data = json.decode(apiResponse.body);
      if (data['status'] != null) {
        List<Cart> emptyCart = [];
        String encodedData = Cart.encode(emptyCart);
        preferences.setString('cart', encodedData);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } finally {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarmMessage ?? "Something went wrong"),
        ),
      );
    }
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('EXTERNAL_WALLET: + ${response.walletName}')));
  }

  List<UserDataAddress> addresses = [];
  getUserAdresses() async {
    Preference<String> addressesString =
        preferences.getString('addresses', defaultValue: '');
    await addressesString.listen((value) {
      if (value != '') {
        addresses = UserDataAddress.decode(value);
      }
    });
    print(addresses);
  }

  @override
  void initState() {
    preferences.setString('status', '').then((value) => print('Changed'));
    getUserAdresses();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    getUserAddresses();
    areas();
    selectedDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
    dateAddition = 1;

    totalList = cartList.map((e) => e.selling_price);
    total = totalList.isEmpty ? 0.0 : 0.0;
    // : (totalList.reduce((sum, element) =>
    //             double.parse(sum) + double.parse(element)) +
    //         deliveryCharge)
    //     .toStringAsFixed(2);
    date = DateTime.now();
    date2 = DateTime(date.year, date.month, date.day + dateAddition);
    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context, listen: false);
    addressFuture = getAddress(addressNotifier);
    OffersNotifier offersNotifier =
        Provider.of<OffersNotifier>(context, listen: false);
    getOffers(offersNotifier);
    date = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context, listen: false);
    cardFuture = getCard(cardNotifier);
    isDateSelected = false;
    super.initState();
  }

  _pickTime() async {
    var today = DateTime.now();
    DateTime t = await showDatePicker(
      context: context,
      initialDate: DateTime.now().hour < 12
          ? DateTime(today.year, today.month, today.day)
          : DateTime(today.year, today.month, today.day + dateAddition),
      lastDate: DateTime(today.year, today.month, today.day + 21),
      firstDate: DateTime.now().hour < 12
          ? DateTime(today.year, today.month, today.day)
          : DateTime(
              today.year, DateTime.now().month, today.day + dateAddition),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        date = t;
      });
    return date;
  }

  _pickTimeIncludeToday() async {
    var today = DateTime.now();
    DateTime t = await showDatePicker(
      context: context,
      initialDate:
          // DateTime.now().hour < 12
          //     ? DateTime(today.year, today.month, today.day) :
          DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year, today.month, today.day + 21),
      firstDate: DateTime(today.year, DateTime.now().month, today.day),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        date = t;
      });
    return date;
  }

  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }

  List<String> timeSlots = [];
  String timeSlot;

  Widget _buildTimeDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var hintTextStyle = textTheme.subtitle.copyWith(color: Colors.grey);
    var textFormFieldTextStyle =
        textTheme.subtitle.copyWith(color: Colors.grey);
    return Container(
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          0,
          36,
          0,
          0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        content: Container(
          height: 160,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Change delivery time',
                    style: textTheme.title.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                //TODO:Check
//                 child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('Timeslots')
//                         .snapshots(),
//                     builder: (BuildContext context,
//                         AsyncSnapshot<QuerySnapshot> snap) {
//                       if (snap.hasData && !snap.hasError && snap.data != null) {
//                         timeSlots.clear();
//                         for (int i = 0;
//                             i < snap.data.docs[0]['Timeslots'].length;
//                             i++) {
//                           DateTime dt = DateTime.now();
//
//                           if (dt.hour > 12) {
//                             String st = snap.data.docs[0]['Timeslots'][i];
//                             String s = '';
//                             for (int i = 0; i < st.length; i++) {
//                               if (st[i] != ' ')
//                                 s = s + st[i];
//                               else
//                                 break;
//                             }
//
//                             double d = double.parse(s);
//                             if (d > (dt.hour - 12) &&
//                                 snap.data.docs[0]['Timeslots'][i]
//                                     .contains('PM')) {
//                               timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                             }
//                           } else {
//                             String st = snap.data.docs[0]['Timeslots'][i];
//                             String s = '';
//                             for (int i = 0; i < st.length; i++) {
//                               if (st[i] != ' ')
//                                 s = s + st[i];
//                               else
//                                 break;
//                             }
//
//                             double d = double.parse(s);
//                             if (d > (dt.hour) &&
//                                 snap.data.docs[0]['Timeslots'][i]
//                                     .contains('AM')) {
//                               timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                             }
//                           }
//                         }
//                         if (timeSlots.length == 0) {
//                           selectedDate =
//                               selectedDate.add(new Duration(days: 1));
//                           for (int i = 0;
//                               i < snap.data.docs[0]['Timeslots'].length;
//                               i++) {
//                             timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                           }
//                         }
//
//                         if (selectedDate.difference(DateTime.now()).inDays >=
//                             1) {
//                           timeSlots.clear();
//                           for (int i = 0;
//                               i < snap.data.docs[0]['Timeslots'].length;
//                               i++) {
//                             timeSlots.add(snap.data.docs[0]['Timeslots'][i]);
//                           }
//                         }
//                         return timeSlots.length != 0
//                             ? Column(
//                                 children: [
//                                   Container(
//                                     width:
//                                         MediaQuery.of(context).size.width * 0.9,
//                                     child: DropdownButtonHideUnderline(
//                                       child:
//                                           new DropdownButtonFormField<String>(
//                                         validator: (value) => value == null
//                                             ? 'field required'
//                                             : null,
//                                         hint: Text('Time Slots'),
//                                         value: timeSlots[0],
//                                         items: timeSlots.map((String value) {
//                                           return new DropdownMenuItem<String>(
//                                             value: value,
//                                             child: new Text(value),
//                                           );
//                                         }).toList(),
//                                         onChanged: (String newValue) {
//                                           setState(() {
//                                             selectedTime = newValue;
//
// //                      Navigator.pop(context);
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : Container();
//                       } else {
//                         return Container();
//                       }
//                     }),
              ),
              Spacer(flex: 1),
              FlatButton(
                  child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            width: 1,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Change',
                            style: TextStyle(color: MColors.mainColor)),
                      ))),
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop(true);
                  })
            ],
          ),
        ),
      ),
    );
  }

  UserDataProfile currentUser;

  void areas() async {
    Preference<String> cUser =
        await preferences.getString('user', defaultValue: '');
    await cUser.listen((value) {
      // print('cUser');
      // print(value);
      if (value != '')
        currentUser = UserDataProfile.fromMap(json.decode(value));
      print(currentUser.token);
      print(currentUser.id);
    });
  }

  var totalList;
  var total;
  String deliverySelected = 'Normal';
  bool redeemWallet = false;
  Offer offerSelected =
      Offer('', '', false, '', '', '', '', {'valued': 0}, false, {}, 0);
  String status = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhiteSmoke,
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MColors.textGrey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          "Check out",
          style: boldFont(MColors.mainColor, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        null,
      ),
      body: primaryContainer(
        SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: PreferenceBuilder<String>(
                preference: preferences.getString(
                  'status',
                  defaultValue: '',
                ),
                builder: (BuildContext context, String counter) {
                  print(counter);

                  return counter == 'Loading'
                      ? Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: progressIndicator(MColors.primaryPurple)),
                        )
                      : Column(
                          children: <Widget>[
                            // Container(
                            //     child: Column(
                            //   children: [
                            //     Row(
                            //       children: [
                            //         Container(
                            //           child: SvgPicture.asset(
                            //             "assets/images/icons/Location.svg",
                            //             color: MColors.mainColor,
                            //           ),
                            //         ),
                            //         SizedBox(
                            //           width: 5.0,
                            //         ),
                            //         Expanded(
                            //           child: Container(
                            //             child: Text(
                            //               "Shipping address",
                            //               style: normalFont(MColors.textGrey, 20.0),
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ],
                            // )),

                            SizedBox(
                              height: 20.0,
                            ),

                            SizedBox(
                              height: 20.0,
                            ),
                            //Cart summary container
                            Container(
                              child: cartSummary(cartList),
                            ),

                            SizedBox(
                              height: 20.0,
                            ),

                            Container(child: shippingAddress()),
                            SizedBox(
                              height: 20.0,
                            ),
                            offersAvailable(),
                            SizedBox(
                              height: 20.0,
                            ),
                            deliveryOptions(),
                            SizedBox(
                              height: 20.0,
                            ),
                            deliverySelected == 'Normal'
                                ? dateSelected()
                                : Container(),
                            deliverySelected == 'Normal'
                                ? SizedBox(
                                    height: 20.0,
                                  )
                                : Container(),
                            deliverySelected == 'Normal'
                                ? slotSelected()
                                : Container(),
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(child: placeOrderButton(cartList))
                          ],
                        );
                })),
      ),
    );
  }

  Widget savedAddressWidget() {
    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context);
    var addressList = addressNotifier.userDataAddressList;
    var address = addressList.first;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Location.svg",
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Shipping address",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 60.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () async {
                    UserDataAddressNotifier addressNotifier =
                        Provider.of<UserDataAddressNotifier>(context,
                            listen: false);
                    // var navigationResult = await Navigator.of(context).push(
                    //   CupertinoPageRoute(
                    //     builder: (_) => AddressScreen(address, addressList),
                    //   ),
                    // );
                    // if (navigationResult == true) {
                    //   setState(() {
                    //     getAddress(addressNotifier);
                    //   });
                    //   showSimpleSnack(
                    //     "Address has been updated",
                    //     Icons.check_circle_outline,
                    //     Colors.green,
                    //     _scaffoldKey,
                    //   );
                    // }
                  },
                  child: Text(
                    "Change",
                    style: boldFont(MColors.mainColor, 14.0),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    address.address,
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Text(
                    address.address + ", " + address.city,
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noSavedAddress() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Location.svg",
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Container(
                  child: Text(
                    "Shipping address",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(
              left: 25.0,
            ),
            child: Text(
              "No shipping address added to this  account",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          primaryButtonWhiteSmoke(
            Text("Add a shipping address",
                style: boldFont(MColors.mainColor, 16.0)),
            () async {
              UserDataAddressNotifier addressNotifier =
                  Provider.of<UserDataAddressNotifier>(context, listen: false);
              var navigationResult = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => AddressScreen(null, null),
                ),
              );
              if (navigationResult == true) {
                setState(() {
                  getAddress(addressNotifier);
                });
                showSimpleSnack(
                  "Address has been updated",
                  Icons.check_circle_outline,
                  Colors.green,
                  _scaffoldKey,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget cartSummary(List<Cart> cartList) {
    var totalList = cartList.map((e) => e.selling_price * e.cartQuantity);
    var total = totalList.isEmpty
        ? 0.0
        : (totalList.reduce((sum, element) => sum + element) + deliveryCharge)
            .toStringAsFixed(2);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Bag.svg",
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Bag summary",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 50.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () {
                    _showModalSheet(cartList, total);
                  },
                  child: Text(
                    "See all",
                    style: boldFont(MColors.mainColor, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Container(
            // padding: EdgeInsets.only(left: 25.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: cartList.length < 7 ? cartList.length : 7,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                Cart cartItem = cartList[i];

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(cartItem.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: normalFont(MColors.textGrey, 12.0)),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 4.5,
                        child: Text(
                            "Rs. " +
                                (cartItem.selling_price * cartItem.cartQuantity)
                                    .toStringAsFixed(2),
                            maxLines: 1,
                            // overflow: TextOverflow.ellipsis,
                            style: boldFont(MColors.textDark, 12.0)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            // padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Text("Delivery Charge",
                    style: boldFont(MColors.mainColor, 14.0)),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 4.5,
                  child: Text("Rs. " + deliveryCharge.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldFont(MColors.mainColor, 14.0)),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          (offerSelected.id != '')
              ? Container(
                  // padding: EdgeInsets.only(left: 25),
                  child: Row(
                    children: <Widget>[
                      Text("Offer Applied",
                          style: boldFont(MColors.mainColor, 16.0)),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 4.5,
                        child: Text(offerSelected.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: boldFont(MColors.mainColor, 14.0)),
                      ),
                    ],
                  ),
                )
              : Container(),
          (offerSelected.id != '') ? SizedBox(height: 5.0) : Container(),
          (offerSelected.id != '')
              ? Container(
                  // padding: EdgeInsets.only(left: 25),
                  child: Row(
                    children: <Widget>[
                      Text("Discount Applied",
                          style: boldFont(MColors.mainColor, 16.0)),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 4.5,
                        child: Text(
                            // (
                            // (offerSelected.discount['valued'] * total) /
                            //     total *
                            //     100)
                            'Rs. ${(double.parse(total) * (offerSelected.discount["valued"]) / 100)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: boldFont(MColors.mainColor, 14.0)),
                      ),
                    ],
                  ),
                )
              : Container(),
          (offerSelected.id != '') ? SizedBox(height: 5.0) : Container(),
          Container(
            // padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Text("Total", style: boldFont(MColors.mainColor, 16.0)),
                Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width / 4.5,
                  child: Text(
                      "Rs. " +
                          (double.parse(total) -
                                  (double.parse(total) *
                                      (offerSelected.discount["valued"]) /
                                      100))
                              .toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldFont(MColors.mainColor, 14.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget placeOrderButton(List<Cart> cartList) {
    var totalList = cartList.map((e) => e.selling_price * e.cartQuantity);
    var total = totalList.isEmpty
        ? 0.0
        : (totalList.reduce((sum, element) => sum + element) + deliveryCharge)
            .toStringAsFixed(2);

    return Container(
      width: MediaQuery.of(context).size.width,
      // padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          primaryButtonPurple(
              Text(
                'Place Order',
                style: boldFont(Colors.white, 16),
              ), () async {
            await getDiscount();
            if (currentUser != null)
              _showConfirmModalSheet(
                  cartList, double.parse(total.toString()), offerSelected);
            else
              showSimpleSnack(
                "Login to place an order",
                Icons.warning_amber_outlined,
                Colors.amber,
                _scaffoldKey,
              );
          }),
        ],
      ),
    );
  }

  Widget savedPaymentMethod() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;
    var card = cardList.first;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Wallet.svg",
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Payment method",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 60.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () async {
                    UserDataCardNotifier cardNotifier =
                        Provider.of<UserDataCardNotifier>(context,
                            listen: false);

                    var navigationResult = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => AddNewCard(card, cardList),
                      ),
                    );
                    if (navigationResult == true) {
                      setState(() {
                        getCard(cardNotifier);
                      });
                      showSimpleSnack(
                        "Card has been updated",
                        Icons.check_circle_outline,
                        Colors.green,
                        _scaffoldKey,
                      );
                    }
                  },
                  child:
                      Text("Change", style: boldFont(MColors.mainColor, 14.0)),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    card.cardHolder,
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "•••• •••• •••• " +
                            card.cardNumber
                                .substring(card.cardNumber.length - 4),
                        style: normalFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    Spacer(),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/mastercard.svg",
                        height: 30.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noPaymentMethod() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Wallet.svg",
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Payment method",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "No payment card added to this account",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          primaryButtonWhiteSmoke(
            Text("Add a payment card",
                style: boldFont(MColors.mainColor, 16.0)),
            () async {
              var navigationResult = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => AddNewCard(null, cardList),
                ),
              );
              if (navigationResult == true) {
                setState(() {
                  getCard(cardNotifier);
                });
                showSimpleSnack(
                  "Card has been updated",
                  Icons.check_circle_outline,
                  Colors.green,
                  _scaffoldKey,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget dateSelected() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: <Widget>[
            Container(
              child: Icon(
                Icons.date_range_rounded,
                color: MColors.mainColor,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Container(
                child: Text(
                  "Delivery Date",
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: MColors.dashPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     Container(
                //       child: Icon(
                //         Icons.date_range_rounded,
                //         color: MColors.mainColor,
                //       ),
                //     ),
                //     SizedBox(
                //       width: 5.0,
                //     ),
                //     Expanded(
                //       child: Container(
                //         child: Text(
                //           "Delivery Date",
                //           style: normalFont(MColors.textGrey, 14.0),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 10.0),
                Container(
                  // padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Select a delivery date",
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                SizedBox(height: 10.0),
                primaryButtonWhiteSmoke(
                    Text(
                        '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}',
                        style: boldFont(MColors.mainColor, 16.0)),
                    _pickTime),
                SizedBox(height: 10.0),
                Text(
                  'You can cancel your order before 12:00 AM ${date.day.toString()}-${date.month.toString()}-${date.year.toString()}',
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String selectedSlot;
  List<String> slots = [];
  getSlots() async {
    var slotsUrl =
        Uri.parse('https://wild-grocery.herokuapp.com/api/gettimeslot');
    var walletResponse = await http.get(slotsUrl);
    var data = json.decode(walletResponse.body);
    // print(data[0]['slots']);
    List<String> slotList = List<String>.from(data[0]['slots']);

    slots = slotList;
    if (selectedSlot == null) {
      if (slots.length != 0)
        selectedSlot = slots[0];
      else
        selectedSlot = '';
    }

    setState(() {});
    // print(walletResponse.body);
  }

  Widget slotSelected() {
    getSlots();

    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return slots.length == 0
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: MColors.dashPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: ExpansionTile(
              title: Row(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.date_range_rounded,
                      color: MColors.mainColor,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        "Delivery Slot",
                        style: normalFont(MColors.textGrey, 14.0),
                      ),
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: MColors.dashPurple,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Row(
                      //   children: <Widget>[
                      //     Container(
                      //       child: Icon(
                      //         Icons.date_range_rounded,
                      //         color: MColors.mainColor,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 5.0,
                      //     ),
                      //     Expanded(
                      //       child: Container(
                      //         child: Text(
                      //           "Delivery Slot",
                      //           style: normalFont(MColors.textGrey, 14.0),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 10.0),
                      Container(
                        // padding: const EdgeInsets.only(left: 25.0),
                        child: Text(
                          "Select a delivery slot",
                          style: boldFont(MColors.textDark, 16.0),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: Expanded(
                          child: DropdownButtonHideUnderline(
                              child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              focusColor: MColors.textDark,
                              items: slots.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: boldFont(MColors.textDark, 16.0),
                                  ),
                                );
                              }).toList(),
                              value: selectedSlot,
                              onTap: () {},
                              onChanged: (val) {
                                selectedSlot = val;

                                setState(() {});
                              },
                              style: boldFont(MColors.textDark, 16.0),
                            ),
                          )),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'You can cancel your order before 12:00 AM ${date.day.toString()}-${date.month.toString()}-${date.year.toString()}',
                        style: normalFont(MColors.textGrey, 14.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  Widget noDateSelected() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.date_range_rounded,
                  color: MColors.mainColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Delivery Date",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Please select a date for delivery",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          Card(
            elevation: 5,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                  border: Border.all(color: MColors.mainColor),
                  borderRadius: BorderRadius.all(Radius.zero)),
              child: Row(
                children: [
                  Text('    Next Delivery: '),
                  Icon(
                    Icons.delivery_dining,
                    color: MColors.mainColor,
                  ),
                  SizedBox(width: 5),
                  InkWell(
                      onTap: () {
                        _pickTime().then((value) {
                          setState(() {
                            selectedDate = value;
                          });
                        });
                      },
                      child: selectedDate != null
                          ? Text(
                              '${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()} ',
                              style: TextStyle(color: Color(0xFF6b3600)),
                            )
                          : Text(
                              '${date.day.toString()}/${date.month.toString()}/${selectedDate.year.toString()} ',
                              style: TextStyle(color: Color(0xFF6b3600)),
                            )),
                  Text(' at '),
                  Icon(
                    Icons.timer,
                    size: 19,
                    color: MColors.mainColor,
                  ),
                  SizedBox(width: 5),
                  InkWell(
                      onTap: () {
                        _timeDialog(context);
                      },
                      child: Text(
                        '$selectedTime ',
                        style: TextStyle(color: Color(0xFF6b3600)),
                      )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                ],
              ),
            ),
          ),
//          primaryButtonWhiteSmoke(
//              Text("Delivery Date",
//                  style: boldFont(MColors.mainColor, 16.0)),
//              _pickTime),
          SizedBox(height: 10.0),
          Text(
            'Selected products can only be delivered after 15 days',
            style: boldFont(MColors.textDark, 12.0),
          ),
        ],
      ),
    );
  }

  UserDataAddress selectedAddress;

  Widget shippingAddress() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              child: SvgPicture.asset(
                "assets/images/icons/Location.svg",
                color: MColors.mainColor,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Container(
                child: Text(
                  "Shipping address",
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: MColors.dashPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Row(
                //   children: [
                //     Container(
                //       child: SvgPicture.asset(
                //         "assets/images/icons/Location.svg",
                //         color: MColors.mainColor,
                //       ),
                //     ),
                //     SizedBox(
                //       width: 5.0,
                //     ),
                //     Expanded(
                //       child: Container(
                //         child: Text(
                //           "Shipping address",
                //           style: normalFont(MColors.textGrey, 14.0),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 10.0),
                Container(
                  // padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Enter a new address",
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                SizedBox(height: 10.0),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value == '')
                            return 'Required field';
                          return null;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: MColors.mainColor)),
                          hintText: 'Full Address*',
                        ),
                        controller: addressController,
                        style: normalFont(MColors.mainColor, 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value == '')
                            return 'Required field';
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: MColors.mainColor)),
                            hintText: 'City*'),
                        style: normalFont(MColors.mainColor, 14),
                        controller: cityController,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value == '')
                            return 'Required field';
                          return null;
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(15.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: MColors.mainColor)),
                            hintText: 'Zip Code*'),
                        keyboardType: TextInputType.phone,
                        // maxLines: 2,
                        controller: zipController,
                        style: normalFont(MColors.mainColor, 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                    height:
                        // showOffers == true ?
                        240
                    // : 240.0
                    ,
                    child:
                        // showOffers == true
                        //     ?
                        ListView.builder(
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount: addresses.length,
                            itemBuilder: (context, i) {
                              return InkWell(
                                onTap: () {
                                  selectedAddress = addresses[i];
                                  addressController.text = addresses[i].address;
                                  cityController.text = addresses[i].city;
                                  zipController.text =
                                      addresses[i].zip.toString();

                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: selectedAddress == addresses[i]
                                          ? MColors.primaryWhite
                                          : Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Text(
                                                  addresses[i].address,
                                                  style: boldFont(
                                                      MColors.mainColor, 15),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                '${addresses[i].city}',
                                                style: normalFont(
                                                    MColors.mainColor, 15),
                                              ),
                                              Text(
                                                '${addresses[i].zip}',
                                                style: normalFont(
                                                    MColors.mainColor, 13),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                    // : InkWell(
                    //     onTap: () {
                    //       if (total <= offersListIUniv[0].discount['minOrder'])
                    //         setState(() {
                    //           offerSelected = offersListIUniv[0];
                    //         });
                    //       else
                    //         showSimpleSnack(
                    //             'The order total is less than the minimum order value',
                    //             Icons.warning_amber_outlined,
                    //             Colors.amber,
                    //             _scaffoldKey);
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(bottom: 10.0),
                    //       child: Container(
                    //         height: 230,
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.all(Radius.circular(10)),
                    //           color: offerSelected == offersListIUniv[0]
                    //               ? MColors.dashPurple
                    //               : Colors.transparent,
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Column(
                    //               children: [
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.symmetric(horizontal: 5),
                    //                   child: Text(
                    //                     offersListIUniv[0].title,
                    //                     style: boldFont(MColors.mainColor, 15),
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    //                   child: Text(
                    //                     'Minimum Order Value - Rs.${offersListIUniv[0].discount['minOrder']}',
                    //                     style: normalFont(MColors.mainColor, 13),
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   '${offersListIUniv[0].discount['valued']}% OFF',
                    //                   style: boldFont(MColors.mainColor, 15),
                    //                 ),
                    //               ],
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.all(5.0),
                    //               child: Container(
                    //                 width: 80,
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10.0),
                    //                   child: FadeInImage.assetNetwork(
                    //                     image:
                    //                         'https://wild-grocery.herokuapp.com/${offersListIUniv[0].banner}'
                    //                             .replaceAll('\\', '/'),
                    //                     fit: BoxFit.fill,
                    //                     height: 80                                                                                                                                                                                                                       ,
                    //                     width:
                    //                         MediaQuery.of(context).size.width - 80,
                    //                     placeholder:
                    //                         "assets/images/placeholder.jpg",
                    //                     placeholderScale:
                    //                         MediaQuery.of(context).size.height / 2,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    ),
                SizedBox(height: 10.0),
                //TODO: Saved Addresses Button
                // Container(
                //   width: MediaQuery.of(context).size.width - 40,
                //   child: primaryButtonPurple(
                //     Text(
                //       "View Saved Addresses",
                //       style: boldFont(MColors.primaryWhite, 14.0),
                //     ),
                //     () async {
                //       var navigationResult = await Navigator.of(context).push(
                //         CupertinoPageRoute(
                //           builder: (_) => MyAddresses(addresses),
                //         ),
                //       );
                //       if (navigationResult == true) {
                //         UserDataAddressNotifier addressNotifier =
                //             Provider.of<UserDataAddressNotifier>(context,
                //                 listen: false);
                //
                //         setState(() {
                //           getAddress(addressNotifier);
                //         });
                //         showSimpleSnack(
                //           "Address has been updated",
                //           Icons.check_circle_outline,
                //           Colors.green,
                //           _scaffoldKey,
                //         );
                //       }
                //     },
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool showOffers = false;
  Widget offersAvailable() {
    var totalList = cartList.map((e) => e.selling_price * e.cartQuantity);
    var total = totalList.isEmpty
        ? 0.0
        : (totalList.reduce((sum, element) => sum + element) + deliveryCharge);

    return Container(
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: <Widget>[
            Container(
              child: Icon(
                Icons.local_offer_outlined,
                color: MColors.mainColor,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Container(
              child: Text(
                "Offers Available",
                style: normalFont(MColors.textGrey, 14.0),
              ),
            ),
            Spacer(),
            // InkWell(
            //   onTap: () {
            //     if (showOffers == false)
            //       setState(() {
            //         showOffers = true;
            //       });
            //     else
            //       setState(() {
            //         showOffers = false;
            //       });
            //   },
            //   child: Container(
            //     child: Text(
            //       "See More",
            //       style: normalFont(MColors.textGrey, 14.0),
            //     ),
            //   ),
            // ),
          ],
        ),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: MColors.dashPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Container(
                //   width: MediaQuery.of(context).size.width - 50,
                //   child: Row(
                //     children: <Widget>[
                //       Container(
                //         child: Icon(
                //           Icons.local_offer_outlined,
                //           color: MColors.mainColor,
                //         ),
                //       ),
                //       SizedBox(
                //         width: 5.0,
                //       ),
                //       Container(
                //         child: Text(
                //           "Offers Available",
                //           style: normalFont(MColors.textGrey, 14.0),
                //         ),
                //       ),
                //       Spacer(),
                //       // InkWell(
                //       //   onTap: () {
                //       //     if (showOffers == false)
                //       //       setState(() {
                //       //         showOffers = true;
                //       //       });
                //       //     else
                //       //       setState(() {
                //       //         showOffers = false;
                //       //       });
                //       //   },
                //       //   child: Container(
                //       //     child: Text(
                //       //       "See More",
                //       //       style: normalFont(MColors.textGrey, 14.0),
                //       //     ),
                //       //   ),
                //       // ),
                //     ],
                //   ),
                // ),
                SizedBox(height: 10.0),
                Container(
                    height:
                        // showOffers == true ?
                        offersListIUniv.length * 80.0
                    // : 240.0
                    ,
                    child:
                        // showOffers == true
                        //     ?
                        ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: offersListIUniv.length,
                            itemBuilder: (context, i) {
                              return InkWell(
                                onTap: () {
                                  int count = 0;
                                  currentUser.copounsused.forEach((element) {
                                    if (element == offersListIUniv[i].title)
                                      count += 1;
                                  });
                                  if (count < offersListIUniv[i].perUserLimit) {
                                    if (total <=
                                        offersListIUniv[i].discount['minOrder'])
                                      showSimpleSnack(
                                          'The order total is less than the minimum order value',
                                          Icons.warning_amber_outlined,
                                          Colors.amber,
                                          _scaffoldKey);
                                    else if (offerSelected ==
                                        offersListIUniv[i])
                                      setState(() {
                                        offerSelected = Offer(
                                            '',
                                            '',
                                            false,
                                            '',
                                            '',
                                            '',
                                            '',
                                            {'valued': 0},
                                            false,
                                            {},
                                            0);
                                      });
                                    else
                                      setState(() {
                                        offerSelected = offersListIUniv[i];
                                      });
                                  } else
                                    showSimpleSnack(
                                        'You have crossed the maximum user limit for this order',
                                        Icons.warning_amber_outlined,
                                        Colors.amber,
                                        _scaffoldKey);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: offerSelected == offersListIUniv[i]
                                          ? MColors.primaryWhite
                                          : Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                offersListIUniv[i].title,
                                                style: boldFont(
                                                    MColors.mainColor, 15),
                                              ),
                                              Text(
                                                'Minimum Order Value - Rs.${offersListIUniv[i].discount['minOrder']}',
                                                style: normalFont(
                                                    MColors.mainColor, 13),
                                              ),
                                              Text(
                                                '${offersListIUniv[i].discount['valued']}% OFF',
                                                style: boldFont(
                                                    MColors.mainColor, 15),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Container(
                                            width: 80,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: FadeInImage.assetNetwork(
                                                image:
                                                    'https://wild-grocery.herokuapp.com/${offersListIUniv[i].banner}'
                                                        .replaceAll('\\', '/'),
                                                fit: BoxFit.fill,
                                                height: 80,
                                                width: 80,
                                                placeholder:
                                                    "assets/images/placeholder.jpg",
                                                placeholderScale:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                    // : InkWell(
                    //     onTap: () {
                    //       if (total <= offersListIUniv[0].discount['minOrder'])
                    //         setState(() {
                    //           offerSelected = offersListIUniv[0];
                    //         });
                    //       else
                    //         showSimpleSnack(
                    //             'The order total is less than the minimum order value',
                    //             Icons.warning_amber_outlined,
                    //             Colors.amber,
                    //             _scaffoldKey);
                    //     },
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(bottom: 10.0),
                    //       child: Container(
                    //         height: 230,
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.all(Radius.circular(10)),
                    //           color: offerSelected == offersListIUniv[0]
                    //               ? MColors.dashPurple
                    //               : Colors.transparent,
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Column(
                    //               children: [
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.symmetric(horizontal: 5),
                    //                   child: Text(
                    //                     offersListIUniv[0].title,
                    //                     style: boldFont(MColors.mainColor, 15),
                    //                   ),
                    //                 ),
                    //                 Padding(
                    //                   padding:
                    //                       const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    //                   child: Text(
                    //                     'Minimum Order Value - Rs.${offersListIUniv[0].discount['minOrder']}',
                    //                     style: normalFont(MColors.mainColor, 13),
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   '${offersListIUniv[0].discount['valued']}% OFF',
                    //                   style: boldFont(MColors.mainColor, 15),
                    //                 ),
                    //               ],
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.all(5.0),
                    //               child: Container(
                    //                 width: 80,
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10.0),
                    //                   child: FadeInImage.assetNetwork(
                    //                     image:
                    //                         'https://wild-grocery.herokuapp.com/${offersListIUniv[0].banner}'
                    //                             .replaceAll('\\', '/'),
                    //                     fit: BoxFit.fill,
                    //                     height: 80                                                                                                                                                                                                                       ,
                    //                     width:
                    //                         MediaQuery.of(context).size.width - 80,
                    //                     placeholder:
                    //                         "assets/images/placeholder.jpg",
                    //                     placeholderScale:
                    //                         MediaQuery.of(context).size.height / 2,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(TutorialOverlay());
  }

  Widget deliveryOptions() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      decoration: BoxDecoration(
        color: MColors.dashPurple,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: <Widget>[
            Container(
              child: Icon(
                Icons.list,
                color: MColors.mainColor,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Expanded(
              child: Container(
                child: Text(
                  "Delivery Options",
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ),
            ),
          ],
        ),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: MColors.dashPurple,
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     Container(
                //       child: Icon(
                //         Icons.list,
                //         color: MColors.mainColor,
                //       ),
                //     ),
                //     SizedBox(
                //       width: 5.0,
                //     ),
                //     Expanded(
                //       child: Container(
                //         child: Text(
                //           "Delivery Options",
                //           style: normalFont(MColors.textGrey, 14.0),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 10.0),
                Container(
                  // padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "Select a delivery type",
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: () {
                    setState(() {
                      deliverySelected = 'Normal';
                      deliveryCharge = 0;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                color: deliverySelected == 'Normal'
                                    ? MColors.mainColor
                                    : Colors.transparent,
                                border: Border.all(
                                    width: 2, color: MColors.mainColor)),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            "Normal delivery",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Free Delivery',
                            style: normalFont(MColors.textGrey, 14.0),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          child: Text(
                            'Your order will be delivered on the delivery date selected.',
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: normalFont(MColors.textGrey, 14.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: () {
                    setState(() {
                      deliverySelected = 'Express';
                      deliveryCharge = 40;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                                color: deliverySelected == 'Express'
                                    ? MColors.mainColor
                                    : Colors.transparent,
                                border: Border.all(
                                    width: 2, color: MColors.mainColor)),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            "Express delivery",
                            style: boldFont(MColors.textDark, 16.0),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Container(
                          child: Text(
                            'Delivery Charge - Rs. 40',
                            style: normalFont(MColors.textGrey, 14.0),
                          ),
                        ),
                      ),
                      DateTime.now().hour < 18
                          ? Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Container(
                                child: Text(
                                  'Your order will be delivered in 3 hours.\nYou can cancel your order within 5 minutes of placing the order.',
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  style: normalFont(MColors.textGrey, 14.0),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Container(
                                child: Text(
                                  'Your order will be delivered tomorrow.\nYou can cancel your order within 5 minutes of placing the order.',
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  style: normalFont(MColors.textGrey, 14.0),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          )
        ],
      ),
    );
  }

  //Bag summary
  void _showModalSheet(List<Cart> cartList, total) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.9,
          margin: EdgeInsets.only(
            bottom: 10.0,
            left: 10.0,
            right: 10.0,
            top: 5.0,
          ),
          padding: EdgeInsets.only(
            bottom: 15.0,
            left: 15.0,
            right: 15.0,
            top: 10.0,
          ),
          decoration: BoxDecoration(
            color: MColors.primaryWhiteSmoke,
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                modalBarWidget(),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Bag summary",
                        style: boldFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.mainColor,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Rs. " +
                          (double.parse(total) + deliveryCharge)
                              .toStringAsFixed(2),
                      style: boldFont(MColors.mainColor, 14.0),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Container(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      var cartItem = cartList[i];

                      return Container(
                        decoration: BoxDecoration(
                          color: MColors.primaryWhite,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.all(7.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30.0,
                              height: 40.0,
                              child: FadeInImage.assetNetwork(
                                image:
                                    'https://wild-grocery.herokuapp.com/${cartItem.image}',
                                fit: BoxFit.fill,
                                height: MediaQuery.of(context).size.height,
                                placeholder: "assets/images/placeholder.jpg",
                                placeholderScale:
                                    MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                cartItem.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: normalFont(MColors.textGrey, 12.0),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              "X${cartItem.cartQuantity}", // Container(
                              style: normalFont(MColors.textGrey,
                                  12.0), //   padding: const EdgeInsets.all(3.0),
                              textAlign: TextAlign
                                  .left, //   decoration: BoxDecoration(
                            ), //     color: MColors.dashPurple,
                            //     borderRadius: new BorderRadius.circular(10.0),
                            //   ),
                            //   child: Text(
                            //     "X${cartItem.cartQuantity}",
                            //     style: normalFont(MColors.textGrey, 12.0),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                            Spacer(),
                            Container(
                              child: Text(
                                "Rs. " +
                                    cartItem.selling_price.toStringAsFixed(2),
                                style: boldFont(MColors.textDark, 12.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("Delivery Charge",
                          style: boldFont(MColors.mainColor, 16.0)),
                      Spacer(),
                      Text("Rs. " + deliveryCharge.toString(),
                          style: boldFont(MColors.mainColor, 16.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String disc = '0';
  getDiscount() async {
    var url2 = Uri.parse(
        'https://wild-grocery.herokuapp.com/api/discountformem/61e965302b7bea464c4fc8f6');

    var apiResponse2 = await http.get(url2);
    var data2 = json.decode(apiResponse2.body);
    print(data2);
    disc = data2['percentOff'].toString();
  }

  void _showConfirmModalSheet(
      List<Cart> cartList, double total, Offer offerApplied) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setState /*You can rename this!*/) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            margin: EdgeInsets.only(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              top: 5.0,
            ),
            padding: EdgeInsets.only(
              bottom: 15.0,
              left: 15.0,
              right: 15.0,
              top: 10.0,
            ),
            decoration: BoxDecoration(
              color: MColors.primaryWhiteSmoke,
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            child: Column(
              children: <Widget>[
                modalBarWidget(),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Bag summary",
                        style: boldFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.mainColor,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 10.0),
                Container(
                  height: offerSelected.id != ''
                      ? MediaQuery.of(context).size.height * 0.8 - 365
                      : MediaQuery.of(context).size.height * 0.8 - 315,
                  child: ListView.builder(
                    itemCount: cartList.length,
                    // physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      var cartItem = cartList[i];

                      return Container(
                        decoration: BoxDecoration(
                          color: MColors.primaryWhite,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.all(7.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30.0,
                              height: 40.0,
                              child: FadeInImage.assetNetwork(
                                image:
                                    'https://wild-grocery.herokuapp.com/${cartItem.image}',
                                fit: BoxFit.fill,
                                height: MediaQuery.of(context).size.height,
                                placeholder: "assets/images/placeholder.jpg",
                                placeholderScale:
                                    MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                cartItem.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: normalFont(MColors.textGrey, 12.0),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              "X${cartItem.cartQuantity}",
                              style: normalFont(MColors.textGrey, 12.0),
                              textAlign: TextAlign.left,
                            ),
                            // Container(
                            //   padding: const EdgeInsets.all(3.0),
                            //   decoration: BoxDecoration(
                            //     color: MColors.dashPurple,
                            //     borderRadius: new BorderRadius.circular(10.0),
                            //   ),
                            //   child: Text(
                            //     "X${cartItem.cartQuantity}",
                            //     style: normalFont(MColors.textGrey, 12.0),
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                            Spacer(),
                            Container(
                              child: Text(
                                "Rs. " +
                                    cartItem.selling_price.toStringAsFixed(2),
                                style: boldFont(MColors.textDark, 12.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 5.0),
                Spacer(),
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("Cart Amount",
                          style: boldFont(MColors.mainColor, 16.0)),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                            (total -
                                        (total *
                                            (offerSelected.discount["valued"]) /
                                            100)) >
                                    0
                                ? "Rs. " +
                                    (double.parse(total.toString()) -
                                            deliveryCharge)
                                        .toStringAsFixed(2)
                                : "Rs. 0",
                            style: boldFont(MColors.mainColor, 16.0)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                (currentUser.subscription == 'member')
                    ? Container(
                        child: Row(
                          children: <Widget>[
                            Text("Delivery Charge",
                                style: boldFont(MColors.mainColor, 16.0)),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                  (total -
                                              (total *
                                                  (offerSelected
                                                      .discount["valued"]) /
                                                  100)) >
                                          0
                                      ? "Rs. " + deliveryCharge.toString()
                                      : "Rs. 0",
                                  style: boldFont(MColors.mainColor, 16.0)),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        child: Row(
                          children: <Widget>[
                            Text("Subscription Discount",
                                style: boldFont(MColors.mainColor, 16.0)),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                  (total -
                                              (total *
                                                  (offerSelected
                                                      .discount["valued"]) /
                                                  100)) >
                                          0
                                      ? "Rs. " +
                                          (((total - deliveryCharge) -
                                                      ((total -
                                                              deliveryCharge) *
                                                          (offerSelected
                                                                  .discount[
                                                              "valued"]) /
                                                          100)) *
                                                  int.parse(disc) /
                                                  100)
                                              .toStringAsFixed(1)
                                      : "Rs. 0",
                                  style: boldFont(MColors.mainColor, 16.0)),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: 5.0),
                (offerSelected.id != '')
                    ? Container(
                        // padding: EdgeInsets.only(left: 25),
                        child: Row(
                          children: <Widget>[
                            Text("Offer Applied",
                                style: boldFont(MColors.mainColor, 16.0)),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(offerSelected.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: boldFont(MColors.mainColor, 16.0)),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                (offerSelected.id != '') ? SizedBox(height: 5.0) : Container(),
                (offerSelected.id != '')
                    ? Container(
                        // padding: EdgeInsets.only(left: 25),
                        child: Row(
                          children: <Widget>[
                            Text("Discount Applied",
                                style: boldFont(MColors.mainColor, 16.0)),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text(
                                  // (
                                  // (offerSelected.discount['valued'] * total) /
                                  //     total *
                                  //     100)
                                  'Rs. ${(total * (offerSelected.discount["valued"]) / 100)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: boldFont(MColors.mainColor, 16.0)),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                (offerSelected.id != '') ? SizedBox(height: 5.0) : Container(),
                Container(
                  child: Row(
                    children: <Widget>[
                      Text("Total Amount",
                          style: boldFont(MColors.mainColor, 16.0)),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                            (total -
                                        (total *
                                            (offerSelected.discount["valued"]) /
                                            100) -
                                        (((total - deliveryCharge) -
                                                ((total - deliveryCharge) *
                                                    (offerSelected
                                                        .discount["valued"]) /
                                                    100)) *
                                            int.parse(disc) /
                                            100)) >
                                    0
                                ? currentUser.subscription == 'member'
                                    ? "Rs. " +
                                        (total -
                                                (total *
                                                    (offerSelected
                                                        .discount["valued"]) /
                                                    100))
                                            .toStringAsFixed(1)
                                    : "Rs. " +
                                        (total -
                                                (total *
                                                    (offerSelected
                                                        .discount["valued"]) /
                                                    100) -
                                                (((total - deliveryCharge) -
                                                        ((total -
                                                                deliveryCharge) *
                                                            (offerSelected
                                                                    .discount[
                                                                "valued"]) /
                                                            100)) *
                                                    int.parse(disc) /
                                                    100) -
                                                deliveryCharge)
                                            .toStringAsFixed(1)
                                : "Rs. 0",
                            style: boldFont(MColors.mainColor, 16.0)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                currentUser.coins != 0
                    ? Container(
                        child: Row(
                          children: <Widget>[
                            Text("Wallet Balance",
                                style: boldFont(MColors.mainColor, 16.0)),
                            Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Text("Rs. " + currentUser.coins.toString(),
                                  style: boldFont(MColors.mainColor, 16.0)),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                SizedBox(height: 5.0),
                currentUser.coins != 0
                    ? InkWell(
                        onTap: () {
                          if (redeemWallet == false)
                            setState(() {
                              redeemWallet = true;
                              total -= currentUser.coins;
                            });
                          else
                            setState(() {
                              redeemWallet = false;
                              total += currentUser.coins;
                            });
                        },
                        child: Container(
                          child: Row(
                            children: [
                              // Container(
                              //   height: 15,
                              //   width: 15,
                              //   decoration: BoxDecoration(
                              //       color: redeemWallet == true
                              //           ? MColors.mainColor
                              //           : Colors.transparent,
                              //       border: Border.all(
                              //           width: 2, color: MColors.mainColor)),
                              // ),
                              // SizedBox(
                              //   width: 5.0,
                              // ),
                              Text(
                                redeemWallet != true
                                    ? "Redeem Wallet Balance"
                                    : "Keep Wallet Balance",
                                style: normalFont(MColors.textDark, 16.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 5.0),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 28,
                        child: primaryButtonPurple(
                          Text(
                            "Cash On Delivery",
                            style: boldFont(MColors.primaryWhite, 14.0),
                          ),
                          () async {
                            List<Map> cartProducts = [];
                            cartList.forEach((element) {
                              cartProducts.add({
                                'product': element.id,
                                'name': element.name,
                                'price': element.selling_price,
                                'count': element.cartQuantity,
                                'imgURL': element.image,
                                'quantity': element.quantity
                              });
                            });
                            if (redeemWallet == true) {
                              var walletUrl = Uri.parse(
                                  'https://wild-grocery.herokuapp.com/api/subs/create');
                              var walletResponse = await http.post(walletUrl,
                                  // headers: {
                                  //   'Authorization':
                                  //   'Bearer ${currentUser.token.toString()}',
                                  //   'Accept': 'application/json',
                                  //   'Content-Type': 'application/json'
                                  // },
                                  body: {
                                    "title": "walletdel",
                                    "userId": currentUser.id,
                                    "transactionId": "check",
                                    "orderId": currentUser.id,
                                    "amount": (total -
                                                (total *
                                                    (offerSelected
                                                        .discount["valued"]) /
                                                    100)) <
                                            currentUser.coins
                                        ? (total -
                                                (total *
                                                    (offerSelected
                                                        .discount["valued"]) /
                                                    100))
                                            .toString()
                                        : currentUser.coins.toString()
                                  });
                              refreshUserProfile(currentUser);
                            }
                            var url = Uri.parse(
                                'https://wild-grocery.herokuapp.com/api/order/create/${currentUser.id.toString()}');
                            String encodedOrderData = json.encode({
                              "order": {
                                "status": "Not processed",
                                "products": cartProducts,
                                "transaction_id": "ABC789",
                                "amount": total.toInt(),
                                "offerApplied": offerSelected.title,
                                "address": {
                                  "address": addressController.text,
                                  "city": cityController.text,
                                  "zip": zipController.text
                                },
                                "user": currentUser.id.toString(),
                                "orderType": "Cash On Delivery",
                                "deliveryType": deliverySelected,
                                "expectedDelivery": date.toString(),
                                "tax": (total * 0.02).round(),
                                "deliveryCharge":
                                    deliverySelected == 'Normal' ? 0 : 40,
                                "offPrice": (total *
                                    offerSelected.discount['valued'] /
                                    100),
                                "scheduleTime": selectedSlot
                              }
                            });

                            var response = await http.post(url,
                                headers: {
                                  'Authorization':
                                      'Bearer ${currentUser.token.toString()}',
                                  'Accept': 'application/json',
                                  'Content-Type': 'application/json'
                                },
                                body: encodedOrderData);

                            if (offerSelected.id != '') {
                              refreshUserProfile(currentUser);
                            }
                            var data = json.decode(response.body);

                            List<Cart> emptyCart = [];
                            String encodedData = Cart.encode(emptyCart);
                            preferences.setString('cart', encodedData);
                            Navigator.pop(context);
                            _showOverlay(context);

                            // Navigator.pop(context);
                          },
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 28,
                        child: primaryButtonPurple(
                          Text(
                            "Pay Online",
                            style: boldFont(MColors.primaryWhite, 14.0),
                          ),
                          () async {
                            Navigator.pop(context);
                            preferences.setString('status', 'Loading');
                            status = 'Checkout';
                            _scaffoldKey.currentState.setState(() {});
                            openCheckout(total, random);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: 10.0),
                // Container(
                //   width: MediaQuery.of(context).size.width - 40,
                //   child: primaryButtonPurple(
                //     Text(
                //       "Pay Online At Delivery",
                //       style: boldFont(MColors.primaryWhite, 14.0),
                //     ),
                //     () async {
                //       List<Map> cartProducts = [];
                //       cartList.forEach((element) {
                //         cartProducts.add({
                //           'product': element.id,
                //           'name': element.name,
                //           'price': element.selling_price,
                //           'count': element.cartQuantity,
                //           'imgURL': element.image,
                //           'quantity': element.quantity
                //         });
                //       });
                //       var url = Uri.parse(
                //           'https://wild-grocery.herokuapp.com/api/order/create/${currentUser.id.toString()}');
                //       String encodedOrderData = json.encode({
                //         "order": {
                //           "products": cartProducts,
                //           "transaction_id": "ABC789",
                //           "amount": total.toInt(),
                //           "address": {
                //             "address": addressController.text,
                //             "city": cityController.text,
                //             "zip": zipController.text
                //           },
                //           "user": currentUser.id.toString(),
                //           "orderType": "COD",
                //           "deliveryType": deliverySelected,
                //           "expectedDelivery": date.toString(),
                //           "tax": (total * 0.2).round(),
                //           "deliveryCharge":
                //               deliverySelected == 'Normal' ? 40 : 0,
                //           "offerApplied": offerSelected.title,
                //           "offPrice":
                //               (total * offerSelected.discount['valued'] / 100)
                //         }
                //       });
                //       var response = await http.post(url,
                //           headers: {
                //             'Authorization':
                //                 'Bearer ${currentUser.token.toString()}',
                //             'Accept': 'application/json',
                //             'Content-Type': 'application/json'
                //           },
                //           body: encodedOrderData);
                //       var data = json.decode(response.body);
                //       if (offerSelected.id != '') {
                //         refreshUserProfile(currentUser);
                //       }
                //       List<Cart> emptyCart = [];
                //       String encodedData = Cart.encode(emptyCart);
                //       preferences.setString('cart', encodedData);
                //       Navigator.pop(context);
                //       Navigator.pop(context);
                //     },
                //   ),
                // ),
              ],
            ),
          );
        });
      },
    );
  }

  Future _showLoadingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return;
          },
          child: AlertDialog(
            backgroundColor: MColors.primaryWhiteSmoke,
            title: Text(
              "Please wait..",
              style: boldFont(MColors.mainColor, 14.0),
            ),
            content: Container(
              height: 20.0,
              child: Row(
                children: <Widget>[
                  Text(
                    " We are placing your order.",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                  Spacer(),
                  progressIndicator(MColors.mainColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
