import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrpet/model/notifiers/wishlist_notifier.dart';

import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WishlistScr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WishlistNotifier>(
      create: (BuildContext context) => WishlistNotifier(),
      child: WishlistScreen(),
    );
  }
}

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future bagFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WishlistNotifier wishlistNotifier =
        Provider.of<WishlistNotifier>(context, listen: false);
    bagFuture = getWishlist(wishlistNotifier);
    getWishlist(wishlistNotifier);

    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    WishlistNotifier wishlistNotifier = Provider.of<WishlistNotifier>(context);
    var wishlistList = wishlistNotifier.wishlistList;
    var totalList = wishlistList.map((e) => e.totalPrice);
    var total = totalList.isEmpty
        ? 0.0
        : totalList.reduce((sum, element) => sum + element).toStringAsFixed(2);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return Future.value(true);
      },
      child: Scaffold(
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
            'Misterpet.ae',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        body: FutureBuilder(
          future: bagFuture,
          builder: (c, s) {
            switch (s.connectionState) {
              case ConnectionState.active:
                return progressIndicator(MColors.primaryPurple);
                break;
              case ConnectionState.done:
                return wishlistList.isEmpty
                    ? emptyScreen(
                        "assets/images/emptyCart.svg",
                        "Wishlist is empty",
                        "Products you add to your wishlist will show up here. So lets get shopping and make your pet happy.",
                      )
                    : bag(wishlistList, total);
                break;
              case ConnectionState.waiting:
                return progressIndicator(MColors.primaryPurple);
                break;
              default:
                return progressIndicator(MColors.primaryPurple);
            }
          },
        ),
      ),
    );
  }

  Widget bag(wishlistList, total) {
    WishlistNotifier wishlistNotifier =
        Provider.of<WishlistNotifier>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: () => getWishlist(wishlistNotifier),
        child: primaryContainer(
          Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: wishlistList.length,
                    itemBuilder: (context, i) {
                      var wishlistItem = wishlistList[i];

                      return Dismissible(
                        key: UniqueKey(),
                        confirmDismiss: (direction) => promptUser(wishlistItem),
                        onDismissed: (direction) {
                          wishlistList.remove(UniqueKey());
                          showSimpleSnack(
                            "Product removed from bag",
                            Icons.error_outline,
                            Colors.amber,
                            _scaffoldKey,
                          );
                        },
                        background:
                            backgroundDismiss(AlignmentDirectional.centerStart),
                        secondaryBackground:
                            backgroundDismiss(AlignmentDirectional.centerEnd),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  width: 80.0,
                                  child: FadeInImage.assetNetwork(
                                    image: wishlistItem.productImage,
                                    fit: BoxFit.fill,
                                    height: MediaQuery.of(context).size.height,
                                    placeholder:
                                        "assets/images/placeholder.jpg",
                                    placeholderScale:
                                        MediaQuery.of(context).size.height / 2,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          wishlistItem.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: normalFont(
                                              MColors.textDark, 16.0),
                                          textAlign: TextAlign.left,
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
                                              "\$${wishlistItem.price}",
                                              style: boldFont(
                                                  MColors.primaryPurple, 22.0),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(
                                                color: MColors.dashPurple,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Text(
                                                "${wishlistItem.quantity}X",
                                                style: normalFont(
                                                    MColors.textGrey, 14.0),
                                                textAlign: TextAlign.left,
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
                                              Icons.info_outline,
                                              color: Colors.redAccent,
                                              size: 14.0,
                                            ),
                                            SizedBox(
                                              width: 2.0,
                                            ),
                                            Container(
                                              child: Text(
                                                "Swipe to remove",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: normalFont(
                                                    Colors.redAccent, 10.0),
                                                textAlign: TextAlign.left,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Remove from cart
  Future<bool> promptUser(wishlistItem) async {
    WishlistNotifier wishlistNotifier =
        Provider.of<WishlistNotifier>(context, listen: false);

    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            content: Text("Are you sure you want to remove?"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                  getWishlist(wishlistNotifier);
                },
              ),
              CupertinoDialogAction(
                child: Text("Yes"),
                textStyle: normalFont(Colors.red, null),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  removeItemFromWishlist(wishlistItem);
                  getWishlist(wishlistNotifier);
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
