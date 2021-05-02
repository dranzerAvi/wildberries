import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:mrpet/model/data/emirates.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:mrpet/widgets/allWidgets.dart';


import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmAddress extends StatefulWidget {
  String location;
  ConfirmAddress(this.location);
  @override
  _ConfirmAddressState createState() => _ConfirmAddressState();
}

class _ConfirmAddressState extends State<ConfirmAddress> {
  final locationselected = TextEditingController();
  List<Emirates> allemirates = [];

  List<Emirates> savedemirate = [];

  double minOrderPrice = 0;
  double deliveryCharge = 0;
  String area;
  String emirate2;
  String emirate;






  void areas() async {


    await FirebaseFirestore.instance
        .collection('Emirates')
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        print(value.docs.length);

        emiratesname.add(value.docs[i]['name']);
        Emirates emi = Emirates(value.docs[i]['deliveryCharge'],
            value.docs[i]['minOrderPrice'], value.docs[i]['name']);

        savedemirate.add(emi);
      }
    });
    emirate = savedemirate[0].name;


          deliveryCharge = double.parse(savedemirate[0].deliverycharge);
          minOrderPrice = double.parse(savedemirate[0].minorderprice);
        }




  List<String> emiratesname = [];
  List<String> areaname = [];
  var id = '';
  var minimumOrderValue = '150';
User user;
  void addAddress() async {
     user = await FirebaseAuth.instance.currentUser;
  }

  void setaddress() async {

         await FirebaseFirestore.instance
        .collection('userData')
        .doc(user.email)
        .collection('address2')
        .add({
      'address': locationselected.text,
      'hno': hnocontroller.text,
      'landmark': localitycontroller.text,
      'Emirate': emirate,

    });

    Navigator.of(context).pop(minimumOrderValue);
  }

  @override
  void initState() {
    locationselected.text = widget.location;

    addAddress();
    areas();

    super.initState();
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
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw Fluttertoast.showToast(
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
            'Misterpet.ae',
            style: TextStyle(
                color: MColors.secondaryColor,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: areaname.length!=0?Column(
              children: [
               Text('Complete your address',style:TextStyle(color:Colors.black,fontSize:25,fontFamily:'Poppins',fontWeight: FontWeight.bold)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(color: Color(0xFF6b3600))),
                    ),
                    maxLines: 2,
                    controller: locationselected,
                  ),
                ),
                StreamBuilder(
                    stream:
                    FirebaseFirestore.instance.collection('Emirates').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        allemirates.clear();
                        emiratesname.clear();
                        for (int i = 0; i < snap.data.docs.length; i++) {
                          print(snap.data.docs.length);
                          emirate2 = snap.data.docs[0]['name'];
                          emiratesname.add(snap.data.docs[i]['name']);
                          Emirates emi = Emirates(
                              snap.data.docs[i]['deliveryCharge'],
                              snap.data.docs[i]['minOrderPrice'],
                              snap.data.docs[i]['name']);

                          allemirates.add(emi);
                        }
                        if (emirate == null) {
                          emirate = allemirates[0].name;
                        }
                        // minimumOrderValue = allemirates[0].minorderprice;
                        return allemirates.length != 0
                            ? Column(
                          children: [
                            Container(
                              width:
                              MediaQuery.of(context).size.width * 0.9,
                              child: DropdownButtonHideUnderline(
                                child:
                                new DropdownButtonFormField<String>(
                                  validator: (value) => value == null
                                      ? 'field required'
                                      : null,
                                  hint: Text('Emirates'),
                                  value: emirate,
                                  items: emiratesname.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      emirate = newValue;
                                      emirate2 = newValue;
                                      print(emirate);

                                            for (int i = 0;
                                                i < allemirates.length;
                                                i++) {
                                              if (allemirates[i].name ==
                                                  newValue) {
                                                minimumOrderValue =
                                                    allemirates[i]
                                                        .minorderprice;
                                                deliveryCharge=double.parse(allemirates[i].deliverycharge);
                                                print(allemirates[i]
                                                    .minorderprice);
                                                print(allemirates[i].name);
                                              }
                                            }
                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                            : Container();
                      } else {
                        return Container();
                      }
                    }),
//                StreamBuilder(
//                    stream: Firestore.instance
//                        .collection('EmiratesArea')
//                        .where('Emirate', isEqualTo: emirate)
//                        .snapshots(),
//                    builder: (BuildContext context,
//                        AsyncSnapshot<QuerySnapshot> snap) {
//                      if (snap.hasData && !snap.hasError && snap.data != null) {
//                        allareas.clear();
//                        areaname.clear();
//                        index = 0;
//                        for (int i = 0; i < snap.data.documents.length; i++) {
//                          if (i == 0) {
//                            areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                            EmiratesArea emi2 = EmiratesArea(
//                                snap.data.documents[i]['Emirate'],
//                                snap.data.documents[i]['deliveryCharge'],
//                                snap.data.documents[i]['minOrderPrice'],
//                                '${snap.data.documents[i]['name']}',
//                                snap.data.documents[i]['zone']);
//                            allareas.add(emi2);
//                          }
////                          print(snap.data.documents.length);
//                          for (int j = i + 1;
//                              j < snap.data.documents.length;
//                              j++) {
//                            if (snap.data.documents[i]['name'] ==
//                                snap.data.documents[j]['name']) {
//                              areaname
//                                  .add(' ${snap.data.documents[j]['name']}');
//                              print(
//                                  '5555555555555${snap.data.documents[j]['name']}');
//                              print(
//                                  'Minorder${snap.data.documents[j]['minOrderPrice']}');
//                              EmiratesArea emi2 = EmiratesArea(
//                                  snap.data.documents[j]['Emirate'],
//                                  snap.data.documents[j]['deliveryCharge'],
//                                  snap.data.documents[j]['minOrderPrice'],
//                                  ' ${snap.data.documents[j]['name']}',
//                                  snap.data.documents[j]['zone']);
//                              allareas.add(emi2);
//                              print('length:${areaname.length}');
//                              index = j;
//                              print('Index:${index}');
//                            }
//                          }
//                          if (i != index) {
//                            areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                            EmiratesArea emi2 = EmiratesArea(
//                                snap.data.documents[i]['Emirate'],
//                                snap.data.documents[i]['deliveryCharge'],
//                                snap.data.documents[i]['minOrderPrice'],
//                                '${snap.data.documents[i]['name']}',
//                                snap.data.documents[i]['zone']);
//                            allareas.add(emi2);
//                          }
//                        }
//                        areaname.add('Others');
//                        if (area == null) {
//                          area = allareas[0].name;
//                        }
//                        return areaname.length != 0

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Color(0xFF6b3600))),
                        hintText: 'House No.(Optional)'),
                    controller: hnocontroller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(2),
                            borderSide: BorderSide(color: Color(0xFF6b3600))),
                        hintText: 'Landmark(Optional)'),
                    controller: localitycontroller,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
             Center(
               child: InkWell(
                 onTap:(){
                   setaddress();
                 },
                 child: Container(
                   height:MediaQuery.of(context).size.height*0.06,
                   width:MediaQuery.of(context).size.width*0.85,
                   color:MColors.secondaryColor,
                   child:Text('Save Address',style:TextStyle(color: Colors.white,fontFamily: 'Poppins',fontSize: 22))
                 ),
               ),
             )
              ],
            ):Center(
              child: Container(
                  height:100,
                  width:100,
                  child:CircularProgressIndicator()
              ),
            ),
          ),
        ));
  }
}
