import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/cart.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/screens/register_screens/login_screen.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/utils/textFieldFormaters.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  var id = '';
  CartNotifier cartNotifier;
  // final db = FirebaseFirestore.instance;

  String _firstName;
  String _lastName;
  String phone;
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController otpController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController addresssController = new TextEditingController();
  TextEditingController zipController = new TextEditingController();
  String _otp;
  String _city;
  String _addresss;
  String _zip;
  bool _isOTPSent = false;
  String _error;
  bool _autoValidate = false;
  bool _isButtonDisabled = false;
  String token = '';
  bool _obscureText = true;
  bool _isEnabled = true;
  File _image;
  Future _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

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
                        "Create your account",
                        style: boldFont(MColors.textGrey, 38.0),
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
                              style: normalFont(MColors.textGrey, 16.0),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                    color: MColors.mainColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: _image == null
                                    ? FlatButton(
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                        onPressed: this._getImage,
                                        color: MColors.mainColor,
                                      )
                                    : Image.file(_image),
                                margin: EdgeInsets.only(top: 20.0),
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
                                  "First Name",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                firstNameController,
                                null,
                                "e.g. Shubham",
                                (val) => _firstName = val,
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
                              SizedBox(height: 10.0),
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Last Name",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                lastNameController,
                                null,
                                "e.g. Shukla",
                                (val) => _lastName = val,
                                _isEnabled,
                                EmailValiditor.validate,
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
                          SizedBox(height: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "Address",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                addresssController,
                                null,
                                null,
                                (val) => _addresss = val,
                                _isEnabled,
                                PasswordValiditor.validate,
                                false,
                                _autoValidate,
                                false,
                                TextInputType.text,
                                null,
                                null,
                                // SizedBox(
                                //   height: 20.0,
                                //   width: 40.0,
                                //   child: RawMaterialButton(
                                //     onPressed: _toggle,
                                //     child: Text(
                                //       _obscureText ? "Show" : "Hide",
                                //       style: TextStyle(
                                //         color: MColors.textGrey,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "City",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                cityController,
                                null,
                                null,
                                (val) => _city = val,
                                _isEnabled,
                                PasswordValiditor.validate,
                                false,
                                _autoValidate,
                                false,
                                TextInputType.text,
                                null,
                                null,
                                // SizedBox(
                                //   height: 20.0,
                                //   width: 40.0,
                                //   child: RawMaterialButton(
                                //     onPressed: _toggle,
                                //     child: Text(
                                //       _obscureText ? "Show" : "Hide",
                                //       style: TextStyle(
                                //         color: MColors.textGrey,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "ZIP Code",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                zipController,
                                null,
                                null,
                                (val) => _zip = val,
                                _isEnabled,
                                PasswordValiditor.validate,
                                false,
                                _autoValidate,
                                false,
                                TextInputType.text,
                                null,
                                null,
                                // SizedBox(
                                //   height: 20.0,
                                //   width: 40.0,
                                //   child: RawMaterialButton(
                                //     onPressed: _toggle,
                                //     child: Text(
                                //       _obscureText ? "Show" : "Hide",
                                //       style: TextStyle(
                                //         color: MColors.textGrey,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                0.50,
                              ),
                            ],
                          ),
                          SizedBox(height: 10.0),
                          // Container(
                          //   child: Text(
                          //     "Your password must have 6 or more characters.",
                          //     style: normalFont(MColors.textGrey, null),
                          //   ),
                          // ),
                          // SizedBox(height: 20.0),
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
                                phoneController,
                                null,
                                "",
                                (val) => phone = val,
                                _isEnabled,
                                PhoneNumberValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.numberWithOptions(),
                                [],
                                null,
                                0.50,
                              ),
                              SizedBox(height: 10.0),
                              Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Text(
                                  "OTP",
                                  style: normalFont(MColors.textGrey, null),
                                ),
                              ),
                              primaryTextField(
                                otpController,
                                null,
                                "",
                                (val) => _otp = val,
                                _isEnabled,
                                PhoneNumberValiditor.validate,
                                false,
                                _autoValidate,
                                true,
                                TextInputType.numberWithOptions(),
                                [],
                                null,
                                0.50,
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.verified_user,
                                    color: MColors.textGrey,
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
                              _isOTPSent == true
                                  ? primaryButtonPurple(
                                      Text(
                                        "Sign In",
                                        style: boldFont(
                                          MColors.primaryWhite,
                                          16.0,
                                        ),
                                      ),
                                      _verifyOTP,
                                    )
                                  : primaryButtonPurple(
                                      Text(
                                        "Get OTP",
                                        style: boldFont(
                                          MColors.primaryWhite,
                                          16.0,
                                        ),
                                      ),
                                      //   () {
                                      //   print(phoneController.text);
                                      // }
                                      _submit,
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

  void _submit() async {
    try {
      var url = Uri.parse('https://wild-grocery.herokuapp.com/api/sendOTP');
      var response =
          await http.post(url, body: {"phone": "+91${phoneController.text}"});
      var data = json.decode(response.body);
      // print(response.body);
      if (data['messages']['errorMessage'] == null)
        setState(() {
          // print(data['messages']['errorMessage']);
          _isOTPSent = true;
          token = data['token'];
          // id = data['_id'];
        });
      print('Token 1');
      print(token);
      // print(data);

      // Navigator.of(context).pushReplacement(
      //   CupertinoPageRoute(
      //     builder: (_) => MyApp(),
      //   ),
      // );

      // final auth = MyProvider.of(context).auth;
      // if (form.validate()) {
      //   form.save();
      //
      //   if (mounted) {
      //     setState(() {
      //       _isButtonDisabled = true;
      //       _isEnabled = false;
      //     });
      //   }
      //   String uid = await auth.signInWithEmailAndPassword(_email, _password);
      //
      //   Cartdetails(_cartNotifier);
      //
      //   print("Signed in with $uid");
      //

      // } else {
      //   setState(() {
      //     _autoValidate = true;
      //     _isEnabled = true;
      //   });
      // }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isOTPSent = false;
          _isEnabled = true;
        });
      }

      print("ERRORR ==>");
      print(e);
    }
  }

  List<UserDataAddress> addresses = [];

  void _verifyOTP() async {
    try {
      var url = Uri.parse('https://wild-grocery.herokuapp.com/api/verifyOTP');
      // print(otpController.text);
      var response = await http.post(url, body: {
        "phone": "+91${phoneController.text}",
        "token": token,
        "otp": otpController.text
      });
      var data = json.decode(response.body);
      // print(data['token 2']);
      print(data['token']);
      String newToken = await data['token'];
      if (data['token'] != null) {
        id = await data['userdata']['_id'];
        Dio dio = new Dio();
        String fileName = await _image.path.split('/').last;
        var formData = FormData.fromMap({
          "photo": MultipartFile.fromFile(_image.path, filename: fileName),
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'city': cityController.text,
          'address': addresssController.text,
          'zip': zipController.text,
        });
        // print('https://wild-grocery.herokuapp.com/api/user/$id');
        dio
            .put('https://wild-grocery.herokuapp.com/api/user/$id',
                data: formData,
                options: Options(
                  headers: {
                    HttpHeaders.authorizationHeader: 'Bearer $newToken',
                    HttpHeaders.contentTypeHeader: 'multipart/form-data',
                  },
                  method: 'PUT',
                  followRedirects: false,
                  // validateStatus: (status) {
                  //   return status <= 500;
                  // }
                  // responseType: ResponseType.json // or ResponseType.JSON
                ))
            .then((response) {
          // Navigator.of(context).pushReplacement(
          //   CupertinoPageRoute(
          //     builder: (_) => MyApp(),
          //   ),
          // );
          // print(response.data);
        }).catchError((error) => print(error));
      } else
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('OTP is incorrect')));
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isOTPSent = false;
          _isEnabled = true;
        });
      }

      print("ERRORR ==>");
      print(e);
    }
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

  Future<dynamic> Cartdetails(CartNotifier cartNotifier) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // print('Running on ${androidInfo.id}');

      // id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // print('Running on ${iosInfo.model}');
      // id = iosInfo.model;
    }
    //TODO:Check
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection("tempUserCart")
    //     .doc(id)
    //     .collection("cartItems")
    //     .get();

    List<Cart> cartList = [];
    // snapshot.docs.forEach((document) async {
    //   Cart cart = Cart.fromMap(document.data());
    //   cartList.add(cart);
    //   await db
    //       .collection("userCart")
    //       .doc(_email)
    //       .collection("cartItems")
    //       .doc(cart.productID)
    //       .set(cart.toMap())
    //       .catchError((e) {
    //     print(e);
    //   });
    // });

    cartNotifier.cartList = cartList;
  }
}
