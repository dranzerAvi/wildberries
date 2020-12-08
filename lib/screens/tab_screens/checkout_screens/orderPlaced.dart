

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrpet/main.dart';
import 'package:mrpet/model/data/userData.dart';
import 'package:mrpet/screens/tab_screens/home.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/root_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPlaced extends StatefulWidget {
  final List<UserDataAddress> addressList;
  OrderPlaced(this.addressList);
  @override
  _OrderPlacedState createState() => _OrderPlacedState(addressList);
}

class _OrderPlacedState extends State<OrderPlaced> {
  final List<UserDataAddress> addressList;
  _OrderPlacedState(this.addressList);
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
    return Scaffold(
      backgroundColor: MColors.primaryWhiteSmoke,
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
      body: primaryContainer(
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              Center(
                child: Container(
                  height: 70.0,
                  width: 70.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MColors.dashPurple,
                  ),
                  child: Icon(
                    Icons.check,
                    color: MColors.secondaryColor,
                    size: 30.0,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                  "Thank you!",
                  style: boldFont(MColors.textDark, 20.0),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                child: Center(
                  child: Text(
                    "Your order has been successfully placed",
                    style: boldFont(MColors.textGrey, 16.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: SvgPicture.asset(
                  "assets/images/orderPlaced.svg",
                  height: 150,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "An order confirmation and purchase reciept will be sent to your email.",
                  style: normalFont(MColors.textGrey, 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Your purchased items will be delivered to",
                      style: normalFont(MColors.textGrey, 16),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      addressList.first.addressNumber +
                          ", " +
                          addressList.first.addressLocation,
                      style: boldFont(MColors.textGrey, 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: primaryButtonPurple(
          Text("Back home", style: boldFont(MColors.primaryWhite, 16.0)),
          () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (_) => HomeScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
    );
  }
}
