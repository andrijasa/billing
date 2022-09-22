import 'package:billing/models/company.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DbProvider {
  final String company;

  List<ProductItem> _productsData;
  Company _companyData;
  DbProvider({this.company});
  // {

  //   companyData;
  // }

  final CollectionReference billingCollection =
      Firestore.instance.collection('billing');



  Company _companyDataFromSnapshot(DocumentSnapshot snapshot) {
    
    return Company(
      id: snapshot.data['id']?? '',
      name: snapshot.data['name']?? '',
      product: List<ProductItem>.from(snapshot.data['product'].map((e) => ProductItem(
              itemName: e['itemName'],
              code: e['code'],
              salePrice: double.parse(e['salePrice'].toString()),
              purchasePrice: double.parse(e['purchasePrice'].toString()),
              openingStock: double.parse(e['openingStock'].toString()),
              asOfDate: e['asOfDate'],
              atPrice: double.parse(e['atPrice'].toString()),
              minStock: double.parse(e['minStock'].toString()),
              itemLocation: e['itemLocation'],
              id: e['id'].toString(),
            )))??[],
      party: List<PartyItem>.from(snapshot.data['party'].map((e) => PartyItem(
              id: e['id'],
              name: e['name'],
              phoneNumber:e['phoneNumber'],
              email: e['email'],
              address: e['address'],
              openingBalance: double.parse(e['openingBalance'].toString()),
              asOfDate: e['asOfDate'],
              toPayOrRecieve: int.parse(e['toPayOrRecieve'].toString()),
              
            )))??[],
      sale: List<SaleItem>.from(snapshot.data['sale'].map((e) => SaleItem(
              id: e['id'],
              dateTime:  e['dateTime'],
              partyId:e['partyId'],
              billedItem: List<BilledItem>.from(e['billedItem'].map((v) => BilledItem(
                productId: v['productId'],
                qty: double.parse(v['qty'].toString()),
                unit: v['unit'],
                rate: double.parse(v['rate'].toString()),

              ))),
              discount: double.parse(e['discount'].toString()),
              tax: double.parse(e['tax'].toString()),
              recieved: double.parse(e['recieved'].toString()),
              paymentType: e['paymentType'],
              discription: e['discription'],
              image: List<Images>.from(e['image'].map((v) => Images(url:v['url']))),
              
            )))??[]
      
      );
  }

  // Stream<List<ProductItem>> get productData {
    
  //   return billingCollection
  //       .document(company)
  //       .snapshots()
  //       .map(_productDataFromSnapshot);
  // }

  Stream<Company> get companyData {
    print('-----------xxx---------------');
    return billingCollection
        .document(company)
        .snapshots()
        .map(_companyDataFromSnapshot);
  }

}
