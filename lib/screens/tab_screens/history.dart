import 'dart:convert';
import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wildberries/model/data/orders.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/orders_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/internetConnectivity.dart';
import 'package:http/http.dart' as http;

import 'package:wildberries/widgets/allWidgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryScreen extends StatefulWidget {
  UserDataProfile currentUser;
  HistoryScreen(this.currentUser, {Key key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  Future ordersFuture;
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _tabItems = [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child:
          Text("Current orders", style: boldFont(MColors.secondaryColor, 15)),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text("Past orders", style: boldFont(MColors.secondaryColor, 15)),
    ),
  ];
  List<Order> orderList = [];
  @override
  void initState() {
    checkInternetConnectivity().then((value) => {
          value == true
              ? () {
                  OrderListNotifier orderListNotifier =
                      Provider.of<OrderListNotifier>(context, listen: false);
                  ordersFuture =
                      getOrders(orderListNotifier, widget.currentUser);
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

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
              return progressIndicator(MColors.primaryPurple);

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
              return progressIndicator(MColors.primaryPurple);

              break;
            default:
              return progressIndicator(MColors.primaryPurple);
          }
        },
      ),
    );
  }

  Widget ordersScreen(List<Order> orderList) {
    final _tabBody = [
      currentOrder(
          orderList.where((element) => element.status != 'Delivered').toList()),
      pastOrder(
          orderList.where((element) => element.status == 'Delivered').toList()),
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
            'Wildberries',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _tabBody,
        ),
      ),
    );
  }

  Widget currentOrder(List<Order> orderList) {
    DateTime currentDate = new DateTime.now();
    OrderListNotifier orderListNotifier =
        Provider.of<OrderListNotifier>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: () => getOrders(orderListNotifier, widget.currentUser),
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: orderListNotifier.orderListList
              .where((element) => element.status != 'Delivered')
              .toList()
              .length,
          itemBuilder: (context, i) {
            OrderListNotifier orderListNotifier =
                Provider.of<OrderListNotifier>(context);
            List<Order> _orderList = orderListNotifier.orderListList
                .where((element) => element.status != 'Delivered')
                .toList();

            Order orderListItem = _orderList[i];
            var orderID = orderListItem.id;

            var order = _orderList[i].products.toList();
            var orderTotalPriceList = order.map((e) => e['price']).toList();
            var orderTotalPrice = orderListItem.amount;
            print(orderTotalPriceList);
            print(order);

            // orderTotalPriceList
            //     .reduce((sum, element) => sum + element)
            //     .toStringAsFixed(2);
            //TODO:Check
            // var orderDayTime = orderListItem.orderDate.toDate().day.toString() +
            //     "-" +
            //     orderListItem.orderDate.toDate().month.toString() +
            //     "-" +
            //     orderListItem.orderDate.toDate().year.toString();

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
                      // Container(
                      //   width: 60.0,
                      //   height: 25.0,
                      //   child: RawMaterialButton(
                      //     onPressed: () {
                      //       // print(orderListItem);
                      //       _showCancelModalSheet(orderListItem);
                      //     },
                      //     child: Text(
                      //       "Cancel",
                      //       style: boldFont(MColors.mainColor, 14.0),
                      //     ),
                      //   ),
                      // ),
                      orderListItem.deliveryType == 'Normal'
                          ? currentDate
                                      .difference(DateTime.parse(
                                          orderListItem.createdAt))
                                      .inDays ==
                                  0
                              ? Container(
                                  child: InkWell(
                                    onTap: () {
                                      _showCancelOrderModalSheet(orderListItem);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: boldFont(Colors.red, 14),
                                    ),
                                  ),
                                  //TODO:Check
                                  // child: Text(
                                  //   orderDayTime,
                                  //   style: normalFont(MColors.textGrey, 14.0),
                                  // ),
                                )
                              : Container()
                          : currentDate
                                      .difference(DateTime.parse(
                                          orderListItem.createdAt))
                                      .inMinutes <=
                                  5
                              ? Container(
                                  child: Text(
                                    'Cancel',
                                    style: boldFont(Colors.red, 14),
                                  ),
                                  //TODO:Check
                                  // child: Text(
                                  //   orderDayTime,
                                  //   style: normalFont(MColors.textGrey, 14.0),
                                  // ),
                                )
                              : Container(),
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
                            image:
                                'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
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
                          "Rs." + orderTotalPrice.toString(),
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
                              print(orderListItem);
                              _showModalSheet(orderListItem);
                            },
                            child: Text(
                              "Details",
                              style: boldFont(MColors.mainColor, 14.0),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          orderListItem.status.toString(),
                          style: boldFont(Colors.green, 14.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  InkWell(
                    onTap: () {
                      _raiseIssueModalSheet(orderListItem);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color: MColors.mainColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Raise an issue',
                          style: boldFont(Colors.white, 14),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget pastOrder(List<Order> orderList) {
    OrderListNotifier orderListNotifier =
        Provider.of<OrderListNotifier>(context, listen: false);
    print('Past orders');

    print(orderListNotifier.orderListList
        .where((element) => element.status != 'Delivered')
        .toList());
    return Container(
      height: MediaQuery.of(context).size.height,
      child: RefreshIndicator(
        onRefresh: () => getOrders(orderListNotifier, widget.currentUser),
        child: orderListNotifier.orderListList
                    .where((element) => element.status == 'Delivered')
                    .toList()
                    .length ==
                0
            ? emptyScreen(
                "assets/images/noHistory.svg",
                "No Orders",
                "Your past orders will show up here.",
              )
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderListNotifier.orderListList
                    .where((element) => element.status == 'Delivered')
                    .toList()
                    .length,
                itemBuilder: (context, i) {
                  OrderListNotifier orderListNotifier =
                      Provider.of<OrderListNotifier>(context);
                  List<Order> _orderList = orderListNotifier.orderListList
                      .where((element) => element.status == 'Delivered')
                      .toList();

                  Order orderListItem = _orderList[i];
                  var orderID = orderListItem.id;

                  var order = _orderList[i].products.toList();
                  var orderTotalPriceList =
                      order.map((e) => e['selling_price']);
                  var orderTotalPrice = orderListItem.amount;
                  // orderTotalPriceList
                  //     .reduce((sum, element) => sum + element)
                  //     .toStringAsFixed(2);
                  //TODO:Check
                  // var orderDayTime = orderListItem.orderDate.toDate().day.toString() +
                  //     "-" +
                  //     orderListItem.orderDate.toDate().month.toString() +
                  //     "-" +
                  //     orderListItem.orderDate.toDate().year.toString();

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
                                //TODO:Check
                                // child: Text(
                                //   orderDayTime,
                                //   style: normalFont(MColors.textGrey, 14.0),
                                // ),
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
                                  image:
                                      'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
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
                                "Rs." + orderTotalPrice.toString(),
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
                                    print(orderListItem);
                                    _showModalSheet(orderListItem);
                                  },
                                  child: Text(
                                    "Details",
                                    style: boldFont(MColors.mainColor, 14.0),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                orderListItem.status,
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

  TextEditingController reasonController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  void _showCancelOrderModalSheet(Order orderListItem) {
    var orderID = orderListItem.id;
    var userId = orderListItem.user;
    var order = orderListItem.products.toList();

    var orderDayTime = DateTime.parse(orderListItem.createdAt).day.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).month.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).year.toString();

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
                        "Request Order Cancellation",
                        style: boldFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Spacer(),
                    Text(
                      "Rs.${orderListItem.amount}",
                      // + orderTotalPrice,
                      style: boldFont(MColors.textGrey, 16.0),
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
                Row(
                  children: [
                    Text(
                      "Delivering to",
                      style: boldFont(MColors.textGrey, 14.0),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Row(
                  children: [
                    Text(
                      orderListItem.address['address'],
                      style: normalFont(MColors.textGrey, 14.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  validator: (value) {
                    if (value == null || value == '') return 'Required field';
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
                    hintText: 'Reason For Cancellation*',
                  ),
                  controller: reasonController,
                  style: normalFont(MColors.mainColor, 14),
                ),
                SizedBox(height: 15.0),
                primaryButtonPurple(
                    Text(
                      'Request Cancellation',
                      style: boldFont(Colors.white, 14),
                    ), () async {
                  var url = Uri.parse(
                      'https://wild-grocery.herokuapp.com/api/create/cancellation');
                  String encodedOrderData = json.encode({
                    "name":
                        '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                    "email": '${widget.currentUser.email}',
                    "phone": widget.currentUser.phone.toString().substring(2),
                    "issues": reasonController.text,
                    "user": widget.currentUser.id.toString(),
                    "orderId": orderID
                  });
                  var response = await http.post(url, body: {
                    "name":
                        '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                    "email": '${widget.currentUser.email}',
                    "phone": widget.currentUser.phone.toString().substring(2),
                    "issues": reasonController.text,
                    "user": widget.currentUser.id.toString(),
                    "orderId": orderID
                  });
                  var data = json.decode(response.body);
                  print(data);
                  Navigator.pop(context);
                }),
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
                                image:
                                    'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
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
                                "Rs.0",
                                // order[i]['selling_price']
                                //     .toStringAsFixed(2),
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

  File _image;
  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _raiseIssueModalSheet(Order orderListItem) {
    var orderID = orderListItem.id;
    var userId = orderListItem.user;
    var order = orderListItem.products.toList();

    var orderDayTime = DateTime.parse(orderListItem.createdAt).day.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).month.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).year.toString();

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return StatefulBuilder(builder: (BuildContext context,
            StateSetter setModalState /*You can rename this!*/) {
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
                          "Raise An Issue",
                          style: boldFont(MColors.textGrey, 16.0),
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Spacer(),
                      Text(
                        "Rs.${orderListItem.amount}",
                        // + orderTotalPrice,
                        style: boldFont(MColors.textGrey, 16.0),
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
                  Row(
                    children: [
                      Text(
                        "Delivering to",
                        style: boldFont(MColors.textGrey, 14.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      Text(
                        orderListItem.address['address'],
                        style: normalFont(MColors.textGrey, 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: MColors.mainColor,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: _image == null
                        ? FlatButton(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 50,
                            ),
                            onPressed: () async {
                              await _getImage();
                              setModalState;
                            },
                            color: MColors.mainColor,
                          )
                        : InkWell(
                            onTap: () async {
                              await _getImage();
                              setModalState;
                            },
                            child: Image.file(_image)),
                    margin: EdgeInsets.only(top: 20.0),
                  ),
                  SizedBox(height: 15.0),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value == '') return 'Required field';
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
                      hintText: 'Explain Your Query*',
                    ),
                    controller: queryController,
                    style: normalFont(MColors.mainColor, 14),
                  ),
                  SizedBox(height: 15.0),
                  primaryButtonPurple(
                      Text(
                        'Raise Query',
                        style: boldFont(Colors.white, 14),
                      ), () async {
                    if (_image == null) {
                      var url = Uri.parse(
                          'https://wild-grocery.herokuapp.com/api/create/withoutimg-report');
                      // String encodedOrderData = json.encode({
                      //   "name":
                      //       '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                      //   "email": '${widget.currentUser.email}',
                      //   "phone":
                      //       widget.currentUser.phone.toString().substring(2),
                      //   "issues": queryController.text,
                      //   "user": widget.currentUser.id.toString(),
                      //   "orderId": orderID
                      // });
                      var response = await http.post(url, body: {
                        "name":
                            '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                        "email": '${widget.currentUser.email}',
                        "phone":
                            widget.currentUser.phone.toString().substring(2),
                        "issues": queryController.text,
                        "user": widget.currentUser.id.toString(),
                        "orderId": orderID
                      });
                      var data = json.decode(response.body);
                      print(data);
                      Navigator.pop(context);
                    } else {
                      Dio dio = new Dio();
                      String fileName = await _image.path.split('/').last;
                      var formData = FormData.fromMap({
                        "banner": MultipartFile.fromFile(_image.path,
                            filename: fileName),
                        "name":
                            '${widget.currentUser.firstName} ${widget.currentUser.lastName}',
                        "email": '${widget.currentUser.email}',
                        "phone":
                            widget.currentUser.phone.toString().substring(2),
                        "issues": queryController.text,
                        "user": widget.currentUser.id.toString(),
                        "orderId": orderID
                      });
                      // print('https://wild-grocery.herokuapp.com/api/user/$id');
                      dio
                          .post(
                              'https://wild-grocery.herokuapp.com/api/create/report',
                              data: formData,
                              options: Options(
                                // headers: {
                                //   HttpHeaders.authorizationHeader:
                                //       'Bearer $newToken',
                                //   // HttpHeaders.contentTypeHeader: 'application/json',
                                // },
                                method: 'POST',
                                followRedirects: false,
                                // validateStatus: (status) {
                                //   return status <= 500;
                                // }
                                // responseType: ResponseType.json // or ResponseType.JSON
                              ))
                          .then((response) {
                        var data = json.decode(response.statusMessage);
                        print(data);
                        Navigator.pop(context);
                      }).catchError((error) => print('error $error'));
                    }
                  }),
                  // Container(
                  //   child: ListView.builder(
                  //     itemCount: order.length,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     shrinkWrap: true,
                  //     itemBuilder: (context, i) {
                  //       return Container(
                  //         decoration: BoxDecoration(
                  //           color: MColors.primaryWhite,
                  //           borderRadius: BorderRadius.all(
                  //             Radius.circular(10.0),
                  //           ),
                  //         ),
                  //         margin: EdgeInsets.symmetric(vertical: 4.0),
                  //         padding: EdgeInsets.all(7.0),
                  //         child: Row(
                  //           children: <Widget>[
                  //             Container(
                  //               width: 30.0,
                  //               height: 40.0,
                  //               child: FadeInImage.assetNetwork(
                  //                 image:
                  //                     'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
                  //                 fit: BoxFit.fill,
                  //                 height: MediaQuery.of(context).size.height,
                  //                 placeholder: "assets/images/placeholder.jpg",
                  //                 placeholderScale:
                  //                     MediaQuery.of(context).size.height / 2,
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               width: 5.0,
                  //             ),
                  //             Container(
                  //               width: MediaQuery.of(context).size.width / 2,
                  //               child: Text(
                  //                 order[i]['name'],
                  //                 maxLines: 2,
                  //                 overflow: TextOverflow.ellipsis,
                  //                 softWrap: true,
                  //                 style: normalFont(MColors.textGrey, 14.0),
                  //               ),
                  //             ),
                  //             SizedBox(
                  //               width: 5.0,
                  //             ),
                  //             Container(
                  //               padding: const EdgeInsets.all(3.0),
                  //               decoration: BoxDecoration(
                  //                 color: MColors.dashPurple,
                  //                 borderRadius: new BorderRadius.circular(10.0),
                  //               ),
                  //               child: Text(
                  //                 "X" + order[i]['quantity'].toString(),
                  //                 style: normalFont(MColors.textGrey, 14.0),
                  //                 textAlign: TextAlign.left,
                  //               ),
                  //             ),
                  //             Spacer(),
                  //             Container(
                  //               child: Text(
                  //                 "Rs.0",
                  //                 // order[i]['selling_price']
                  //                 //     .toStringAsFixed(2),
                  //                 style: boldFont(MColors.textDark, 14.0),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  //Order details
  void _showModalSheet(Order orderListItem) {
    var orderID = orderListItem.id;
    var order = orderListItem.products.toList();
    var orderTotalPriceList = order.map((e) => e['price']);
    var orderTotalPrice = orderListItem.amount;
    // orderTotalPriceList
    //     .reduce((sum, element) => sum + element)
    //     .toStringAsFixed(2);
    print(order);
    var orderDayTime = DateTime.parse(orderListItem.createdAt).day.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).month.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).year.toString();

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
                        style: boldFont(MColors.mainColor, 16.0),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.textGrey,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Rs." + orderTotalPrice.toString(),
                      style: boldFont(MColors.mainColor, 16.0),
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
                              "Order ID: ",
                              style: normalFont(MColors.textGrey, 14.0),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                orderID,
                                overflow: TextOverflow.ellipsis,
                                style: boldFont(MColors.textGrey, 14.0),
                              ),
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
                orderTrackerWidget(orderListItem.status),
                SizedBox(height: 15.0),
                Text(
                  "Delivering to",
                  style: boldFont(MColors.textGrey, 14.0),
                ),
                SizedBox(height: 5.0),
                Text(
                  orderListItem.address['address'],
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
                                image:
                                    'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
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
                                // "Rs.0",
                                order[i]['price'].toStringAsFixed(2),
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

  void _showCancelModalSheet(Order orderListItem) {
    var orderID = orderListItem.id;
    var order = orderListItem.products.toList();
    var orderTotalPriceList = order.map((e) => e['price']);
    var orderTotalPrice = orderListItem.amount;
    // orderTotalPriceList
    //     .reduce((sum, element) => sum + element)
    //     .toStringAsFixed(2);
    print(order);
    var orderDayTime = DateTime.parse(orderListItem.createdAt).day.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).month.toString() +
        "-" +
        DateTime.parse(orderListItem.createdAt).year.toString();

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
                        style: boldFont(MColors.mainColor, 16.0),
                      ),
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.textGrey,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "Rs." + orderTotalPrice.toString(),
                      style: boldFont(MColors.mainColor, 16.0),
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
                              "Order ID: ",
                              style: normalFont(MColors.textGrey, 14.0),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                orderID,
                                overflow: TextOverflow.ellipsis,
                                style: boldFont(MColors.textGrey, 14.0),
                              ),
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
                orderTrackerWidget(orderListItem.status),
                SizedBox(height: 15.0),
                Text(
                  "Delivering to",
                  style: boldFont(MColors.textGrey, 14.0),
                ),
                SizedBox(height: 5.0),
                Text(
                  orderListItem.address['address'],
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
                                image:
                                    'https://wild-grocery.herokuapp.com/${order[i]['imgURL']}',
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
                                // "Rs.0",
                                order[i]['price'].toStringAsFixed(2),
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
