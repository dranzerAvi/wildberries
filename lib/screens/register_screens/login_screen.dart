import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mrpet/main.dart';
import 'package:mrpet/model/data/cart.dart';
import 'package:mrpet/model/services/user_management.dart';
import 'package:mrpet/screens/register_screens/registration_screen.dart';
import 'package:mrpet/screens/register_screens/reset_screen.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/utils/textFieldFormaters.dart';
import 'package:mrpet/widgets/provider.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:progress_dialog/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  CartNotifier _cartNotifier;
  final formKey = GlobalKey<FormState>();
  final loginKey = GlobalKey<_LoginScreenState>();
  var id='';
  String _email;
  String _password;
  String _error;
  bool _autoValidate = false;
  bool _isButtonDisabled = false;
  bool _obscureText = true;
  bool _isEnabled = true;
  final db = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
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
                  "Sign in to your account",
                  style: boldFont(MColors.textDark, 38.0),
                  textAlign: TextAlign.start,
                ),
              ),

              SizedBox(height: 20.0),

              Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      "Do not have an account? ",
                      style: normalFont(MColors.textGrey, 16.0),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      child: Text(
                        "Create it!",
                        style: normalFont(MColors.primaryPurple, 16.0),
                        textAlign: TextAlign.start,
                      ),
                      onTap: () {
                        formKey.currentState.reset();
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                            builder: (_) => RegistrationScreen(),
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
                                  color: MColors.primaryPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          0.50,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_box,
                          color: MColors.primaryPurple,
                        ),
                        SizedBox(width: 5.0),
                        Container(
                          child: Text(
                            "Remember me.",
                            style: normalFont(MColors.textDark, null),
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
                              "Sign in",
                              style: boldFont(
                                MColors.primaryWhite,
                                16.0,
                              ),
                            ),
                            _isButtonDisabled ? null : _submit,
                          ),
                    SizedBox(height: 20.0),
                    _signInButton(),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => ResetScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot password?",
                        style: normalFont(MColors.textGrey, null),
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
  }
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  int j = 0;
  int length = 0;
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final ProgressDialog pr = await ProgressDialog(context);
    pr.style(
        message: 'Logging in..',
        backgroundColor: Colors.white,
        progressWidget: GFLoader(
          type: GFLoaderType.ios,
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    await pr.show();
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = await _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print('signInWithGoogle succeeded: $user');
      FirebaseFirestore.instance.collection('userData').snapshots().listen((element) {
        length = element.docs.length;
        print(length);
        for (int i = 0; i < element.docs.length; i++) {
          if (element.docs[i].id != googleSignIn.currentUser.email) {
            print(element.docs[i].id);
            j++;
            print(j.toString());
          }
        }
        if (j == length) {
         storeNewUser(googleSignIn.currentUser.displayName, '', googleSignIn.currentUser.email);
        }
      });

      await pr.hide();
      return '$user';
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
Future<dynamic> Cartdetails(CartNotifier cartNotifier)async{
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

  });

  cartNotifier.cartList = cartList;

  QuerySnapshot snapshot2 = await FirebaseFirestore.instance
      .collection("userCart")
      .doc(_email)
      .collection("cartItems")
      .get();


  List<Cart> cartList2 = [];
  snapshot.docs.forEach((document) async{
    Cart cart = Cart.fromMap(document.data());
    cartList2.add(cart);

  });

  cartNotifier.cartList = cartList2;
}
 void  _submit() async {
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
        String uid = await auth.signInWithEmailAndPassword(_email, _password);

Cartdetails(_cartNotifier);

        print("Signed in with $uid");

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
          _error = e.toString();
          _isButtonDisabled = false;
          _isEnabled = true;
        });
      }

      print("ERRORR ==>");
      print(e);
    }
  }
  Widget _signInButton() {
    return Container(
      width: 400,
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          signInWithGoogle().then((result) {
            if (result != null) {
              Cartdetails(_cartNotifier);

              print("Signed in with $googleSignIn");

              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (_) => MyApp(),
                ),
              );
//              _getToken();
//              Navigator.of(context).push(
//                MaterialPageRoute(
//                  builder: (context) {
//                    return RootScreen();
//                  },
//                ),
//              );
            }
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: AssetImage("assets/images/google.png"), height: 30.0),
              SizedBox(width:10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
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
}
