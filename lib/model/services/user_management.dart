import 'dart:convert';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:wildberries/credentials.dart';
import 'package:wildberries/main.dart';
import 'package:wildberries/model/data/userData.dart';
import 'package:wildberries/model/notifiers/userData_notifier.dart';
import 'package:wildberries/model/services/auth_service.dart';
import 'package:http/http.dart' as http;

String fetchUserAPIUrl = 'https://wild-grocery.herokuapp.com/api/user/';
//Storing new user data
refreshUserProfile(UserDataProfile currentUser,
    {String subscriptionID, String subscriptionDiscount}) async {
  if (subscriptionID != null) {
    var url = Uri.parse(
        'https://wild-grocery.herokuapp.com/api/user/${currentUser.id}');
    var response = await http
        .get(url, headers: {"Authorization": "Bearer ${currentUser.token}"});
    var data = json.decode(response.body);
    if (data['_id'] != null) {
      UserDataProfile refreshedUser = UserDataProfile(
        firstName: data['firstName'],
        lastName: data['lastName'],
        phone: data['phone'],
        email: data['email'],
        id: data['_id'],
        imgURL: data['imgURL'],
        role: data['role'],
        coins: data['coins'],
        copounsused: data['copounsused'],
        subscription: data['subscription'],
        subscriptionTime: data['subscriptionTime'],
        subscriptionDiscount: subscriptionDiscount,
        subscriptionID: subscriptionID,
        token: currentUser.token,
      );
      print(refreshedUser.toMap());
      preferences
          .setString('user', json.encode(refreshedUser.toMap()))
          // .then((value) => print('Saved ${json.encode(refreshedUser.toMap())}'))
          .catchError((e) => print(e));
      List<UserDataAddress> addresses = [];

      for (var v in data['address'].toList()) {
        await addresses.add(UserDataAddress.fromMap(v));
      }
      final String encodedData = UserDataAddress.encode(addresses);

      preferences.setString('addresses', encodedData);
    }
    // setState(() {
    //   print(data['messages']['errorMessage']);
    //   _isOTPSent = true;
    // });
  } else {
    var url = Uri.parse(
        'https://wild-grocery.herokuapp.com/api/user/${currentUser.id}');
    var response = await http
        .get(url, headers: {"Authorization": "Bearer ${currentUser.token}"});
    var data = json.decode(response.body);
    if (data['_id'] != null) {
      UserDataProfile refreshedUser = UserDataProfile(
        firstName: data['firstName'],
        lastName: data['lastName'],
        phone: data['phone'],
        email: data['email'],
        id: data['_id'],
        imgURL: data['imgURL'],
        role: data['role'],
        coins: data['coins'],
        copounsused: data['copounsused'],
        subscription: data['subscription'],
        subscriptionTime: data['subscriptionTime'],
        token: currentUser.token,
      );

      preferences
          .setString('user', json.encode(refreshedUser.toMap()))
          // .then((value) => print('Saved ${json.encode(refreshedUser.toMap())}'))
          .catchError((e) => print(e));
      List<UserDataAddress> addresses = [];

      for (var v in data['address'].toList()) {
        await addresses.add(UserDataAddress.fromMap(v));
      }
      final String encodedData = UserDataAddress.encode(addresses);

      preferences.setString('addresses', encodedData);
    }
    // setState(() {
    //   print(data['messages']['errorMessage']);
    //   _isOTPSent = true;
    // });
  }
}

//Getting User profile
getProfile(UserDataProfileNotifier profileNotifier) async {
  UserDataProfile _userDataProfile;

  //Getting Current cart items
  final Preference<String> musicsString =
      await preferences.getString('user', defaultValue: '');
  musicsString.listen((value) {
    if (value != '')
      _userDataProfile = UserDataProfile.fromMap(json.decode(value));
  });
  profileNotifier.userDataProfile = _userDataProfile;
  // print(profileNotifier.userDataProfile);
}

//Updating User profile
updateProfile(_name, _phone) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // CollectionReference profileRef =
  //     db.collection("userData").doc(uEmail).collection("profile");
  // await profileRef.doc(uEmail).update(
  //   {'name': _name, 'phone': _phone},
  // );
}

Future updateProfilePhoto(file) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // //Input the link to your own firebase storage bucket
  // final FirebaseStorage _storage =
  //     FirebaseStorage(storageBucket: FIREBASE_STORAGE_BUCKET);
  //
  // String filePath = 'userImages/$uEmail.png';
  //
  // StorageUploadTask uploadTask = _storage.ref().child(filePath).putFile(file);
  //
  // StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  //
  // var ref = storageTaskSnapshot.ref;
  // var profilePhoto = await ref.getDownloadURL();
  //
  // print(profilePhoto);
  //
  // CollectionReference profileRef =
  //     db.collection("userData").doc(uEmail).collection("profile");
  // await profileRef.doc(uEmail).update(
  //   {
  //     'profilePhoto': profilePhoto,
  //   },
  // );
}

// Adding new address
storeAddress(
  fullLegalName,
  addressLocation,
  addressNumber,
) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // await db
  //     .collection("userData")
  //     .doc(uEmail)
  //     .collection("address")
  //     .doc(uEmail)
  //     .set({
  //   'fullLegalName': fullLegalName,
  //   'addressLocation': addressLocation,
  //   'addressNumber': addressNumber,
  // }).catchError((e) {
  //   print(e);
  // });
}

//get users address
getAddress(UserDataAddressNotifier addressNotifier) async {
  List<UserDataAddress> _address;

  //Getting Current cart items
  final Preference<String> musicsString =
      await preferences.getString('addresses', defaultValue: '');
  musicsString.listen((value) {
    if (value != '') {
      _address = UserDataAddress.decode(value);
    }
  });

  addressNotifier.userDataAddressList = await _address;
  // print(addressNotifier.userDataAddressList);
}

//Updating new address
updateAddress(
  fullLegalName,
  addressLocation,
  addressNumber,
) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // CollectionReference addressRef =
  //     db.collection("userData").doc(uEmail).collection("address");
  // await addressRef.doc(uEmail).update(
  //   {
  //     'fullLegalName': fullLegalName,
  //     'addressLocation': addressLocation,
  //     'addressNumber': addressNumber,
  //   },
  // );
}

//Adding new card
storeNewCard(
  cardHolder,
  cardNumber,
  validThrough,
  securityCode,
) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // await db
  //     .collection("userData")
  //     .doc(uEmail)
  //     .collection("card")
  //     .doc(uEmail)
  //     .set({
  //   'cardHolder': cardHolder,
  //   'cardNumber': cardNumber,
  //   'validThrough': validThrough,
  //   'securityCode': securityCode,
  // }).catchError((e) {
  //   print(e);
  // });
}

//get users card
getCard(UserDataCardNotifier cardNotifier) async {
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // QuerySnapshot snapshot = await FirebaseFirestore.instance
  //     .collection("userData")
  //     .doc(uEmail)
  //     .collection("card")
  //     .get();
  //
  // List<UserDataCard> _userDataCardList = [];
  //
  // snapshot.docs.forEach((doc) {
  //   UserDataCard userDataCard = UserDataCard.fromMap(doc.data());
  //   _userDataCardList.add(userDataCard);
  // });
  //
  // cardNotifier.userDataCardList = _userDataCardList;
}

//Updating new card
updateCard(
  cardHolder,
  cardNumber,
  validThrough,
  securityCode,
) async {
  // final db = FirebaseFirestore.instance;
  // final uEmail = await AuthService().getCurrentEmail();
  //
  // CollectionReference cardRef =
  //     db.collection("userData").doc(uEmail).collection("card");
  // await cardRef.doc(uEmail).update(
  //   {
  //     'cardHolder': cardHolder,
  //     'cardNumber': cardNumber,
  //     'validThrough': validThrough,
  //     'securityCode': securityCode,
  //   },
  // );
}

saveDeviceToken() async {
  final _fcm = FirebaseMessaging();
  String uid;
  Preference<String> addressesString =
      preferences.getString('user', defaultValue: '');
  addressesString.listen((value) {
    if (value != '') {
      UserDataProfile user = UserDataProfile.fromMap(json.decode(value));
      uid = user.id;
    }
  });

  //Getting device token
  String fcmToken = await _fcm.getToken();
  print("FCM Token $fcmToken");
  //Storing token
  if (fcmToken != null) {
    var url =
        Uri.parse('https://wild-grocery.herokuapp.com/api/user/details/$uid');
    String encodedOrderData = json.encode({"fcmtoken": fcmToken});

    var response = await http.put(url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: encodedOrderData);

    var data = json.decode(response.body);
    print(data);
  }
}
