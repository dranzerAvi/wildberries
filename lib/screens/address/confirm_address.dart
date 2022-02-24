import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/filter.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:wildberries/model/services/user_management.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class ConfirmAddress extends StatefulWidget {
  LocationResult location;
  String address;
  String city;
  String zip;
  ConfirmAddress(this.location, this.address, this.city, this.zip);
  @override
  _ConfirmAddressState createState() => _ConfirmAddressState();
}

class _ConfirmAddressState extends State<ConfirmAddress> {
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final zipController = TextEditingController();

  // List<Emirates> allemirates = [];
  //
  // List<Emirates> savedemirate = [];

  double minOrderPrice = 0;
  double deliveryCharge = 0;
  String area;
  String emirate2;
  String emirate;
  Map addressDetails = {};
  LatLng coordinates;

  var id = '';
  var minimumOrderValue = '150';
  // User user;

  @override
  void initState() {
    // locationselected.text = widget.location;

    if (widget.location.address != null)
      addressController.text = widget.location.address;
    else
      addressController.text = 'Test';
    getCity();
    print(widget.location.latLng.toString());
    super.initState();
  }

  getCity() async {
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(
            widget.location.latLng.latitude, widget.location.latLng.longitude));
    cityController.text = addresses.first.locality;
    zipController.text = addresses.first.postalCode;
  }

  final hnocontroller = TextEditingController();
  final localitycontroller = TextEditingController();
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

  int index = 0;
  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("Loading"),
            ],
          ),
        );
      },
    );
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    print(widget.location);
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: isLoading == false
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: CircularProgressIndicator(
                    backgroundColor: MColors.mainColor,
                  )),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirm shipping Address',
                          style: boldFont(MColors.mainColor, 20)),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '')
                              return 'Required field';
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
                                borderSide:
                                    BorderSide(color: MColors.mainColor)),
                            hintText: 'Address',
                          ),
                          controller: addressController,
                          style: normalFont(MColors.mainColor, 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '')
                              return 'Required field';
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
                                borderSide:
                                    BorderSide(color: MColors.mainColor)),
                            hintText: 'City',
                          ),
                          controller: cityController,
                          style: normalFont(MColors.mainColor, 14),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '')
                              return 'Required field';
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
                                borderSide:
                                    BorderSide(color: MColors.mainColor)),
                            hintText: 'ZIP',
                          ),
                          controller: zipController,
                          style: normalFont(MColors.mainColor, 14),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: primaryButtonPurple(
                            Text('Save Address',
                                style: normalFont(MColors.secondaryColor, 17)),
                            () async {
                          isLoading = await true;
                          setState(() {});
                          String user = '';
                          Preference<String> userProfileString =
                              preferences.getString('user', defaultValue: '');
                          await userProfileString.listen((value) async {
                            // UserDataProfile user = UserDataProfile.fromMap(json.decode(value));
                            UserDataProfile user =
                                await UserDataProfile.fromMap(
                                    json.decode(value));

                            var uri = Uri.parse(
                                'https://wild-grocery.herokuapp.com/api/user/add/address/${user.id}');
                            var addressResponse = await http.put(uri, body: {
                              "address": addressController.text,
                              "city": cityController.text,
                              "zip": zipController.text,
                              "lang":
                                  widget.location.latLng.latitude.toString(),
                              "long":
                                  widget.location.latLng.longitude.toString()
                            });
                            await refreshUserProfile(user);
                            print(addressResponse.body);
                          });
                          isLoading = false;
                          setState(() {});
                          new Future.delayed(new Duration(seconds: 3), () {
                            Navigator.pop(context); //pop dialog
                          });
                          // Navigator.pop(context);
                        }),
                      )
                    ],
                  ),
                ),
        ));
  }
}
