import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrpet/main.dart';
import 'package:mrpet/model/data/cart.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/userData_notifier.dart';
import 'package:mrpet/model/services/user_management.dart';
import 'package:mrpet/screens/register_screens/login_screen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/textFieldFormaters.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/widgets/provider.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
var id='';
CartNotifier cartNotifier;
final db=FirebaseFirestore.instance;
  String _name;
  String _phone;
  String _email;
  String _password;
  String _error;
  bool _autoValidate = false;
  bool _isButtonDisabled = false;
  bool _obscureText = true;
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserDataProfileNotifier>(
      create: (BuildContext context) => UserDataProfileNotifier(),
      child: Consumer<UserDataProfileNotifier>(
        builder: (context, profileNotifier, _) {
          return Scaffold(
            backgroundColor: MColors.primaryWhiteSmoke,
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: primaryContainer(
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Text(
                        "Create your free account",
                        style: boldFont(MColors.textDark, 38.0),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    SizedBox(height: 20.0),

                    Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            "Already have an account? ",
                            style: normalFont(MColors.textGrey, 16.0),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            child: Text(
                              "Sign in!",
                              style: normalFont(MColors.secondaryColor, 16.0),
                              textAlign: TextAlign.start,
                            ),
                            onTap: () {
                              formKey.currentState.reset();
                              Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.0),

                    showAlert(),

                    SizedBox(height: 10.0),

                    //FORM
                    Form(
                      key: formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Name",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "Remiola",
                                (val) => _name = val,
                                _isEnabled,
                                NameValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.text,
                                null,
                                null,
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Email",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "e.g Remiola2034@gmail.com",
                                (val) => _email = val,
                                _isEnabled,
                                EmailValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.emailAddress,
                                null,
                                null,
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Password",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                null,
                                (val) => _password = val,
                                _isEnabled,
                                PasswordValiditor.validate,
                                _obscureText,
                                _autoValidate,
                                false,
                                TextInputType.text,
                                null,
                                SizedBox(
                                  height: 20.0,
                                  width: 40.0,
                                  child: RawMaterialButton(
                                    onPressed: _toggle,
                                    child: Text(
                                      _obscureText ? "Show" : "Hide",
                                      style: TextStyle(
                                        color: MColors.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: Text(
                              "Your password must have 6 or more characters.",
                              style: normalFont(MColors.secondaryColor, null),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Phone number",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                null,
                                null,
                                "e.g +971 4 4475 70",
                                (val) => _phone = val,
                                _isEnabled,
                                PhoneNumberValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.numberWithOptions(),
                                [maskTextInputFormatter],
                                null,
                                0.50,
                              ),
                              SizedBox(height: 10.0),
                              Container(
                                child: Text(
                                  "Your number should contain your country code and state code.",
                                  style:
                                      normalFont(MColors.secondaryColor, null),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.verified_user,
                                    color: MColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        "By continuing, you agree to our Terms of Service.",
                                        style:
                                            normalFont(MColors.textGrey, null),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              _isButtonDisabled == true
                                  ? primaryButtonPurple(
                                      //if button is loading
                                      progressIndicator(Colors.white),
                                      null,
                                    )
                                  : primaryButtonPurple(
                                      Text(
                                        "Next step",
                                        style: boldFont(
                                          MColors.primaryWhite,
                                          16.0,
                                        ),
                                      ),
                                      _isButtonDisabled ? null : _submit,
                                    ),
                              SizedBox(height: 20.0),
                            ],
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
    );
  }

  Widget showAlert() {
    if (_error != null) {
      return Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.error_outline,
                color: Colors.redAccent,
              ),
            ),
            Expanded(
              child: Text(
                _error,
                style: normalFont(Colors.redAccent, 15.0),
              ),
            ),
          ],
        ),
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: MColors.primaryWhiteSmoke,
          border: Border.all(width: 1.0, color: Colors.redAccent),
          borderRadius: BorderRadius.all(
            Radius.circular(4.0),
          ),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
Future<dynamic>Cartdetails(CartNotifier cartNotifier)async{
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.id}');

    id=androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    print('Running on ${iosInfo.model}');
    id=iosInfo.model;
  }
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("tempUserCart")
      .doc(id)
      .collection("cartItems")
      .get();


  List<Cart> cartList = [];
  snapshot.docs.forEach((document) async{
    Cart cart = Cart.fromMap(document.data());
    cartList.add(cart);
    await db
        .collection("userCart")
        .doc(_email)
        .collection("cartItems")
        .doc(cart.productID)
        .set(cart.toMap())
        .catchError((e) {
      print(e);
    });

  });

  cartNotifier.cartList = cartList;






}
  void _submit() async {
    final form = formKey.currentState;

    try {
      final auth = MyProvider.of(context).auth;

      if (form.validate()) {
        form.save();

        if (mounted) {
          setState(() {
            _isButtonDisabled = true;
            _isEnabled = false;
          });
        }

        String uid = await auth.createUserWithEmailAndPassword(
          _email,
          _password,
          _phone,
        );

        storeNewUser(_name, _phone, _email);

Cartdetails(cartNotifier);
        print("Signed Up with new $uid");

        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => MyApp(),
          ),
        );
      } else {
        setState(() {
          _autoValidate = true;
          _isEnabled = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isButtonDisabled = false;
          _isEnabled = true;
        });
      }

      print("ERRORR ==>");
      print(e);
    }
  }
}
