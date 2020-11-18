import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrpet/model/notifiers/orders_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/internetConnectivity.dart';

import 'package:mrpet/widgets/allWidgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({Key key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  Future ordersFuture;
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _tabItems = [
    Text(
      "Current orders",
      style: TextStyle(
          color: MColors.secondaryColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold),
    ),
    Text(
      "Past orders",
      style: TextStyle(
          color: MColors.secondaryColor,
          fontSize: 15,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold),
    ),
  ];

  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  OrderListNotifier orderListNotifier =
                      Provider.of<OrderListNotifier>(context, listen: false);
                  ordersFuture = getOrders(orderListNotifier);
                }()
              : showNoInternetSnack(_scaffoldKey)
        });

    _tabController = TabController(
      length: _tabItems.length,
      vsync: this,
    );
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

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    OrderListNotifier orderListNotifier =
        Provider.of<OrderListNotifier>(context);
    var orderList = orderListNotifier.orderListList;

    return Scaffold(
      body: FutureBuilder(
        future: ordersFuture,
        builder: (c, s) {
          switch (s.connectionState) {
            case ConnectionState.active:
              return _firebaseAuth.currentUser != null
                  ? progressIndicator(MColors.primaryPurple)
                  : emptyScreen(
                      "assets/images/noHistory.svg",
                      "No Orders",
                      "Your past orders, transactions and hires will show up here.",
                    );
              break;
            case ConnectionState.done:
              return orderList.isEmpty
                  ? emptyScreen(
                      "assets/images/noHistory.svg",
                      "No Orders",
                      "Your past orders, transactions and hires will show up here.",
                    )
                  : ordersScreen(orderList);
              break;
            case ConnectionState.waiting:
              return _firebaseAuth.currentUser != null
                  ? progressIndicator(MColors.primaryPurple)
                  : emptyScreen(
                      "assets/images/noHistory.svg",
                      "No Orders",
                      "Your past orders, transactions and hires will show up here.",
                    );
              break;
            default:
              return _firebaseAuth.currentUser != null
                  ? progressIndicator(MColors.primaryPurple)
                  : emptyScreen(
                      "assets/images/noHistory.svg",
                      "No Orders",
                      "Your past orders, transactions and hires will show up here.",
                    );
          }
        },
      ),
    );
  }

  Widget ordersScreen(orderList) {
    final _tabBody = [
      currentOrder(orderList),
      pastOrder(),
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          bottom: TabBar(
            physics: BouncingScrollPhysics(),
            tabs: _tabItems,
            controller: _tabController,
          ),
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
        body: TabBarView(
          children: _tabBody,
        ),
      ),
    );
  }

  Widget currentOrder(orderList) {
    OrderListNotifier orderListNotifier =
        Provider.of<OrderListNotifier>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: () => getOrders(orderListNotifier),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: orderList.length,
          itemBuilder: (context, i) {
            OrderListNotifier orderListNotifier =
                Provider.of<OrderListNotifier>(context);
            var _orderList = orderListNotifier.orderListList;

            var orderListItem = _orderList[i];
            var orderID = orderListItem.orderID.substring(
              orderListItem.orderID.length - 11,
            );

            var order = _orderList[i].order.toList();
            var orderTotalPriceList = order.map((e) => e['totalPrice']);
            var orderTotalPrice = orderTotalPriceList
                .reduce((sum, element) => sum + element)
                .toStringAsFixed(2);
            var orderDayTime = orderListItem.orderDate.toDate().day.toString() +
                "-" +
                orderListItem.orderDate.toDate().month.toString() +
                "-" +
                orderListItem.orderDate.toDate().year.toString();

            return Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.only(bottom: 10.0),
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
                      Expanded(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Order No. ",
                                style: normalFont(MColors.textGrey, 14.0),
                              ),
                              Text(
                                orderID,
                                style: boldFont(MColors.textGrey, 14.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          orderDayTime,
                          style: normalFont(MColors.textGrey, 14.0),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    height: 70.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: order.length,
                      itemBuilder: (context, i) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          height: 50.0,
                          width: 40.0,
                          child: FadeInImage.assetNetwork(
                            image: order[i]['productImage'],
                            fit: BoxFit.fill,
                            placeholder: "assets/images/placeholder.jpg",
                            placeholderScale:
                                MediaQuery.of(context).size.height / 2,
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          order.length.toString() + " Items",
                          style: normalFont(MColors.textGrey, 14.0),
                        ),
                        Spacer(),
                        Text(
                          "\$" + orderTotalPrice.toString(),
                          style: boldFont(MColors.textGrey, 14.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 60.0,
                          height: 25.0,
                          child: RawMaterialButton(
                            onPressed: () {
                              _showModalSheet(orderListItem);
                            },
                            child: Text(
                              "Details",
                              style: boldFont(MColors.primaryPurple, 14.0),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          orderListItem.orderStatus,
                          style: boldFont(Colors.green, 14.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget pastOrder() {
    return emptyScreen(
      "assets/images/noHistory.svg",
      "No past orders",
      "Orders that have been delivered to you or cancelled will show up here.",
    );
  }

  //Order details
  void _showModalSheet(orderListItem) {
    var orderID = orderListItem.orderID.substring(
      orderListItem.orderID.length - 11,
    );
    var order = orderListItem.order.toList();
    var orderTotalPriceList = order.map((e) => e['totalPrice']);
    var orderTotalPrice = orderTotalPriceList
        .reduce((sum, element) => sum + element)
        .toStringAsFixed(2);

    var orderDayTime = orderListItem.orderDate.toDate().day.toString() +
        "-" +
        orderListItem.orderDate.toDate().month.toString() +
        "-" +
        orderListItem.orderDate.toDate().year.toString();

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
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Order details",
                        style: boldFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.primaryPurple,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "\$" + orderTotalPrice,
                      style: boldFont(MColors.primaryPurple, 16.0),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Order No. ",
                              style: normalFont(MColors.textGrey, 14.0),
                            ),
                            Text(
                              orderID,
                              style: boldFont(MColors.textGrey, 14.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        orderDayTime,
                        style: normalFont(MColors.textGrey, 14.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                orderTrackerWidget(orderListItem.orderStatus),
                SizedBox(height: 15.0),
                Text(
                  "Delivering to",
                  style: boldFont(MColors.textGrey, 14.0),
                ),
                SizedBox(height: 5.0),
                Text(
                  orderListItem.shippingAddress,
                  style: normalFont(MColors.textGrey, 14.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.0),
                Container(
                  child: ListView.builder(
                    itemCount: order.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
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
                                image: order[i]['productImage'],
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
                                order[i]['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: normalFont(MColors.textGrey, 14.0),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: MColors.dashPurple,
                                borderRadius: new BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                "X" + order[i]['quantity'].toString(),
                                style: normalFont(MColors.textGrey, 14.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Spacer(),
                            Container(
                              child: Text(
                                "\$" +
                                    order[i]['totalPrice'].toStringAsFixed(2),
                                style: boldFont(MColors.textDark, 14.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
