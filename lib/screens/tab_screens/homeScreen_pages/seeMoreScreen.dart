import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wildberries/model/data/Products.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/products_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/search_screens/search_tabs.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/custom_floating_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bag.dart';

class SeeMoreScreen extends StatefulWidget {
  final String title;
  final Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final String categoryId;

  SeeMoreScreen(
      {Key key,
      this.title,
      this.products,
      this.cartNotifier,
      this.productsNotifier,
      this.cartProdID,
      this.categoryId})
      : super(key: key);

  @override
  _SeeMoreScreenState createState() => _SeeMoreScreenState(
      title, products, cartNotifier, productsNotifier, cartProdID, categoryId);
}

class _SeeMoreScreenState extends State<SeeMoreScreen> {
  final String title;
  final Iterable<ProdProducts> products;
  final CartNotifier cartNotifier;
  final ProductsNotifier productsNotifier;
  final Iterable<String> cartProdID;
  final String categoryId;

  _SeeMoreScreenState(this.title, this.products, this.cartNotifier,
      this.productsNotifier, this.cartProdID, this.categoryId);
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
    var cartList = cartNotifier.cartList;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          size: 20,
          color: MColors.secondaryColor,
        ),
        backgroundColor: MColors.mainColor,
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
                    phone: '7060222315', message: 'Check out this awesome app');
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
      floatingActionButton: CustomFloatingButton(
          CurrentScreen(currentScreen: SeeMoreScreen(), tab_no: 0)),
      body: SearchTabWidget(
        prods: products,
        cartNotifier: cartNotifier,
        productsNotifier: productsNotifier,
        cartProdID: cartProdID,
        categoryId: categoryId,
      ),
    );
  }
}
