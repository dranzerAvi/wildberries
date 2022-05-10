import 'dart:io';
import 'package:flutter/services.dart';
// import 'package:geocoder/geocoder.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geolocator/geolocator.dart' as gl;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gmlp;
import 'package:permission_handler/permission_handler.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/model/data/userData.dart';

import 'package:wildberries/screens/address/confirm_address.dart';
import 'package:wildberries/utils/colors.dart';
// import 'package:place_picker/entities/location_result.dart';
// import 'package:place_picker/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/model/data/address.dart';
import 'package:wildberries/widgets/allWidgets.dart';

import '../../main.dart';

class MyAddresses extends StatefulWidget {
  List<UserDataAddress> addresses;
  MyAddresses(this.addresses);
  @override
  _MyAddressesState createState() => _MyAddressesState();
}

class _MyAddressesState extends State<MyAddresses> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position currentPosition;
  String _currentAddress;

  var id;
  // void showPlacePicker() async {
  //   print('called');
  //   result = await Navigator.of(context).push(MaterialPageRoute(
  //       builder: (context) =>
  //           PlacePicker("AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw")));
  //   setState(() {
  //     location = result.formattedAddress;
  //   });
  //   // Handle the result in your way
  //   print(location);
  //   if (location != null) {
  //     Navigator.of(context).push(
  //         MaterialPageRoute(builder: (context) => ConfirmAddress(location)));
  //   }
  // }

  // List<Addresses> alladresses = [];
  List<Widget> addressCards = [];
  gmlp.LocationResult currentLocationAddress;

  @override
  void initState() {
    setState(() {});
    _getCurrentLocation();

    super.initState();
  }

  _getCurrentLocation() {
    print('Fetching');
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currentPosition = position;
        print('Position $position');
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
    print(currentPosition);
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
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

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
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
            'Wildberries',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        body: PreferenceBuilder<String>(
            preference: preferences.getString(
              'addresses',
              defaultValue: '',
            ),
            builder: (BuildContext context, String counter) {
              print(counter);
              var cartTotal = 0;

              List<UserDataAddress> addresses = [];
              if (counter != '') addresses = UserDataAddress.decode(counter);

              return addresses.length == 0
                  ? emptyScreen(
                      "assets/images/emptyCart.svg",
                      "Bag is empty",
                      "Products you add to your bag will show up here. So lets get shopping and make your pet happy.",
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemCount: addresses.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var item = addresses[index];
                                return Card(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        (item.address != null &&
                                                item.address != '')
                                            ? Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  'Address : ${item.address}',
                                                  style: normalFont(
                                                      MColors.mainColor, 16),
                                                ),
                                              )
                                            : Text(''),
                                        (item.city != null && item.city != '')
                                            ? Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  'City : ${item.city}',
                                                  style: normalFont(
                                                      MColors.mainColor, 16),
                                                ))
                                            : Text(''),
                                        (item.zip != null && item.zip != '')
                                            ? Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  'ZIP Code : ${item.zip}',
                                                  style: normalFont(
                                                      MColors.mainColor, 16),
                                                ))
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ));
                              },
                            ),
                          ),
                          //

                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: primaryButtonPurple(
                                Text(
                                  '+ Add Address',
                                  style: boldFont(Colors.white, 16),
                                ),
                                () async {
                                  ServiceStatus serviceStatus =
                                      await PermissionHandler()
                                          .checkServiceStatus(
                                              PermissionGroup.location);
                                  bool enabled =
                                      (serviceStatus == ServiceStatus.enabled);
                                  print(enabled);
                                  if (enabled == false)
                                    showSimpleSnack(
                                      "Please turn on device location",
                                      Icons.warning_amber_outlined,
                                      Colors.amber,
                                      _scaffoldKey,
                                    );
                                  else {
                                    var result;
                                    String error;

//                                     result = await gmlp.showLocationPicker(
//                                       context,
//                                       'AIzaSyBRiKMx-SrPII728TuJ0cAPgVHC5l-e9s8',
//                                       initialCenter: LatLng(
//                                           currentPosition.latitude,
//                                           currentPosition.longitude),
//                                       automaticallyAnimateToCurrentLocation:
//                                           true,
// //                      mapStylePath: 'assets/mapStyle.json',
//                                       myLocationButtonEnabled: true,
//                                       requiredGPS: true,
//                                       layersButtonEnabled: true,
//                                       // countries: ['AE'],
//
// //                      resultCardAlignment: Alignment.bottomCenter,
// //                       desiredAccuracy: LocationAccuracy.best,
//                                     );
//                                     print("result = ${result.runtimeType}");
//                                     setState(() {
//                                       currentLocationAddress = result;
//                                       if (currentLocationAddress != null) {
//                                         Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     ConfirmAddress(
//                                                         currentLocationAddress,
//                                                         "",
//                                                         "",
//                                                         "")));
//
// //
//                                       }
//                                     });

                                    //TODO: Place Picker
                                    //-------------
//                                  _locationDialog(context);
//                                   showPlacePicker();
//                                   Navigator.push(context, MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                     return LocationScreen();
//                                   }));
//
                                  }
                                },
                              ))
                        ],
                      ),
                    );
            })
        // Container(
        //   child: SingleChildScrollView(
        //     child:
        //   ),
        // ),
        );
  }
}
