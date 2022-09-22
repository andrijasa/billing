import 'package:billing/models/company.dart';
import 'package:billing/providers/db_provider.dart';

import 'package:billing/screens/notifications.dart';
import 'package:billing/screens/product.dart';
import 'package:billing/services/database.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/loading.dart';
import 'package:billing/widgets/badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class StockItemList extends StatefulWidget {
  @override
  _StockItemListState createState() => _StockItemListState();
}

class _StockItemListState extends State<StockItemList>
    with TickerProviderStateMixin {
  TabController _nestedTabController;
  String _appBarText;
  List<ProductItem> productData;

  @override
  void initState() {
    super.initState();
    _appBarText = 'Stock item list';
    //productData = [];

    _nestedTabController = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    
   // final productData = Provider.of<List<ProductItem>>(context) ?? [];
    final companyData = Provider.of<Company>(context);
    // double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;
    //print(productData.product.length);
    productData = companyData?.product??[];
    return (productData.length != null)
    // && companyData.totalProductQty !=null)
        ?
        // StreamBuilder<Company>(
        //     stream: Database(company: 'company').companyData,
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         List<ProductItem> _listProductItem = List<ProductItem>.from(
        //             snapshot.data.product.map((e) => ProductItem(
        //                   itemName: e['itemName'],
        //                   code: e['code'],
        //                   salePrice: double.parse(e['salePrice'].toString()),
        //                   purchasePrice: double.parse(e['purchasePrice'].toString()),
        //                   openingStock: double.parse(e['openingStock'].toString()),
        //                   asOfDate: e['asOfDate'],
        //                   atPrice: double.parse(e['atPrice'].toString()),
        //                   minStock: double.parse(e['minStock'].toString()),
        //                   itemLocation: e['itemLocation'],
        //                 )));

        //                 print('vvvvvvvvvvvvvvvvvv${productData.length}');

        //         return
        Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.keyboard_backspace,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: false,
                title: Text(
                  _appBarText,
                ),
                elevation: 0.0,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Notifications();
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Notifications();
                          },
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return Notifications();
                          },
                        ),
                      );
                    },
                  ),
                ],
                bottom: TabBar(
                  controller: _nestedTabController,
                  indicatorColor: Colors.green,
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.black12,
                  tabs: [
                    Tab(text: 'Product'),
                    Tab(text: 'Services'),
                    Tab(text: 'Units'),
                  ],
                )),
            body: TabBarView(
              controller: _nestedTabController,
              children: [
                Container(
                  child: ListView.builder(
                    itemCount: productData.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                          key: Key(productData[index].itemName),
                          onDismissed: (direction) {
                            // RegistrationDB().removeData(productData[index].docID);
                          },
                          child: ItemTile(productData: productData[index], companyData: companyData,));
                    },
                  ),
                ),
                Icon(Icons.directions_transit),
                Icon(Icons.directions_bike),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return Product(
                        mode: 'Add',
                      );
                    },
                  ),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
          )
        : Loading();
    
  }
}

class ItemTile extends StatelessWidget {
  final formatCurrency = new NumberFormat.simpleCurrency(
        name: Constants.currency, decimalDigits: Constants.decimalDigits);
  final ProductItem productData;
  final Company companyData;
  ItemTile({this.productData, this.companyData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 5.0),
      child: ListTile(
        // leading: CircleAvatar(
        //   radius: 25.0,
        //   backgroundColor: Colors.brown[registration.strength],
        //   backgroundImage: AssetImage('assets/coffee_icon.png'),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                productData.itemName,
                softWrap: true,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Wrap(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.update,
                    size: 22.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Product(
                            productData: productData,
                            mode: 'Edit',
                          );
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.tune,
                    size: 22.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Notifications();
                        },
                      ),
                    );
                  },
                ),
                Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                                child: IconButton(
                  icon: Icon(Icons.reply),
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Notifications();
                        },
                      ),
                    );
                  },
                ),
              ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Qty'),
                    Text(
                      productData.stockQuantity(companyData.sale).toStringAsFixed(0),
                      //StockItemListData(saleItem: companyData.sale, productItem: productData).stockQuantity.toString(),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Sale Price'),
                    Text(
                      formatCurrency.format(productData.salePrice),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Qty'),
                    Text(//companyData.totalProductQty.toString(),
                      //Company(name: 'company').totalProductQty.toString(),
                      productData.availableQty(companyData.sale).toStringAsFixed(0),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Purcase Price'),
                    Text(
                      formatCurrency.format(productData.purchasePrice),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reserved Qty'),
                    Text(
                      productData.openingStock.toStringAsFixed(0),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Stock Value'),
                    Text( 
                      formatCurrency.format(productData.stockValue(companyData.sale)),
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    
                  ],
                ),
              ],
            )

            //Text('Birthday ${DateTime.parse(productData.birthday.toDate().toString())}'),
          ],
        ),

        onTap: () {
          // Navigator.push(
          //  context, MaterialPageRoute(builder: (context) =>
          //   RegistrationUpdate(docID:productData.docID)));
          // //print(productData.docID);
        },
      ),
    );
  }
}
