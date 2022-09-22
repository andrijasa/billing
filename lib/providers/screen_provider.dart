import 'package:billing/models/company.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ScreenProvider extends ChangeNotifier {
  String partyName;
  String partyId;
  List<BilledItem> billedItems=[];
  double totalBilled=0;
  List<Asset> images = List<Asset>();


  List<BilledItem> get getBilledItems => billedItems;
  List<Asset> get getAssetImage => images;
  double get getTotalBilled => totalBilled;

  String get getPartyName => partyName;
  String get getPartyId => partyName;

  void setPartyName(value) {
    partyName = value;
    notifyListeners();
  }
  void setPartyId(value) {
    partyId = value;
    notifyListeners();
  }

  void setBilledItem(value) {
    billedItems.add(value);
    notifyListeners();
  }
  void setBilledItems(value) {
    billedItems=value;
    notifyListeners();
  }
  void clearBilledItems() {
    billedItems.clear();
    notifyListeners();
  }
  void setTotalBilledItems(value) {
    totalBilled = value;
    notifyListeners();
  }
  void setAssetImage(value) {
    images = value;
    notifyListeners();
  }


}