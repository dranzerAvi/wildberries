import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wildberries/screens/register_screens/login_screen.dart';
import 'package:wildberries/screens/register_screens/registration_screen.dart';
import 'package:wildberries/screens/tab_screens/home.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/strings.dart';
import 'package:wildberries/widgets/allWidgets.dart';

import '../../main.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

//Push
class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _showCloseAppDialog();
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    "assets/images/wb.png",
                    height: 200,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  child: Text(
                    "Welcome to WildBerries",
                    style: boldFont(MColors.textDark, 30.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10.0),
                Container(
                  child: Text(
                    'Here you will find fresh meat and dairy products at the best price. We maintain the quality of the product while keeping it nice and fresh.',
                    style: normalFont(MColors.textGrey, 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 150.0,
          color: MColors.primaryWhite,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              primaryButtonPurple(
                Text(
                  "Sign in",
                  style: boldFont(MColors.primaryWhite, 16.0),
                ),
                () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              primaryButtonWhiteSmoke(
                Text(
                  "Create an account",
                  style: boldFont(MColors.secondaryColor, 16.0),
                ),
                () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => RegistrationScreen(),
                    ),
                  );
                },
              ),
              // SizedBox(
              //   height: 10.0,
              // ),
              // primaryButtonPurple(
              //   Text(
              //     "Skip This Step",
              //     style: boldFont(MColors.primaryWhite, 16.0),
              //   ),
              //   () {
              //     Navigator.of(context).pushReplacement(
              //       CupertinoPageRoute(
              //         builder: (_) => MyApp(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCloseAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              "Are you sure you want to leave?",
              style: normalFont(MColors.textGrey, 14.0),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Cancel",
                  style: normalFont(MColors.textGrey, 14.0),
                ),
              ),
              FlatButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  "Leave",
                  style: normalFont(Colors.redAccent, 14.0),
                ),
              ),
            ],
          );
        });
  }
}
