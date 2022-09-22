import 'package:billing/models/company.dart';
import 'package:billing/screens/party.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class Database extends ChangeNotifier {
  final String company;
  Database({this.company});

  // collection reference
  final CollectionReference billingCollection =
      Firestore.instance.collection('billing');

  Future addData(
    Map<String, dynamic> data,
  ) async {
    await billingCollection.document(company).updateData({
      'product': FieldValue.arrayUnion([data]),
    });
  }

  Future addDataSale(
    Map<String, dynamic> data,
  ) async {
    await billingCollection.document(company).updateData({
      'sale': FieldValue.arrayUnion([data]),
    });
  }

  Future addDataParty(
    Map<String, dynamic> data,
  ) async {
    await billingCollection.document(company).updateData({
      'party': FieldValue.arrayUnion([data]),
    });
  }

  Future updateData(ProductItem elements, Map<String, dynamic> data) async {
    removeProduct(elements);
    await billingCollection.document(company).updateData({
      'product': FieldValue.arrayUnion([data]),
    });
  }

  Future updatePartyData(PartyItem elements, Map<String, dynamic> data) async {
    removeParty(elements);
    await billingCollection.document(company).updateData({
      'party': FieldValue.arrayUnion([data]),
    });
  }

  Future updateSaleData(SaleItem elements, Map<String, dynamic> data) async {
    removeSale(elements);
    await billingCollection.document(company).updateData({
      'sale': FieldValue.arrayUnion([data]),
    });
  }

  Future removeParty(PartyItem elements) async {
    try {
      await billingCollection.document(company).updateData({
        'party': FieldValue.arrayRemove(//val
            [
          {
            'id': elements.id,
            'name': elements.name,
            'phoneNumber': elements.phoneNumber,
            'email': elements.email,
            'address': elements.address,
            'openingBalance': elements.openingBalance,
            'asOfDate': elements.asOfDate,
            'toPayOrRecieve': elements.toPayOrRecieve,
          }
        ])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future removeProduct(ProductItem elements) async {
    try {
      await billingCollection.document(company).updateData({
        'product': FieldValue.arrayRemove(//val
            [
          {
            'itemName': elements.itemName,
            'code': elements.code,
            'salePrice': elements.salePrice,
            'purchasePrice': elements.purchasePrice,
            'openingStock': elements.openingStock,
            'asOfDate': elements.asOfDate,
            'atPrice': elements.atPrice,
            'minStock': elements.minStock,
            'itemLocation': elements.itemLocation,
            'id': elements.id,
          }
        ])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future removeSale(SaleItem elements) async {
    try {
      
      await billingCollection.document(company).updateData({
        'sale': FieldValue.arrayRemove(//[product[0]]
            [
          {
            'id': elements.id,
            'dateTime': elements.dateTime,
            'partyId': elements.partyId,
            'billedItem': //[],//[{elements.billedItem}],
                elements.billedItem
                    .map((e) => {
                          'productId': e.productId,
                          'qty': e.qty,
                          'unit': e.unit,
                          'rate': e.rate
                        })
                    .toList(),
            'discount': elements.discount,
            'tax': elements.tax,
            'recieved': elements.recieved,
            'paymentType': elements.paymentType,
            'discription': elements.discription,
            'image': //[],//elements.image,
                elements.image
                    .map((e) => {
                          'url': e.url,
                        })
                    .toList(),
          }
        ])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Company _userDataFromSnapshot(DocumentSnapshot snapshot) {
    print('------------------${snapshot.data['footPrint']}');
    return Company(product: snapshot.data['product']);
  }

  Stream<Company> get companyData {
    return billingCollection
        .document(company)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child('project/billing/company/$fileName');
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(
        '=======================================${storageTaskSnapshot.ref.getDownloadURL()}');
    storageTaskSnapshot.ref.getDownloadURL().then((value) {
      print(value.toString());
    });
    return storageTaskSnapshot.ref.getDownloadURL();
  }
}
