import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mrpet/model/data/cart.dart';
import 'package:mrpet/model/data/emirates.dart';
import 'package:mrpet/model/notifiers/cart_notifier.dart';
import 'package:mrpet/model/notifiers/userData_notifier.dart';
import 'package:mrpet/model/services/Product_service.dart';
import 'package:mrpet/model/services/auth_service.dart';
import 'package:mrpet/model/services/user_management.dart';
import 'package:mrpet/screens/tab_screens/checkout_screens/addPaymentMethod.dart';
import 'package:uuid/uuid.dart';
import 'package:mrpet/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:mrpet/widgets/allWidgets.dart';
import 'package:mrpet/screens/tab_screens/checkout_screens/enterAddress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orderPlaced.dart';
import 'package:mrpet/screens/address/myaddresses2.dart';

class AddressContainer extends StatefulWidget {
  final List<Cart> cartList;
  String address;String savedEmirate;
  AddressContainer(this.cartList,this.address,this.savedEmirate);
  @override
  _AddressContainerState createState() => _AddressContainerState(cartList,address);
}

class AddressScreen extends StatelessWidget {
  final List<Cart> cartList;
  String address;
  AddressScreen(this.cartList,this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserDataAddressNotifier>(
            create: (context) => UserDataAddressNotifier(),
          ),
          ChangeNotifierProvider<CartNotifier>(
            create: (context) => CartNotifier(),
          ),
          ChangeNotifierProvider<UserDataCardNotifier>(
            create: (context) => UserDataCardNotifier(),
          ),
        ],
        child: AddressContainer(cartList,address,''),
      ),
    );
  }
}

class _AddressContainerState extends State<AddressContainer> {
  final List<Cart> cartList;
  Future addressFuture, cardFuture, completeOrderFuture, dateFuture;
  bool isDateSelected;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<bool> isComplete = Future.value(false);
  DateTime date;
  List<String> timeSlots2 = [];
  User user;
  void addAddress() async {
    user = await FirebaseAuth.instance.currentUser;
  }
  void time() {
    FirebaseFirestore.instance.collection('Timeslots').snapshots().forEach((element) {
      for (int i = 0; i < element.docs[0]['Timeslots'].length; i++) {
        DateTime dt = DateTime.now();

        if (dt.hour > 12) {
          String st = element.docs[0]['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour - 12) &&
              element.docs[0]['Timeslots'][i].contains('PM')) {
            timeSlots2.add(element.docs[0]['Timeslots'][i]);
          }
        } else {
          String st = element.docs[0]['Timeslots'][i];
          String s = '';
          for (int i = 0; i < st.length; i++) {
            if (st[i] != ' ')
              s = s + st[i];
            else
              break;
          }

          double d = double.parse(s);
          if (d > (dt.hour) &&
              element.docs[0]['Timeslots'][i].contains('AM')) {
            timeSlots2.add(element.docs[0]['Timeslots'][i]);
          }
        }
      }
      if (timeSlots2.length == 0) {
        selectedDate = selectedDate.add(new Duration(days: 1));
        for (int i = 0;
        i < element.docs[0]['Timeslots'].length;
        i++) {
          timeSlots2.add(element.docs[0]['Timeslots'][i]);
        }
      }
      selectedTime = timeSlots2[0];
    });
//  if(timeSlots2.length>0){
//    setState(() {
//      selectedTime=timeSlots2[0];
//    });
//
//  }
    select();
  }

  void select() {
    if (timeSlots2.length > 0) {
      setState(() {
        selectedTime = timeSlots2[0];
      });
    }
  }
  int dateAddition;
  checkLastSlot() async {
    await FirebaseFirestore.instance
        .collection('Timeslots')
        .snapshots()
        .listen((event) {
      String st = event.docs[0]['LastSlot'];
      String s = '';
      for (int i = 0; i < st.length; i++) {
        if (st[i] != ' ')
          s = s + st[i];
        else
          break;
      }

      double d = double.parse(s);
      if (st.contains('PM')) d = d + 12;
      DateTime dt = DateTime.now();
      if (dt.hour > d) {
        dateAddition = dateAddition + 1;
        print('Date:${dateAddition}');
        //run
      }
    });
  }
  var dd;
  _AddressContainerState(this.cartList,address);
//  _pickTime() async {
//    DateTime t = await showDatePicker(
//      context: context,
//      initialDate: date,
//      lastDate: DateTime(2021, DateTime.now().month, 30),
//      firstDate: DateTime(2020, DateTime.now().month, DateTime.now().day + 15),
//      builder: (BuildContext context, Widget child) {
//        return Theme(
//          data: ThemeData.dark(),
//          child: child,
//        );
//      },
//    );
//    if (t != null)
//      setState(() {
//        isDateSelected = true;
//        date = t;
//      });
//
//    return date;
//  }
  var addresstype = 'House';
  var color1 = false;
  var color2 = true;
  var color3 = false;
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final phncontroller = TextEditingController();
  final buildingController = TextEditingController();
  final floorcontroller = TextEditingController();
  final flatcontroller = TextEditingController();
  final additionalcontroller = TextEditingController();
  final hnoController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();
  double minOrderPrice = 0;
  double deliveryCharge = 0;
  List<Emirates> savedemirate = [];
  List<Emirates> allemirates = [];
  String emirate2;
  List<String> emiratesname = [];
  String emirate;
  var date2;
  DateTime selectedDate;
  String selectedTime = '';

  @override
  void initState() {
    addAddress();
    areas();
    selectedDate= DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
    dateAddition=15;
    // addDishParams();
    checkLastSlot();
    time();
    totalList = cartList.map((e) => e.totalPrice);
    total = totalList.isEmpty
        ? 0.0
        : (totalList.reduce((sum, element) => double.parse(sum) + double.parse(element))+deliveryCharge).toStringAsFixed(2);
    date = DateTime.now();
    date2 = DateTime(date.year, date.month, date.day + dateAddition);
    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context, listen: false);
    addressFuture = getAddress(addressNotifier);
    date = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 15);
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context, listen: false);
    cardFuture = getCard(cardNotifier);
    isDateSelected = false;
    super.initState();
  }
  _pickTime() async {
    var today = DateTime.now();
    DateTime t = await showDatePicker(
      context: context,
      initialDate:
      DateTime(today.year, today.month, today.day + dateAddition),
      lastDate: DateTime(today.year, today.month, today.day + 21),
      firstDate: DateTime(
          today.year, DateTime.now().month, today.day + dateAddition),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (t != null)
      setState(() {
        date = t;
      });
    return date;
  }
  Future<void> _timeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _buildTimeDialog(context);
      },
    );
  }

  List<String> timeSlots = [];
  String timeSlot;

  Widget _buildTimeDialog(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    var hintTextStyle =
    textTheme.subtitle.copyWith(color: Colors.grey);
    var textFormFieldTextStyle =
    textTheme.subtitle.copyWith(color: Colors.grey);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(32),
        ),
      ),
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(
          0,
          36,
          0,
          0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        content: Container(
          height: 160,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: Center(
                  child: Text(
                    'Change delivery time',
                    style: textTheme.title.copyWith(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder(
                    stream:
                    FirebaseFirestore.instance.collection('Timeslots').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData && !snap.hasError && snap.data != null) {
                        timeSlots.clear();
                        for (int i = 0;
                        i < snap.data.docs[0]['Timeslots'].length;
                        i++) {
                          DateTime dt = DateTime.now();

                          if (dt.hour > 12) {
                            String st =
                            snap.data.docs[0]['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour - 12) &&
                                snap.data.docs[0]['Timeslots'][i]
                                    .contains('PM')) {
                              timeSlots.add(
                                  snap.data.docs[0]['Timeslots'][i]);
                            }
                          } else {
                            String st =
                            snap.data.docs[0]['Timeslots'][i];
                            String s = '';
                            for (int i = 0; i < st.length; i++) {
                              if (st[i] != ' ')
                                s = s + st[i];
                              else
                                break;
                            }

                            double d = double.parse(s);
                            if (d > (dt.hour) &&
                                snap.data.docs[0]['Timeslots'][i]
                                    .contains('AM')) {
                              timeSlots.add(
                                  snap.data.docs[0]['Timeslots'][i]);
                            }
                          }
                        }
                        if (timeSlots.length == 0) {
                          selectedDate =
                              selectedDate.add(new Duration(days: 1));
                          for (int i = 0;
                          i <
                              snap.data.docs[0]['Timeslots']
                                  .length;
                          i++) {
                            timeSlots.add(
                                snap.data.docs[0]['Timeslots'][i]);
                          }
                        }

                        if (selectedDate.difference(DateTime.now()).inDays >=
                            1) {
                          timeSlots.clear();
                          for (int i = 0;
                          i <
                              snap.data.docs[0]['Timeslots']
                                  .length;
                          i++) {
                            timeSlots.add(
                                snap.data.docs[0]['Timeslots'][i]);
                          }
                        }
                        return timeSlots.length != 0
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
                                  hint: Text('Time Slots'),
                                  value: timeSlots[0],
                                  items: timeSlots.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      selectedTime = newValue;

//                      Navigator.pop(context);
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
              ),
              Spacer(flex: 1),
              FlatButton(
                  child:Container(
                      width: 280,
                      decoration:BoxDecoration( border: Border(
                        top: BorderSide(
                          width: 1,
                          color: Colors.grey.withOpacity(0.2),),

                      ),
                      ),
                      child:Center(child:  Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: Text('Change',style:TextStyle(color:MColors.secondaryColor)),
                      ))
                  ),

                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop(true);
                  })
            ],
          ),
        ),
      ),
    );
  }
  void areas() async {
    savedemirate.clear();

    await Firestore.instance
        .collection('Emirates')
        .getDocuments()
        .then((value) {
      for (int i = 0; i < value.documents.length; i++) {
//        print(value.documents.length);

        emiratesname.add(value.documents[i]['name']);
        Emirates emi = Emirates(value.documents[i]['deliveryCharge'],
            value.documents[i]['minOrderPrice'], value.documents[i]['name']);

        savedemirate.add(emi);
      }
    });
    emirate = savedemirate[0].name;




          deliveryCharge = double.parse(savedemirate[0].deliverycharge);
          minOrderPrice = double.parse(savedemirate[0].minorderprice);
        }


  void delivery() {
    if (widget.address != '') {

          for (int i = 0; i < savedemirate.length; i++) {
            if (widget.savedEmirate == savedemirate[i].name) {
              setState(() {
                minOrderPrice = double.parse(savedemirate[i].minorderprice);
                deliveryCharge = double.parse(savedemirate[i].deliverycharge);
              });
            }

    }
  }}
  var totalList;
  var total;

  @override
  Widget build(BuildContext context) {
    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context);
    var addressList = addressNotifier.userDataAddressList;
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;
delivery();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MColors.primaryWhiteSmoke,
      appBar: primaryAppBar(
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MColors.textGrey,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Text(
          "Check out",
          style: boldFont(MColors.secondaryColor, 16.0),
        ),
        MColors.primaryWhiteSmoke,
        null,
        true,
        null,
      ),
      body: primaryContainer(
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(

                child:Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: SvgPicture.asset(
                            "assets/images/icons/Location.svg",
                            color: MColors.secondaryColor,
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              "Shipping address",
                              style: normalFont(MColors.textGrey, 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height:5.0),
                    (widget.address=='')?Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
//                            Container(
//                              width: MediaQuery.of(context).size.width * 0.31,
//                              height: MediaQuery.of(context).size.height * 0.08,
//                              child: OutlineButton(
//                                highlightedBorderColor: Color(0xFF6b3600),
//                                borderSide: BorderSide(
//                                    color: (color1)
//                                        ? Color(0xFF6b3600)
//                                        : Colors.grey),
//                                onPressed: () {
//                                  setState(() {
//                                    color1 = !color1;
//                                    color2 = false;
//                                    color3 = false;
//                                    addresstype = 'Apartment';
//                                  });
//                                },
//                                child: Padding(
//                                  padding: EdgeInsets.only(top: 8.0),
//                                  child: Column(
//                                    children: [
//                                      Image.asset('assets/images/apartment.png',
//                                          height: 25),
//                                      Text('Apartment',
//                                          style: TextStyle(
//                                              fontSize: MediaQuery.of(context)
//                                                      .size
//                                                      .height *
//                                                  0.016,
//                                              color: Colors.black,
//                                              fontWeight: FontWeight.w300))
//                                    ],
//                                  ),
//                                ),
//                                disabledBorderColor: Colors.grey,
//                                color: Color(0xFF6b3600),
//                              ),
//                            ),
//                            SizedBox(
//                                width:
//                                    MediaQuery.of(context).size.width * 0.04),
                          OutlineButton(
                            highlightedBorderColor: MColors.secondaryColor,
                            borderSide: BorderSide(
                                color: (color2)
                                    ? MColors.secondaryColor
                                    : Colors.grey),
                            onPressed: () {
                              setState(() {
                                color2 = !color2;
                                color1 = false;
                                color3 = false;
                                addresstype = 'House';
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Image.asset('assets/images/house.png',
                                      height: 25),
                                  Text('House/Apartment ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w300))
                                ],
                              ),
                            ),
                            disabledBorderColor: Colors.grey,
                            color: MColors.secondaryColor,
                          ),
                          SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.04),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: OutlineButton(
                              highlightedBorderColor: MColors.secondaryColor,
                              borderSide: BorderSide(
                                  color: (color3)
                                      ? MColors.secondaryColor
                                      : Colors.grey),
                              onPressed: () {
                                setState(() {
                                  color3 = !color3;
                                  color2 = false;
                                  color1 = false;
                                  addresstype = 'Office';
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.asset('assets/images/office.png',
                                        height: 25),
                                    Text('Office',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300))
                                  ],
                                ),
                              ),
                              disabledBorderColor: Colors.grey,
                              color: MColors.secondaryColor,
                            ),
                          )
                        ],
                      ),
                    ):Container(child:Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.address),
                    )))
                  ],
                )
              ),
              (addresstype == 'House')
                  ? (widget.address=='')?Form(
                key: _formkey,
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Emirates')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snap) {
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data != null) {

                            allemirates.clear();
                            emiratesname.clear();
                            for (int i = 0;
                            i < snap.data.docs.length;
                            i++) {
//                                              print(snap.data.documents.length);
                              emirate2 = snap.data.docs[0]
                              ['name'];
                              emiratesname.add(snap
                                  .data.docs[i]['name']);
                              Emirates emi = Emirates(
                                  snap.data.docs[i]
                                  ['deliveryCharge'],
                                  snap.data.docs[i]
                                  ['minOrderPrice'],
                                  snap.data.docs[i]
                                  ['name']);

                              allemirates.add(emi);
                            }

                            return allemirates.length != 0
                                ? Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(
                                      context)
                                      .size
                                      .width *
                                      0.9,
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: DropdownButtonHideUnderline(
                                      child:
                                      new DropdownButtonFormField<
                                          String>(
                                        validator: (value) =>
                                        value == null
                                            ? 'field required'
                                            : null,
                                        hint: Text(
                                            'Emirates'),
                                        value:
                                        emirate,
                                        items: emiratesname
                                            .map((String
                                        value) {
                                          return new DropdownMenuItem<
                                              String>(
                                            value: value,
                                            child: new Text(
                                                value),
                                          );
                                        }).toList(),
                                        onChanged: (String
                                        newValue) {
                                          setState(() {
                                            emirate =
                                                newValue;
                                            emirate2 =
                                                newValue;
                                            // print(emirate);
                                            for (int i = 0;
                                            i < allemirates.length;
                                            i++) {
                                              if (allemirates[i].name ==
                                                  newValue) {
                                                minOrderPrice =
                                                   double.parse(allemirates[i].minorderprice);
                                                deliveryCharge=double.parse(allemirates[i].deliverycharge);
                                                print(allemirates[i]
                                                    .minorderprice);
                                                print(allemirates[i].name);
                                              }
                                            }


//                      Navigator.pop(context);
                                          });
                                        },
                                      ),
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
//                                    StreamBuilder(
//                                        stream: Firestore.instance
//                                            .collection('EmiratesArea')
//                                            .where('Emirate',
//                                                isEqualTo: emirate)
//                                            .snapshots(),
//                                        builder: (BuildContext context,
//                                            AsyncSnapshot<QuerySnapshot> snap) {
//
//                                          if (snap.hasData &&
//                                              !snap.hasError &&
//                                              snap.data != null) {
//                                            length2=0;
////                                            final ProgressDialog pr =  ProgressDialog(context);
////                                            pr.style(
////                                                message: 'Please wait ..',
////                                                backgroundColor: Colors.white,
////                                                progressWidget: GFLoader(
////                                                  type: GFLoaderType.ios,
////                                                ),
////                                                elevation: 10.0,
////                                                insetAnimCurve: Curves.easeInOut,
////                                                progress: 0.0,
////                                                maxProgress: 100.0,
////                                                progressTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
////                                                messageTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
////                                            pr.show();
////                                            final ProgressDialog pr =  ProgressDialog(context);
////                                            pr.style(
////                                                message: 'Please wait ..',
////                                                backgroundColor: Colors.white,
////                                                progressWidget: GFLoader(
////                                                  type: GFLoaderType.ios,
////                                                ),
////                                                elevation: 10.0,
////                                                insetAnimCurve: Curves.easeInOut,
////                                                progress: 0.0,
////                                                maxProgress: 100.0,
////                                                progressTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
////                                                messageTextStyle: TextStyle(
////                                                    color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
////                                            pr.show();
//                                            allareas.clear();
//                                            areaname.clear();
//                                            index=0;
////                                            length2=0;
////                                             print('Streambuilder');
//                                            for (int i = 0;
//                                                i < snap.data.documents.length;
//                                                i++) {
//                                              length2=snap.data.documents.length;
//                                              if(i==0){
//                                                areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                ['Emirate'],
//                                                    snap.data.documents[i]
//                                                    ['deliveryCharge'],
//                                                    snap.data.documents[i]
//                                                    ['minOrderPrice'],
//                                                    '${snap.data.documents[i]['name']}',
//                                                    snap.data.documents[i]
//                                                    ['zone']);
//                                                allareas.add(emi2);
//                                              }
////                                              print(snap.data.documents.length);
//                                              for(int j=i+1;j<snap.data.documents.length;j++){
//                                                if(snap.data.documents[i]['name']==snap.data.documents[j]['name']){
//                                                  areaname.add(' ${snap.data.documents[j]['name']}');
//                                                  // print('5555555555555${snap.data.documents[j]['name']}');
//                                                  // print('Minorder${  snap.data.documents[j]
//                                                  // ['minOrderPrice']}');
//                                                  EmiratesArea emi2=EmiratesArea( snap.data.documents[j]
//                                                  ['Emirate'],
//                                                      snap.data.documents[j]
//                                                      ['deliveryCharge'],
//                                                      snap.data.documents[j]
//                                                      ['minOrderPrice'],
//                                                      ' ${snap.data.documents[j]['name']}',
//                                                      snap.data.documents[j]
//                                                      ['zone']);
//                                                  allareas.add(emi2);
//                                                  // print('length:${areaname.length}');
//                                                  index=j;
//                                                  // print('Index:${index}');
//
//
//                                                }
//
//                                              }
//
//                                               if(index!=i){
//                                                 areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                 EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                 ['Emirate'],
//                                                     snap.data.documents[i]
//                                                     ['deliveryCharge'],
//                                                     snap.data.documents[i]
//                                                     ['minOrderPrice'],
//                                                     '${snap.data.documents[i]['name']}',
//                                                     snap.data.documents[i]
//                                                     ['zone']);
//                                                 allareas.add(emi2);
//                                               }
//                                               }
////                                            if(allareas.length==length2){
////                                              pr.hide();
////                                            }
//
//
//
//                                            areaname.add('Others');

//                                            return areaname.length != 0

//                                                : Container();
//                                          } else {
//                                            return Container();
//                                          }
//                                        }),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Name*'),
//                                      controller: nameController,
//                                    ),
//                                  ),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                                  BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Phone no*'),
//                                      controller: phncontroller,
//                                    ),
//                                  ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '')
                            return 'Required field';
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: MColors.secondaryColor)),
                            hintText:
                            'Building name/no.,floor,apartment or villa no.*'),
                        controller: buildingController,
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
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: MColors.secondaryColor)),
                            hintText: 'Street name*'),
                        controller: flatcontroller,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
//                                        validator: (value){if(value==null||value=='')return 'Required field';return null;},

                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: MColors.secondaryColor)),
                            hintText:
                            'Additional Directions/Nearest Landmark'),
                        maxLines: 2,
                        controller: additionalcontroller,
                      ),
                    ),
                  ],
                ),
              ):Container()
                  : (widget.address=='')?Form(
                key: _formkey2,
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: Firestore.instance
                            .collection('Emirates')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snap) {
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data != null) {
                            allemirates.clear();
                            emiratesname.clear();
                            for (int i = 0;
                            i < snap.data.documents.length;
                            i++) {
                              // print(snap.data.documents.length);
                              emirate2 = snap.data.documents[0]
                              ['name'];
                              emiratesname.add(snap
                                  .data.documents[i]['name']);
                              Emirates emi = Emirates(
                                  snap.data.documents[i]
                                  ['deliveryCharge'],
                                  snap.data.documents[i]
                                  ['minOrderPrice'],
                                  snap.data.documents[i]
                                  ['name']);
                              allemirates.add(emi);
                            }
                            return allemirates.length != 0
                                ? Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(
                                      context)
                                      .size
                                      .width *
                                      0.9,
                                  child:
                                  DropdownButtonHideUnderline(
                                    child:
                                    new DropdownButtonFormField<
                                        String>(
                                      validator: (value) =>
                                      value == null
                                          ? 'field required'
                                          : null,
                                      hint: Text(
                                          'Emirates'),
                                      value:
                                      emirate,
                                      items: emiratesname
                                          .map((String
                                      value) {
                                        return new DropdownMenuItem<
                                            String>(
                                          value: value,
                                          child: new Text(
                                              value),
                                        );
                                      }).toList(),
                                      onChanged: (String
                                      newValue) {
                                        setState(() {
                                          emirate =
                                              newValue;
                                          emirate2 =
                                              newValue;
                                          // print(emirate);
                                          for (int i = 0;
                                          i < allemirates.length;
                                          i++) {
                                            if (allemirates[i].name ==
                                                newValue) {
                                              minOrderPrice =
                                                  double.parse(allemirates[i].minorderprice);
                                              deliveryCharge=double.parse(allemirates[i].deliverycharge);
                                              print(allemirates[i]
                                                  .minorderprice);
                                              print(allemirates[i].name);
                                            }
                                          }


//                      Navigator.pop(context);
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
//                                    StreamBuilder(
//                                        stream: Firestore.instance
//                                            .collection('EmiratesArea')
//                                            .where('Emirate',
//                                                isEqualTo: emirate)
//                                            .snapshots(),
//                                        builder: (BuildContext context,
//                                            AsyncSnapshot<QuerySnapshot> snap) {
//                                          if (snap.hasData &&
//                                              !snap.hasError &&
//                                              snap.data != null) {
//                                            allareas.clear();
//                                            areaname.clear();
//                                            index=0;
//                                            for (int i = 0;
//                                            i < snap.data.documents.length;
//                                            i++) {
//                                              // print(snap.data.documents.length);
//                                              for(int j=i+1;j<snap.data.documents.length;j++){
//                                                if(snap.data.documents[i]['name']==snap.data.documents[j]['name']){
//                                                  areaname.add(' ${snap.data.documents[j]['name']}');
//                                                  // print('5555555555555${snap.data.documents[j]['name']}');
//                                                  // print('Minorder${  snap.data.documents[j]
//                                                  // ['minOrderPrice']}');
//                                                  EmiratesArea emi2=EmiratesArea( snap.data.documents[j]
//                                                  ['Emirate'],
//                                                      snap.data.documents[j]
//                                                      ['deliveryCharge'],
//                                                      snap.data.documents[j]
//                                                      ['minOrderPrice'],
//                                                      ' ${snap.data.documents[j]['name']}',
//                                                      snap.data.documents[j]
//                                                      ['zone']);
//                                                  allareas.add(emi2);
//                                                  // print('length:${areaname.length}');
//                                                  index=j;
//                                                  // print('Index:${index}');
//
//
//                                                }
//
//                                              }
//                                              if(i!=index){
//                                                areaname.add('${snap.data.documents[i]['name']}');
////                                                print('5555555555555${snap.data.documents[i]['name']}');
//                                                EmiratesArea emi2=EmiratesArea( snap.data.documents[i]
//                                                ['Emirate'],
//                                                    snap.data.documents[i]
//                                                    ['deliveryCharge'],
//                                                    snap.data.documents[i]
//                                                    ['minOrderPrice'],
//                                                    '${snap.data.documents[i]['name']}',
//                                                    snap.data.documents[i]
//                                                    ['zone']);
//                                                allareas.add(emi2);
//                                              }
//
//                                            }
//                                            areaname.add('Others');

//                                                : Container();
//                                          } else {
//                                            return Container();
//                                          }
//                                        }),
//                                  Padding(
//                                  padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Name*'),
//                                      controller: nameController,
//                                    ),
//                                  ),
//                                  Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: TextFormField(
//                                      decoration: InputDecoration(
//                                          border: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          enabledBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Colors.grey)),
//                                          focusedBorder: OutlineInputBorder(
//                                              borderRadius:
//                                              BorderRadius.circular(2),
//                                              borderSide: BorderSide(
//                                                  color: Color(0xFF6b3600))),
//                                          hintText: 'Phone no*'),
//                                      controller: phncontroller,
//                                    ),
//                                  ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value == '')
                            return 'Required field';
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: MColors.secondaryColor)),
                            hintText:
                            'Building name/no.,floor*'),
                        controller: buildingController,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
//                                        validator: (value){if(value==null||value=='')return 'Required field';return null;},
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(2),
                                borderSide: BorderSide(
                                    color: MColors.secondaryColor)),
                            hintText:
                            'Additional Directions/Nearest Landmark'),
                        maxLines: 2,
                        controller: additionalcontroller,
                      ),
                    ),
                  ],
                ),
              ):Container(),

              //Address container
//              Container(
//                child: FutureBuilder(
//                  future: addressFuture,
//                  builder: (c, s) {
//                    switch (s.connectionState) {
//                      case ConnectionState.active:
//                        return Container(
//                          height: MediaQuery.of(context).size.height / 7,
//                          child: Center(
//                              child: progressIndicator(MColors.secondaryColor)),
//                        );
//                        break;
//                      case ConnectionState.done:
//                        return addressList.isEmpty
//                            ? noSavedAddress()
//                            : savedAddressWidget();
//                        break;
//                      case ConnectionState.waiting:
//                        return Container(
//                          height: MediaQuery.of(context).size.height / 7,
//                          child: Center(
//                              child: progressIndicator(MColors.secondaryColor)),
//                        );
//                        break;
//                      default:
//                        return Container(
//                          height: MediaQuery.of(context).size.height / 7,
//                          child: Center(
//                              child: progressIndicator(MColors.secondaryColor)),
//                        );
//                    }
//                  },
//                ),
//              ),

              SizedBox(
                height: 20.0,
              ),
              Center(
                child: InkWell(
                onTap:(){
                  Navigator.push(context,MaterialPageRoute(builder:(context)=>MyAddresses2(user.email)));
                },
                  child: Container(
                   decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color:MColors.secondaryColor),
                    height:MediaQuery.of(context).size.height*0.05,
                    width:MediaQuery.of(context).size.width*0.85,
                    child:Center(child: Text('Saved Addresses',style:TextStyle(fontFamily: 'Poppins',color:Colors.white,fontSize: 13)))
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              //Cart summary container
              Container(
                child: cartSummary(cartList),
              ),

              SizedBox(
                height: 20.0,
              ),

              //Payment Container
              Container(
                child: FutureBuilder(
                  future: cardFuture,
                  builder: (c, s) {
                    switch (s.connectionState) {
                      case ConnectionState.active:
                        return Container(
                          height: MediaQuery.of(context).size.height / 7,
                          child: Center(
                              child: progressIndicator(MColors.secondaryColor)),
                        );
                        break;
                      case ConnectionState.done:
                        return cardList.isEmpty
                            ? noPaymentMethod()
                            : savedPaymentMethod();
                        break;
                      case ConnectionState.waiting:
                        return Container(
                          height: MediaQuery.of(context).size.height / 7,
                          child: Center(
                              child: progressIndicator(MColors.secondaryColor)),
                        );
                        break;
                      default:
                        return Container(
                          height: MediaQuery.of(context).size.height / 7,
                          child: Center(
                              child: progressIndicator(MColors.secondaryColor)),
                        );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 20.0,
              ),

              //Payment Container
              Container(
                child:
                     noDateSelected(),
              ),
              SizedBox(
                height: 20.0,
              ),
              (addresstype=='House'&&widget.address=='')?Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Place order",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if (!_formkey.currentState.validate() && cardList.isEmpty) {
                      showSimpleSnack(
                        'Please complete shipping and card details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime):addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}',DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced('Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}'),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ):(widget.address=='')?Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Place order",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if (!_formkey2.currentState.validate() && cardList.isEmpty) {
                      showSimpleSnack(
                        'Please complete shipping and card details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime):addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}',DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced('Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}'),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ):Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Place order",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if ( cardList.isEmpty) {
                      showSimpleSnack(
                        'Please complete  card details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,widget.address,DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime):addCartToOrders(cartList,orderID,widget.address,DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Online',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced(widget.address),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ),
              (addresstype=='House'&&widget.address=='')?Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Card on Delivery",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if (!_formkey.currentState.validate() ) {
                      showSimpleSnack(
                        'Please complete shipping  details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime,):addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}',DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced(addresstype=='House'?'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}':'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}'),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ):(widget.address=='')?Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Card on Delivery",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if (!_formkey2.currentState.validate() ) {
                      showSimpleSnack(
                        'Please complete shipping  details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime):addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}',DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced('Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}'),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ):Container(
                color: MColors.primaryWhite,
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
                child: primaryButtonPurple(
                  Text(
                    "Card on Delivery",
                    style: boldFont(MColors.primaryWhite, 16.0),
                  ),
                      () async {
                    final uEmail = await AuthService().getCurrentEmail();
                    if(uEmail==null){
                      print('Logged Out');
                      showSimpleSnack(
                        "Please login First",
                        Icons.error_outline,
                        Colors.red,
                        _scaffoldKey,);
                    }
                    else if (minOrderPrice>double.parse(total) ) {
                      showSimpleSnack(
                        'Please complete shipping  details',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }
                    else if(minOrderPrice>(double.parse(total)+deliveryCharge)){
                      showSimpleSnack(
                        'The minimum order price is ${minOrderPrice.toString()}',
                        Icons.error_outline,
                        Colors.amber,
                        _scaffoldKey,
                      );
                    }else {
                      completeOrderFuture = _showLoadingDialog();
                      var tt = selectedTime.split(' ').join().toLowerCase();
                      String s = '';
                      for (int i = 0; i < selectedTime.length; i++) {
                        if (selectedTime[i] != ' ')
                          s = s + selectedTime[i];
                        else
                          break;
                      }

                      dd = int.parse(s);
                      if (selectedTime.contains('PM')) dd = dd + 12;
                      //Adding cartItems to orders
                      //Generating unique orderID
                      var uuid = Uuid();
                      var orderID = uuid.v4();
                      completeOrderFuture =
                      addresstype=='House'?addCartToOrders(cartList,orderID,widget.address,DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime):addCartToOrders(cartList,orderID,widget.address,DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day, dd),'Card on Delivery',selectedTime);

                      //Clearing the cart and going home
                      completeOrderFuture.then((value) {
                        Navigator.of(context, rootNavigator: true).pop();
                        clearCartAfterPurchase();
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (_) => OrderPlaced(widget.address),
                          ),
                              (Route<dynamic> route) => false,
                        );
                      }).catchError((e) {
                        print(e);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
//      bottomNavigationBar: Container(
//        color: MColors.primaryWhite,
//        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
//        child: primaryButtonPurple(
//          Text(
//            "Place order",
//            style: boldFont(MColors.primaryWhite, 16.0),
//          ),
//          () async {
//            final uEmail = await AuthService().getCurrentEmail();
//            if(uEmail==null){
//              print('Logged Out');
//    showSimpleSnack(
//      "Please login First",
//      Icons.error_outline,
//      Colors.red,
//      _scaffoldKey,);
//            }
//            else if (_formkey.currentState.validate() && cardList.isEmpty) {
//              showSimpleSnack(
//                'Please complete shipping and card details',
//                Icons.error_outline,
//                Colors.amber,
//                _scaffoldKey,
//              );
//            } else {
//              completeOrderFuture = _showLoadingDialog();
//              var tt = selectedTime.split(' ').join().toLowerCase();
//              String s = '';
//              for (int i = 0; i < selectedTime.length; i++) {
//                if (selectedTime[i] != ' ')
//                  s = s + selectedTime[i];
//                else
//                  break;
//              }
//
//              dd = int.parse(s);
//              if (selectedTime.contains('PM')) dd = dd + 12;
//              //Adding cartItems to orders
//              //Generating unique orderID
//              var uuid = Uuid();
//              var orderID = uuid.v4();
//              completeOrderFuture =
//              addresstype=='House'?addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}',DateTime(selectedDate.year, selectedDate.month, selectedDate.day, dd),selectedTime,'Online'):addCartToOrders(cartList,orderID,'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}',DateTime(
//                  selectedDate.year, selectedDate.month, selectedDate.day, dd),selectedTime,'Online');
//
//              //Clearing the cart and going home
//              completeOrderFuture.then((value) {
//                Navigator.of(context, rootNavigator: true).pop();
//                clearCartAfterPurchase();
//                Navigator.of(context).pushAndRemoveUntil(
//                  CupertinoPageRoute(
//                    builder: (_) => OrderPlaced(addresstype=='House'?'Emirate:${emirate},${buildingController.text},Street:${flatcontroller.text},Additional Directions :${additionalcontroller.text}':'Emirate:${emirate},${buildingController.text},Additional Directions:${additionalcontroller.text}'),
//                  ),
//                  (Route<dynamic> route) => false,
//                );
//              }).catchError((e) {
//                print(e);
//              });
//            }
//          },
//        ),
//      ),
    );
  }

  Widget savedAddressWidget() {
    UserDataAddressNotifier addressNotifier =
        Provider.of<UserDataAddressNotifier>(context);
    var addressList = addressNotifier.userDataAddressList;
    var address = addressList.first;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Location.svg",
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Shipping address",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 60.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () async {
                    UserDataAddressNotifier addressNotifier =
                        Provider.of<UserDataAddressNotifier>(context,
                            listen: false);
                    var navigationResult = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => Address(address, addressList),
                      ),
                    );
                    if (navigationResult == true) {
                      setState(() {
                        getAddress(addressNotifier);
                      });
                      showSimpleSnack(
                        "Address has been updated",
                        Icons.check_circle_outline,
                        Colors.green,
                        _scaffoldKey,
                      );
                    }
                  },
                  child: Text(
                    "Change",
                    style: boldFont(MColors.secondaryColor, 14.0),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    address.fullLegalName,
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  child: Text(
                    address.addressNumber + ", " + address.addressLocation,
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noSavedAddress() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Location.svg",
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(width: 5.0),
              Expanded(
                child: Container(
                  child: Text(
                    "Shipping address",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(
              left: 25.0,
            ),
            child: Text(
              "No shipping address added to this  account",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          primaryButtonWhiteSmoke(
            Text("Add a shipping address",
                style: boldFont(MColors.secondaryColor, 16.0)),
            () async {
              UserDataAddressNotifier addressNotifier =
                  Provider.of<UserDataAddressNotifier>(context, listen: false);
              var navigationResult = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => Address(null, null),
                ),
              );
              if (navigationResult == true) {
                setState(() {
                  getAddress(addressNotifier);
                });
                showSimpleSnack(
                  "Address has been updated",
                  Icons.check_circle_outline,
                  Colors.green,
                  _scaffoldKey,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget cartSummary(cartList) {
    var totalList = cartList.map((e) => e.totalPrice);
    var total = totalList.isEmpty
        ? 0.0
        : (totalList.reduce((sum, element) => sum + element)+deliveryCharge).toStringAsFixed(2);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Bag.svg",
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Bag summary",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 50.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () {
                    _showModalSheet(cartList, total);
                  },
                  child: Text(
                    "See all",
                    style: boldFont(MColors.secondaryColor, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: cartList.length < 7 ? cartList.length : 7,
              shrinkWrap: true,
              itemBuilder: (context, i) {
                var cartItem = cartList[i];

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(cartItem.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: normalFont(MColors.textGrey, 12.0)),
                      ),
                      Spacer(),
                      Container(
                      width: MediaQuery.of(context).size.width / 5.5,

                        child: Text(

                            "AED " + cartItem.totalPrice.toStringAsFixed(2),
                            maxLines:1,
                            overflow:TextOverflow.ellipsis,
                            style: boldFont(MColors.textDark, 12.0)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Text("Delivery Charge", style: boldFont(MColors.secondaryColor, 16.0)),
                Spacer(),
                Container(
    width: MediaQuery.of(context).size.width / 4,
                  child: Text("AED " + deliveryCharge.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldFont(MColors.secondaryColor, 14.0)),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            padding: EdgeInsets.only(left: 25),
            child: Row(
              children: <Widget>[
                Text("Total", style: boldFont(MColors.secondaryColor, 14.0)),
                Spacer(),
                Container(
                    width: MediaQuery.of(context).size.width / 4,
                  child: Text("AED " + total,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldFont(MColors.secondaryColor, 14.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget savedPaymentMethod() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;
    var card = cardList.first;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Wallet.svg",
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Payment method",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
              Container(
                width: 60.0,
                height: 25.0,
                child: RawMaterialButton(
                  onPressed: () async {
                    UserDataCardNotifier cardNotifier =
                        Provider.of<UserDataCardNotifier>(context,
                            listen: false);

                    var navigationResult = await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => AddNewCard(card, cardList),
                      ),
                    );
                    if (navigationResult == true) {
                      setState(() {
                        getCard(cardNotifier);
                      });
                      showSimpleSnack(
                        "Card has been updated",
                        Icons.check_circle_outline,
                        Colors.green,
                        _scaffoldKey,
                      );
                    }
                  },
                  child: Text("Change",
                      style: boldFont(MColors.secondaryColor, 14.0)),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    card.cardHolder,
                    style: boldFont(MColors.textDark, 16.0),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "•••• •••• •••• " +
                            card.cardNumber
                                .substring(card.cardNumber.length - 4),
                        style: normalFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    Spacer(),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/mastercard.svg",
                        height: 30.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noPaymentMethod() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: SvgPicture.asset(
                  "assets/images/icons/Wallet.svg",
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Payment method",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "No payment card added to this account",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          primaryButtonWhiteSmoke(
            Text("Add a payment card",
                style: boldFont(MColors.secondaryColor, 16.0)),
            () async {
              var navigationResult = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => AddNewCard(null, cardList),
                ),
              );
              if (navigationResult == true) {
                setState(() {
                  getCard(cardNotifier);
                });
                showSimpleSnack(
                  "Card has been updated",
                  Icons.check_circle_outline,
                  Colors.green,
                  _scaffoldKey,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget dateSelected() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.date_range_rounded,
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Delivery Date",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Your product will be delivered on",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          primaryButtonWhiteSmoke(
              Text(
                  '${date.day.toString()}-${date.month.toString()}-${date.year.toString()}',
                  style: boldFont(MColors.secondaryColor, 16.0)),
              _pickTime),
          SizedBox(height: 10.0),
          Text(
            'Selected products can only be delivered after 15 days',
            style: boldFont(MColors.textDark, 16.0),
          ),
        ],
      ),
    );
  }

  Widget noDateSelected() {
    UserDataCardNotifier cardNotifier =
        Provider.of<UserDataCardNotifier>(context);
    var cardList = cardNotifier.userDataCardList;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: MColors.primaryWhite,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.date_range_rounded,
                  color: MColors.secondaryColor,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    "Delivery Date",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.only(left: 25.0),
            child: Text(
              "Please select a date for delivery",
              style: normalFont(MColors.textGrey, 16.0),
            ),
          ),
          SizedBox(height: 10.0),
          Card(

            elevation: 5,
            child: Container(
              height:
              MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: MColors.secondaryColor),
                  borderRadius:
                  BorderRadius.all(Radius.zero)),
              child: Row(
                children: [
                  Text('    Next Delivery: '),
                  Icon(
                    Icons.delivery_dining,
                    color: MColors.secondaryColor,
                  ),
                  SizedBox(width: 5),
                  InkWell(
                      onTap: () {
                        _pickTime().then((value) {
                          setState(() {
                            selectedDate = value;
                          });
                        });
                      },
                      child: selectedDate != null
                          ? Text(
                        '${selectedDate.day.toString()}/${selectedDate.month.toString()}/${selectedDate.year.toString()} ',
                        style: TextStyle(
                            color: Color(0xFF6b3600)),
                      )
                          : Text(
                        '${date.day.toString()}/${date.month.toString()}/${selectedDate.year.toString()} ',
                        style: TextStyle(
                            color: Color(0xFF6b3600)),
                      )),
                  Text(' at '),
                  Icon(
                    Icons.timer,
                    size: 19,
                    color: MColors.secondaryColor,
                  ),
                  SizedBox(width: 5),
                  InkWell(
                      onTap: () {
                        _timeDialog(context);
                      },
                      child: Text(
                        '$selectedTime ',
                        style: TextStyle(
                            color: Color(0xFF6b3600)),
                      )),
//                        InkWell(
//                            onTap: () {
//                              _locationDialog(context);
//                            },
//                            child: Icon(Icons.edit))
                ],
              ),
            ),
          ),
//          primaryButtonWhiteSmoke(
//              Text("Delivery Date",
//                  style: boldFont(MColors.secondaryColor, 16.0)),
//              _pickTime),
          SizedBox(height: 10.0),
          Text(
            'Selected products can only be delivered after 15 days',
            style: boldFont(MColors.textDark, 12.0),
          ),
        ],
      ),
    );
  }

  //Bag summary
  void _showModalSheet(cartList, total) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 1.9,
          margin: EdgeInsets.only(
            bottom: 10.0,
            left: 10.0,
            right: 10.0,
            top: 5.0,
          ),
          padding: EdgeInsets.only(
            bottom: 15.0,
            left: 15.0,
            right: 15.0,
            top: 10.0,
          ),
          decoration: BoxDecoration(
            color: MColors.primaryWhiteSmoke,
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                modalBarWidget(),
                SizedBox(height: 10.0),
                Row(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Bag summary",
                        style: boldFont(MColors.textGrey, 16.0),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Container(
                      child: SvgPicture.asset(
                        "assets/images/icons/Bag.svg",
                        color: MColors.secondaryColor,
                      ),
                    ),
                    Spacer(),
                    Text(

                      "AED " + (double.parse(total)+deliveryCharge).toStringAsFixed(2),
                      style: boldFont(MColors.secondaryColor, 14.0),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Container(
                  child: ListView.builder(
                    itemCount: cartList.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      var cartItem = cartList[i];

                      return Container(
                        decoration: BoxDecoration(
                          color: MColors.primaryWhite,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.all(7.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 30.0,
                              height: 40.0,
                              child: FadeInImage.assetNetwork(
                                image: cartItem.productImage,
                                fit: BoxFit.fill,
                                height: MediaQuery.of(context).size.height,
                                placeholder: "assets/images/placeholder.jpg",
                                placeholderScale:
                                    MediaQuery.of(context).size.height / 2,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Text(
                                cartItem.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: normalFont(MColors.textGrey, 12.0),
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: MColors.dashPurple,
                                borderRadius: new BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                "X${cartItem.quantity}",
                                style: normalFont(MColors.textGrey, 12.0),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Spacer(),
                            Container(
                              child: Text(
                                "AED " + cartItem.totalPrice.toStringAsFixed(2),
                                style: boldFont(MColors.textDark, 12.0),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height:5.0),
                Container(

                  child: Row(
                    children: <Widget>[
                      Text("Delivery Charge", style: boldFont(MColors.secondaryColor, 16.0)),
                      Spacer(),
                      Text("AED " + deliveryCharge.toString(),
                          style: boldFont(MColors.secondaryColor, 16.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _showLoadingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return;
          },
          child: AlertDialog(
            backgroundColor: MColors.primaryWhiteSmoke,
            title: Text(
              "Please wait..",
              style: boldFont(MColors.secondaryColor, 14.0),
            ),
            content: Container(
              height: 20.0,
              child: Row(
                children: <Widget>[
                  Text(
                    " We are placing your order.",
                    style: normalFont(MColors.textGrey, 14.0),
                  ),
                  Spacer(),
                  progressIndicator(MColors.secondaryColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
