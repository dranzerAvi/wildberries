import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/offer.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/offers_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/model/services/offers_service.dart';
import 'package:wildberries/screens/tab_screens/checkout_screens/completeOrder.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

class Bag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartNotifier>(
      create: (BuildContext context) => CartNotifier(),
      child:
          // Container()
          BagScreen(),
    );
  }
}

class BagScreen extends StatefulWidget {
  @override
  _BagScreenState createState() => _BagScreenState();
}

class _BagScreenState extends State<BagScreen> {
  Future bagFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?   phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  // Preference<List<Cart>> cartItemsStream;

  @override
  void initState() {
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);
    bagFuture = getCart(cartNotifier);
    print(bagFuture);
    // getCart(cartNotifier);
    // getPreferences();
    super.initState();
  }

  bool refresh = false;
  @override
  Widget build(BuildContext context) {
    // CartNotifier cartNotifier = Provider.of<CartNotifier>(context);
    // var cartList = cartNotifier.cartList;
    // var totalList = cartList.map((e) => e.selling_price);
    // print(totalList.reduce((sum, element) => sum + element).toStringAsFixed(2));
    // var total = totalList.isEmpty
    //     ? 0.0
    //     : totalList.reduce((sum, element) => sum + element).toStringAsFixed(2);
    // if (refresh == true) {
    //   getCart(cartNotifier);
    //   refresh = false;
    //   setState(() {});
    // }
    // getCart(cartNotifier);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return Future.value(true);
      },
      child: Scaffold(
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
          body: PreferenceBuilder<String>(
              preference: preferences.getString(
                'cart',
                defaultValue: '',
              ),
              builder: (BuildContext context, String counter) {
                print(counter);
                var cartTotal = 0;

                List<Cart> cartList = [];
                if (counter != '') cartList = Cart.decode(counter);
                cartList.forEach((element) {
                  cartTotal = cartTotal +
                      (element.cartQuantity * element.selling_price);
                });
                if (cartList.length == 0) cartTotal = 0;

                return cartList.length == 0
                    ? emptyScreen(
                        "assets/images/emptyCart.svg",
                        "Bag is empty",
                        "Products you add to your bag will show up here. So lets get shopping and make your pet happy.",
                      )
                    : Column(
                        children: [
                          SizedBox(height: 10.0),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Cart Items",
                                    style: boldFont(MColors.textGrey, 22.0),
                                  ),
                                  Text(
                                    "Rs. $cartTotal",
                                    style: normalFont(MColors.textGrey, 19.0),
                                  ),
                                  // Column(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   crossAxisAlignment: CrossAxisAlignment.end,
                                  //   children: <Widget>[
                                  //
                                  //
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Expanded(
                            child: Container(
                              child: ListView.builder(
                                  itemCount: cartList.length,
                                  itemBuilder: (context, i) {
                                    Cart cartItem = cartList[i];
                                    return Dismissible(
                                      key: UniqueKey(),
                                      confirmDismiss: (direction) =>
                                          promptUser(cartItem, cartList),
                                      onDismissed: (direction) async {
                                        // await getCart(cartNotifier);

                                        // cartList.remove(cartItem);
                                        // await getCart(cartNotifier);
                                        // cartList = await cartNotifier.cartList;
                                        await setState(() {});

                                        showSimpleSnack(
                                          "Product removed from bag",
                                          Icons.error_outline,
                                          Colors.amber,
                                          _scaffoldKey,
                                        );
                                      },
                                      background: backgroundDismiss(
                                          AlignmentDirectional.centerStart),
                                      secondaryBackground: backgroundDismiss(
                                          AlignmentDirectional.centerEnd),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          height: 160.0,
                                          child: Container(
                                            padding: const EdgeInsets.all(15.0),
                                            decoration: BoxDecoration(
                                              color: MColors.primaryWhite,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                Container(
                                                  width: 100.0,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      image:
                                                          'https://wild-grocery.herokuapp.com/${cartItem.image}',
                                                      fit: BoxFit.fill,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
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
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.2,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text(
                                                          cartItem.name,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: normalFont(
                                                              MColors.textDark,
                                                              16.0),
                                                          textAlign:
                                                              TextAlign.left,
                                                          softWrap: true,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "Rs. ${cartItem.selling_price}",
                                                              style: boldFont(
                                                                  MColors
                                                                      .mainColor,
                                                                  19.0),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(3.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: MColors
                                                                    .dashPurple,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              child: Text(
                                                                " ${cartItem.productQuantity} ",
                                                                style: normalFont(
                                                                    MColors
                                                                        .textGrey,
                                                                    13.0),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .info_outline,
                                                              color: Colors
                                                                  .redAccent,
                                                              size: 14.0,
                                                            ),
                                                            SizedBox(
                                                              width: 2.0,
                                                            ),
                                                            Container(
                                                              child: Text(
                                                                "Swipe to remove",
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: normalFont(
                                                                    Colors
                                                                        .redAccent,
                                                                    10.0),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Spacer(),
                                                Builder(
                                                  builder: (context) {
                                                    CartNotifier cartNotifier =
                                                        Provider.of<
                                                                CartNotifier>(
                                                            context,
                                                            listen: false);

                                                    return Container(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  new BorderRadius
                                                                          .circular(
                                                                      10.0),
                                                              color: MColors
                                                                  .dashPurple,
                                                            ),
                                                            height: 34.0,
                                                            width: 34.0,
                                                            child:
                                                                RawMaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                addAndUpdateData(
                                                                    cartItem,
                                                                    _scaffoldKey,
                                                                    cartList);
                                                              },
                                                              child: Icon(
                                                                Icons.add,
                                                                color: MColors
                                                                    .mainColor,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Center(
                                                              child: Text(
                                                                cartItem
                                                                    .cartQuantity
                                                                    .toString(),
                                                                style: normalFont(
                                                                    MColors
                                                                        .textDark,
                                                                    18.0),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  new BorderRadius
                                                                          .circular(
                                                                      10.0),
                                                              color: MColors
                                                                  .primaryWhiteSmoke,
                                                            ),
                                                            width: 34.0,
                                                            height: 34.0,
                                                            child:
                                                                RawMaterialButton(
                                                              onPressed:
                                                                  () async {
                                                                if (cartItem
                                                                        .cartQuantity ==
                                                                    1)
                                                                  await removeItemFromCart(
                                                                      cartItem,
                                                                      _scaffoldKey);
                                                                else
                                                                  await subAndUpdateData(
                                                                      cartItem,
                                                                      _scaffoldKey,
                                                                      cartList);
                                                              },
                                                              child: Icon(
                                                                Icons.remove,
                                                                color: MColors
                                                                    .mainColor
                                                                    .withOpacity(
                                                                        0.5),
                                                                size: 30.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    // return InkWell(
                                    //   child: Text(cartList[i].name),
                                    //   onTap: () async {
                                    //     await cartList.remove(cartList[i]);
                                    //     final String encodedData = Cart.encode(cartList);
                                    //     await preferences.setString('cart', encodedData);
                                    //   },
                                    // );
                                  }),
                            ),
                          ),
                          Container(
                            color: MColors.primaryWhite,
                            padding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                            child: primaryButtonPurple(
                              Text("Proceed to Checkout",
                                  style: boldFont(MColors.primaryWhite, 16.0)),
                              () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        AddressScreen(cartList, ''),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
              })
          // FutureBuilder(
          //   future: bagFuture,
          //   builder: (c, s) {
          //     // print(s.connectionState);
          //     // print(s.data);
          //     // print(cartList);
          //     switch (s.connectionState) {
          //       case ConnectionState.active:
          //         return progressIndicator(MColors.secondaryColor);
          //         break;
          //       case ConnectionState.done:
          //         return cartList.isEmpty || cartList == null
          //             ? emptyScreen(
          //                 "assets/images/emptyCart.svg",
          //                 "Bag is empty",
          //                 "Products you add to your bag will show up here. So lets get shopping and make your pet happy.",
          //               )
          //             : bag(total);
          //         break;
          //       case ConnectionState.waiting:
          //         return progressIndicator(MColors.secondaryColor);
          //         break;
          //       default:
          //         return progressIndicator(MColors.secondaryColor);
          //     }
          //   },
          // ),
          //  , bottomNavigationBar:
          ),
    );
  }

  // Widget bag(total) {
  //   CartNotifier cartNotifier =
  //       Provider.of<CartNotifier>(context, listen: false);
  //   List cartList = cartNotifier.cartList;
  //   return Scaffold(
  //     key: _scaffoldKey,
  //     body: RefreshIndicator(
  //       onRefresh: () => getCart(cartNotifier),
  //       child: primaryContainer(
  //         Column(
  //           children: <Widget>[
  //             SizedBox(height: 10.0),
  //             Container(
  //               width: MediaQuery.of(context).size.width,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     "Cart Items",
  //                     style: boldFont(MColors.textGrey, 22.0),
  //                   ),
  //                   Text(
  //                     "Rs. $total",
  //                     style: normalFont(MColors.textGrey, 19.0),
  //                   ),
  //                   // Column(
  //                   //   mainAxisAlignment: MainAxisAlignment.end,
  //                   //   crossAxisAlignment: CrossAxisAlignment.end,
  //                   //   children: <Widget>[
  //                   //
  //                   //
  //                   //   ],
  //                   // ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 10.0),
  //             Expanded(
  //               child: Container(
  //                 height: MediaQuery.of(context).size.height,
  //                 child: ListView.builder(
  //                   physics: BouncingScrollPhysics(),
  //                   shrinkWrap: true,
  //                   itemCount: cartList.length,
  //                   itemBuilder: (context, i) {
  //                     var cartItem = cartList[i];
  //
  //                     return Dismissible(
  //                       key: UniqueKey(),
  //                       confirmDismiss: (direction) =>
  //                           promptUser(cartItem, cartList),
  //                       onDismissed: (direction) async {
  //                         await getCart(cartNotifier);
  //
  //                         cartList.remove(cartItem);
  //                         await getCart(cartNotifier);
  //                         cartList = await cartNotifier.cartList;
  //                         await setState(() {});
  //
  //                         showSimpleSnack(
  //                           "Product removed from bag",
  //                           Icons.error_outline,
  //                           Colors.amber,
  //                           _scaffoldKey,
  //                         );
  //                       },
  //                       background:
  //                           backgroundDismiss(AlignmentDirectional.centerStart),
  //                       secondaryBackground:
  //                           backgroundDismiss(AlignmentDirectional.centerEnd),
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           borderRadius: BorderRadius.all(
  //                             Radius.circular(10.0),
  //                           ),
  //                         ),
  //                         margin: const EdgeInsets.symmetric(vertical: 5.0),
  //                         height: 160.0,
  //                         child: Container(
  //                           padding: const EdgeInsets.all(15.0),
  //                           decoration: BoxDecoration(
  //                             color: MColors.primaryWhite,
  //                             borderRadius: BorderRadius.all(
  //                               Radius.circular(10.0),
  //                             ),
  //                           ),
  //                           child: Row(
  //                             crossAxisAlignment: CrossAxisAlignment.stretch,
  //                             children: <Widget>[
  //                               Container(
  //                                 width: 80.0,
  //                                 child: FadeInImage.assetNetwork(
  //                                   image:
  //                                       'https://wild-grocery.herokuapp.com/${cartItem.image}',
  //                                   fit: BoxFit.fill,
  //                                   height: MediaQuery.of(context).size.height,
  //                                   placeholder:
  //                                       "assets/images/placeholder.jpg",
  //                                   placeholderScale:
  //                                       MediaQuery.of(context).size.height / 2,
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 width: 5.0,
  //                               ),
  //                               Container(
  //                                 width:
  //                                     MediaQuery.of(context).size.width / 2.2,
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: <Widget>[
  //                                     Container(
  //                                       child: Text(
  //                                         cartItem.name,
  //                                         maxLines: 2,
  //                                         overflow: TextOverflow.ellipsis,
  //                                         style: normalFont(
  //                                             MColors.textDark, 16.0),
  //                                         textAlign: TextAlign.left,
  //                                         softWrap: true,
  //                                       ),
  //                                     ),
  //                                     SizedBox(
  //                                       height: 5.0,
  //                                     ),
  //                                     Container(
  //                                       child: Row(
  //                                         children: <Widget>[
  //                                           Text(
  //                                             "Rs. ${cartItem.selling_price}",
  //                                             style: boldFont(
  //                                                 MColors.mainColor, 22.0),
  //                                             textAlign: TextAlign.left,
  //                                           ),
  //                                           SizedBox(
  //                                             width: 10.0,
  //                                           ),
  //                                           Container(
  //                                             padding: EdgeInsets.all(3.0),
  //                                             decoration: BoxDecoration(
  //                                               color: MColors.dashPurple,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(10.0),
  //                                             ),
  //                                             child: Text(
  //                                               " ${cartItem.productQuantity} ",
  //                                               style: normalFont(
  //                                                   MColors.textGrey, 14.0),
  //                                               textAlign: TextAlign.left,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     Spacer(),
  //                                     Container(
  //                                       child: Row(
  //                                         children: <Widget>[
  //                                           Icon(
  //                                             Icons.info_outline,
  //                                             color: Colors.redAccent,
  //                                             size: 14.0,
  //                                           ),
  //                                           SizedBox(
  //                                             width: 2.0,
  //                                           ),
  //                                           Container(
  //                                             child: Text(
  //                                               "Swipe to remove",
  //                                               maxLines: 3,
  //                                               overflow: TextOverflow.ellipsis,
  //                                               style: normalFont(
  //                                                   Colors.redAccent, 10.0),
  //                                               textAlign: TextAlign.left,
  //                                               softWrap: true,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               Spacer(),
  //                               Builder(
  //                                 builder: (context) {
  //                                   CartNotifier cartNotifier =
  //                                       Provider.of<CartNotifier>(context,
  //                                           listen: false);
  //
  //                                   return Container(
  //                                     child: Column(
  //                                       mainAxisAlignment:
  //                                           MainAxisAlignment.center,
  //                                       children: <Widget>[
  //                                         Container(
  //                                           decoration: BoxDecoration(
  //                                             borderRadius:
  //                                                 new BorderRadius.circular(
  //                                                     10.0),
  //                                             color: MColors.dashPurple,
  //                                           ),
  //                                           height: 34.0,
  //                                           width: 34.0,
  //                                           child: RawMaterialButton(
  //                                             onPressed: () async {
  //                                               await getCart(cartNotifier);
  //                                               await addAndApdateData(
  //                                                   cartItem, _scaffoldKey);
  //                                               await getCart(cartNotifier);
  //                                               setState(() {});
  //                                             },
  //                                             child: Icon(
  //                                               Icons.add,
  //                                               color: MColors.mainColor,
  //                                               size: 24.0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           padding: const EdgeInsets.all(5.0),
  //                                           child: Center(
  //                                             child: Text(
  //                                               cartItem.cartQuantity
  //                                                   .toString(),
  //                                               style: normalFont(
  //                                                   MColors.textDark, 18.0),
  //                                             ),
  //                                           ),
  //                                         ),
  //                                         Container(
  //                                           decoration: BoxDecoration(
  //                                             borderRadius:
  //                                                 new BorderRadius.circular(
  //                                                     10.0),
  //                                             color: MColors.primaryWhiteSmoke,
  //                                           ),
  //                                           width: 34.0,
  //                                           height: 34.0,
  //                                           child: RawMaterialButton(
  //                                             onPressed: () async {
  //                                               await getCart(cartNotifier);
  //
  //                                               await subAndApdateData(
  //                                                   cartItem, _scaffoldKey);
  //                                               await getCart(cartNotifier);
  //                                               setState(() {});
  //                                             },
  //                                             child: Icon(
  //                                               Icons.remove,
  //                                               color: MColors.mainColor
  //                                                   .withOpacity(0.5),
  //                                               size: 30.0,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     bottomNavigationBar: Container(
  //       color: MColors.primaryWhite,
  //       padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
  //       child: primaryButtonPurple(
  //         Text("Proceed to checkout",
  //             style: boldFont(MColors.primaryWhite, 16.0)),
  //         () {
  //           Navigator.of(context).push(
  //             CupertinoPageRoute(
  //               builder: (context) => AddressScreen(cartList, ''),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  //Remove from cart
  Future<bool> promptUser(Cart cartItem, List cartList) async {
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);

    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            content: Text("Are you sure you want to remove?"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                  getCart(cartNotifier);
                },
              ),
              CupertinoDialogAction(
                child: Text("Yes"),
                textStyle: normalFont(Colors.red, null),
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  removeItemFromCart(cartItem, _scaffoldKey);
                  await getCart(cartNotifier);
                  // _scaffoldKey.currentState.setState(() {
                  //   cartList = cartNotifier.cartList;
                  // });
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
