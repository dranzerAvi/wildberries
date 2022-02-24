import 'dart:convert';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/widgets/allWidgets.dart';

import '../../main.dart';

class SubscriptionsScreen extends StatefulWidget {
  SubscriptionsScreen();
  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  var id;
  String phone, message;
  List<Widget> addressCards = [];
  String subscriptionFetchapi =
      'https://wild-grocery.herokuapp.com/api/subscription/list';
  List subscriptions = [];
  UserDataProfile currentUser;
  bool isPurchased = false;

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

  Razorpay _razorpay;
  @override
  void initState() {
    preferences.setString('status', '').then((value) => print('Changed'));

    setState(() {});

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    areas();

    fetchSubscriptions();
    super.initState();
  }

  void fetchSubscriptions() async {
    var result = await http.get(subscriptionFetchapi);
    Map data = json.decode(result.body);
    subscriptions = await data['data'];
    print(subscriptions);
    setState(() {});
  }

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  Map selectedSubscription = {};
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
      var url = Uri.parse('https://wild-grocery.herokuapp.com/api/subs/create');
      String encodedOrderData = json.encode({
        "title": selectedSubscription['title'],
        "userId": currentUser.id,
        "transactionId": response.paymentId,
        "amount": selectedSubscription['sellingAmount'],
        "duration": selectedSubscription['validationMonth']
      });
      var apiResponse = await http.post(url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: encodedOrderData);
      var data = json.decode(apiResponse.body);
      var url2 = Uri.parse(
          'https://wild-grocery.herokuapp.com/api/discountformem/61e965302b7bea464c4fc8f6');

      var apiResponse2 = await http.get(url2);
      var data2 = json.decode(apiResponse2.body);
      print(data2);
      refreshUserProfile(currentUser,
          subscriptionID: selectedSubscription['_id'],
          subscriptionDiscount: data2['percentOff'].toString());
      snackbarmMessage = 'Subscription Purchased';
      isPurchased = true;
      preferences.setString('status', '');
      setState(() {});
      // Navigator.pop(context);
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
    Navigator.of(context).pop();
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
            'ERROR: + ${response.code.toString()} +  -  + ${response.message}')));
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    String snackbarmMessage = '';

    try {
      var url = Uri.parse('https://wild-grocery.herokuapp.com/api/subs/create');
      String encodedOrderData = json.encode({
        "title": selectedSubscription['title'],
        "userId": currentUser.id,
        "transactionId": response.walletName,
        "amount": selectedSubscription['sellingAmount'],
        "duration": selectedSubscription['validationMonth']
      });
      var apiResponse = await http.post(url,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: encodedOrderData);
      var data = json.decode(apiResponse.body);
      var url2 = Uri.parse(
          'https://wild-grocery.herokuapp.com/api/discountformem/${selectedSubscription['_id']}');

      var apiResponse2 = await http.get(url2);
      var data2 = json.decode(apiResponse2.body);

      refreshUserProfile(currentUser,
          subscriptionID: selectedSubscription['_id'],
          subscriptionDiscount: data2['percentOff']);
      snackbarmMessage = 'Subscription Purchased';
      // Navigator.pop(context);

      isPurchased = true;
      preferences.setString('status', '');
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(
            size: 20,
            color: MColors.secondaryColor,
          ),
          backgroundColor: MColors.mainColor,
          actions: [
            InkWell(
                onTap: () {
                  launch('tel:+919027553376');
                },
                child: Icon(
                  Icons.phone,
                )),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
                  launchWhatsApp(
                      phone: '7060222315',
                      message: 'Check out this awesome app');
                },
                child: Container(
                    alignment: Alignment.center,
                    child: FaIcon(FontAwesomeIcons.whatsapp))),
            SizedBox(
              width: 8,
            ),
            InkWell(
                onTap: () {
//                print(1);
                  launch(
                      'mailto:work.axactstudios@gmail.com?subject=Complaint/Feedback&body=Type your views here.');
                },
                child: Icon(
                  Icons.mail,
                )),
            SizedBox(
              width: 14,
            )
          ],
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Wildberries',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
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
                      : isPurchased == true
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.8,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'You are now a PRIME MEMBER',
                                      style: boldFont(MColors.textDark, 18.0),
                                    ),
                                    Image.asset('assets/images/wb.png'),
                                  ],
                                ),
                              ),
                            )
                          : currentUser == null
                              ? Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: progressIndicator(Colors.grey),
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        'Wildberries Subscription Plan',
                                        style: boldFont(MColors.mainColor, 20),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Center(
                                        child: Text(
                                          'Wildberries provide subscription plans for extra benefits. Start your membership now and gain access to exciting offers and fee and charges reductions.',
                                          style: boldFont(MColors.textGrey, 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        color: MColors.dashPurple,
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            currentUser.subscription == 'member'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      'Available Plans',
                                                      style: boldFont(
                                                          Colors.black, 18),
                                                      // textAlign: TextAlign.center,
                                                    ),
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      'Current Plan Details',
                                                      style: boldFont(
                                                          Colors.black, 18),
                                                      // textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                            currentUser.subscription == 'member'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        subscriptions.length !=
                                                                0
                                                            ? ListView.builder(
                                                                itemCount:
                                                                    subscriptions
                                                                        .length,
                                                                shrinkWrap:
                                                                    true,
                                                                physics:
                                                                    ClampingScrollPhysics(),
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  Map item =
                                                                      subscriptions[
                                                                          index];
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      selectedSubscription =
                                                                          subscriptions[
                                                                              index];

                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    child: Card(
                                                                        color: selectedSubscription == subscriptions[index]
                                                                            ? MColors
                                                                                .dashPurple
                                                                            : Colors
                                                                                .white,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Align(
                                                                                alignment: Alignment.bottomLeft,
                                                                                child: Text(
                                                                                  'Subscription Name : ${item['title']}',
                                                                                  style: normalFont(MColors.mainColor, 16),
                                                                                ),
                                                                              ),
                                                                              Align(
                                                                                  alignment: Alignment.bottomLeft,
                                                                                  child: Text(
                                                                                    'Subscription Price : Rs. ${item['actualAmount']}',
                                                                                    style: normalFont(MColors.mainColor, 16),
                                                                                  )),
                                                                              Align(
                                                                                  alignment: Alignment.bottomLeft,
                                                                                  child: Text(
                                                                                    'Current Offer Price : Rs. ${item['sellingAmount']}',
                                                                                    style: normalFont(MColors.mainColor, 16),
                                                                                  )),
                                                                              Align(
                                                                                  alignment: Alignment.bottomLeft,
                                                                                  child: Text(
                                                                                    'Validity : ${item['validationMonth']} Months',
                                                                                    style: normalFont(MColors.mainColor, 16),
                                                                                  )),
                                                                            ],
                                                                          ),
                                                                        )),
                                                                  );
                                                                },
                                                              )
                                                            : Container(
                                                                height: 300,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                child: Center(
                                                                    child: progressIndicator(
                                                                        MColors
                                                                            .primaryPurple)),
                                                              ),
                                                  )
                                                : Container(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 20),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Activated Plan :',
                                                                style: boldFont(
                                                                    MColors
                                                                        .mainColor,
                                                                    16),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                'PRIME MEMBERSHIP',
                                                                style: boldFont(
                                                                    MColors
                                                                        .textGrey,
                                                                    16),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Current Discount :',
                                                                style: boldFont(
                                                                    MColors
                                                                        .mainColor,
                                                                    16),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                '${currentUser.subscriptionDiscount}% OFF',
                                                                style: boldFont(
                                                                    MColors
                                                                        .textGrey,
                                                                    16),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Valid From :',
                                                                style: boldFont(
                                                                    MColors
                                                                        .mainColor,
                                                                    16),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                currentUser
                                                                    .subscriptionTime
                                                                    .substring(
                                                                        0, 15),
                                                                style: boldFont(
                                                                    MColors
                                                                        .textGrey,
                                                                    16),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Validity :',
                                                                style: boldFont(
                                                                    MColors
                                                                        .mainColor,
                                                                    16),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                '1 Month',
                                                                style: boldFont(
                                                                    MColors
                                                                        .textGrey,
                                                                    16),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                            //

                                            currentUser.subscription == 'member'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: primaryButtonPurple(
                                                      Text(
                                                        'Buy Subscription',
                                                        style: boldFont(
                                                            Colors.white, 16),
                                                      ),
                                                      () async {
                                                        if (selectedSubscription[
                                                                'actualAmount'] ==
                                                            null)
                                                          showSimpleSnack(
                                                            "Please select a subscription first",
                                                            Icons
                                                                .warning_amber_outlined,
                                                            Colors.amber,
                                                            _scaffoldKey,
                                                          );
                                                        else {
                                                          preferences.setString(
                                                              'status',
                                                              'Loading');

                                                          openCheckout(
                                                              selectedSubscription[
                                                                      'sellingAmount'] *
                                                                  1.0,
                                                              random);
                                                        }
                                                      },
                                                    ))
                                                : Container(),
                                            currentUser.subscription == 'member'
                                                ? Container()
                                                : Image.asset(
                                                    'assets/images/wb.png'),
                                            SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                })));
  }
}
