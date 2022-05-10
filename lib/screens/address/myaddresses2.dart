import 'dart:io';
import 'package:flutter/services.dart';
// import 'package:geocoder/geocoder.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:geolocator/geolocator.dart' as gl;
import 'package:geolocator/geolocator.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart'
    as gmlp;

import 'package:wildberries/screens/address/confirm_address.dart';
import 'package:wildberries/utils/colors.dart';
// import 'package:place_picker/entities/location_result.dart' ;
// import 'package:place_picker/place_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wildberries/model/data/address.dart';
import 'package:wildberries/screens/tab_screens/checkout_screens/completeOrder.dart';
import 'package:wildberries/model/notifiers/cart_notifier.dart';
import 'package:wildberries/model/services/Product_service.dart';
import 'package:wildberries/screens/tab_screens/checkout_screens/completeOrder.dart';
import 'package:wildberries/utils/colors.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:provider/provider.dart';

class MyAddresses2 extends StatefulWidget {
  String id;
  MyAddresses2(this.id);
  @override
  _MyAddresses2State createState() => _MyAddresses2State();
}

class _MyAddresses2State extends State<MyAddresses2> {
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

  List<Addresses> alladresses = [];
  List<Widget> addressCards = [];
  gmlp.LocationResult currentLocationAddress;
  void alladdresses() async {
    setState(() {
      alladresses.clear();
      print(alladresses.length);
    });

    print('--------------');
    //TODO:Check
    // await FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(widget.id)
    //     .collection('address2')
    //     .snapshots()
    //     .forEach((element) {
    //   element.docs.forEach((element) {
    //     setState(() {
    //       Addresses add = Addresses(element['address'], element['hno'],
    //           element['landmark'], element['Emirate']);
    //       alladresses.add(add);
    //     });
    //     print(id);
    //     print(alladresses.length);
    //   });
    // });
  }

  @override
  void initState() {
    setState(() {
      alladresses.clear();
      print(alladresses.length);
    });

    alladdresses();
    CartNotifier cartNotifier =
        Provider.of<CartNotifier>(context, listen: false);

    getCart(cartNotifier);
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

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url)
      : throw Fluttertoast.showToast(
          msg: 'Could not launch URL', toastLength: Toast.LENGTH_SHORT);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                //TODO:Check
                // child: StreamBuilder(
                //     stream: FirebaseFirestore.instance
                //         .collection('userData')
                //         .doc(widget.id)
                //         .collection('address2')
                //         .snapshots(),
                //     builder: (BuildContext context,
                //         AsyncSnapshot<QuerySnapshot> snap) {
                //       if (snap.hasData &&
                //           !snap.hasError &&
                //           snap.data != null) {
                //         alladresses.clear();
                //         for (int i = 0; i < snap.data.docs.length; i++) {
                //           print(snap.data.docs.length);
                //           Addresses add = Addresses(
                //             snap.data.docs[i]['address'],
                //             snap.data.docs[i]['hno'],
                //             snap.data.docs[i]['landmark'],
                //             snap.data.docs[i]['Emirate'],
                //           );
                //           alladresses.add(add);
                //         }
                //         return alladresses.length != 0
                //             ? Column(
                //                 children: [
                //                   Text('Saved Addresses'),
                //                   ListView.builder(
                //                     itemCount: alladresses.length,
                //                     shrinkWrap: true,
                //                     physics: ClampingScrollPhysics(),
                //                     itemBuilder: (context, index) {
                //                       var item = alladresses[index];
                //                       return InkWell(
                //                         onTap: () {
                //                           CartNotifier cartNotifier =
                //                               Provider.of<CartNotifier>(
                //                                   context);
                //                           var cartList =
                //                               cartNotifier.cartList;
                //                           (item.hno != null &&
                //                                   item.hno != '' &&
                //                                   item.landmark != null &&
                //                                   item.landmark != '')
                //                               ? Navigator.pushReplacement(
                //                                   context,
                //                                   MaterialPageRoute(
                //                                       builder: (context) =>
                //                                           AddressContainer(
                //                                               cartList,
                //                                               'H.no. ${item.hno} , ${item.address} , near ${item.landmark},Emirate: ${item.emirate}',
                //                                               item.emirate)))
                //                               : (item.hno != null &&
                //                                       item.hno != '')
                //                                   ? Navigator.pushReplacement(
                //                                       context,
                //                                       MaterialPageRoute(
                //                                           builder: (context) => AddressContainer(
                //                                               cartList,
                //                                               'H.no. ${item.hno} , ${item.address}, Emirate: ${item.emirate}',
                //                                               item.emirate)))
                //                                   : Navigator.pushReplacement(
                //                                       context,
                //                                       MaterialPageRoute(
                //                                           builder: (context) =>
                //                                               AddressContainer(
                //                                                   cartList,
                //                                                   '${item.address} , Emirate: ${item.emirate} ',
                //                                                   item.emirate)));
                //                         },
                //                         child: Card(
                //                             child: Padding(
                //                           padding: const EdgeInsets.all(8.0),
                //                           child: Column(
                //                             mainAxisAlignment:
                //                                 MainAxisAlignment.start,
                //                             children: [
                //                               (item.hno != null &&
                //                                       item.hno != '')
                //                                   ? Align(
                //                                       alignment: Alignment
                //                                           .bottomLeft,
                //                                       child: Text(
                //                                           'Address : H.no. ${item.hno} , ${item.address}'),
                //                                     )
                //                                   : Align(
                //                                       alignment: Alignment
                //                                           .bottomLeft,
                //                                       child: Text(
                //                                           'Address :  ${item.address}'),
                //                                     ),
                //                               (item.landmark != null &&
                //                                       item.landmark != '')
                //                                   ? Align(
                //                                       alignment: Alignment
                //                                           .bottomLeft,
                //                                       child: Text(
                //                                           'Landmark : ${item.landmark}'))
                //                                   : Text(''),
                //                               item.emirate != null
                //                                   ? Align(
                //                                       alignment: Alignment
                //                                           .bottomLeft,
                //                                       child: Text(
                //                                           'Emirate : ${item.emirate}'))
                //                                   : Container(),
                //                             ],
                //                           ),
                //                         )),
                //                       );
                //                     },
                //                   )
                //                 ],
                //               )
                //             : Container();
                //       } else {
                //         return Container();
                //       }
                //     })
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                    onTap: () async {
                      //TODO: Place Picker
                      var result;
                      String error;
//
//                       gmlp.showLocationPicker(
//                         context,
//                         'AIzaSyAXFXYI7PBgP9KRqFHp19_eSg-vVQU-CRw',
//                         initialCenter: LatLng(31.1975844, 29.9598339),
//                         automaticallyAnimateToCurrentLocation: true,
// //                      mapStylePath: 'assets/mapStyle.json',
//                         myLocationButtonEnabled: true,
//                         // requiredGPS: true,
//                         layersButtonEnabled: true,
//                         countries: ['AE'],
//
// //                      resultCardAlignment: Alignment.bottomCenter,
// //                       desiredAccuracy: LocationAccuracy.best,
//                       );
//                       print("result = $result");
//                       setState(() {
//                         currentLocationAddress = result;
//                         if (currentLocationAddress != null) {
//                           Navigator.of(context).push(MaterialPageRoute(
//                               builder: (context) => ConfirmAddress(
//                                   currentLocationAddress, "", "", "")));
//
// //
//                         }
//                       });
                      //TODO: Place Picker
//                                  _locationDialog(context);
//                                   showPlacePicker();
//                                   Navigator.push(context, MaterialPageRoute(
//                                       builder: (BuildContext context) {
//                                     return LocationScreen();
//                                   }));
//
                    },
                    child: Center(
                      child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.85,
                          color: MColors.secondaryColor,
                          child: Center(
                              child: Text('+ Add Address',
                                  style: TextStyle(color: Colors.white)))),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
