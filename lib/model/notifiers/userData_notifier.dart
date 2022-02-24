import 'package:flutter/foundation.dart';
import 'package:wildberries/model/data/userData.dart';

//For Users profile
class UserDataProfileNotifier with ChangeNotifier {
  UserDataProfile _userDataProfile;

  UserDataProfile get userDataProfile => _userDataProfile;

  set userDataProfile(UserDataProfile userDataProfile) {
    _userDataProfile = userDataProfile;
    notifyListeners();
  }
}

//For Users address
class UserDataAddressNotifier with ChangeNotifier {
  List<UserDataAddress> _userDataAddressList = [];
  UserDataAddress _userDataAddress;

  List<UserDataAddress> get userDataAddressList => _userDataAddressList;
  UserDataAddress get userDataAddress => _userDataAddress;

  set userDataAddressList(List<UserDataAddress> userDataAddressList) {
    _userDataAddressList = userDataAddressList;
    notifyListeners();
  }

  set userDataAddress(UserDataAddress userDataAddress) {
    _userDataAddress = userDataAddress;
    notifyListeners();
  }
}

class UserDataCardNotifier with ChangeNotifier {
  List<UserDataCard> _userDataCardList = [];
  UserDataCard _userDataCard;

  List<UserDataCard> get userDataCardList => _userDataCardList;
  UserDataCard get userDataCard => _userDataCard;

  set userDataCardList(List<UserDataCard> userDataCardList) {
    _userDataCardList = userDataCardList;
    notifyListeners();
  }

  set userDataCard(UserDataCard userDataCard) {
    _userDataCard = userDataCard;
    notifyListeners();
  }
}
