//import 'package:billing/screens/party_list.dart';
import 'package:billing/screens/sale_list.dart';
import 'package:billing/screens/stock_item_list.dart';
import 'package:billing/util/const.dart';
import 'package:flutter/material.dart';

import 'party_list.dart';

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.keyboard_backspace,
          //   ),
          //   onPressed: () => Navigator.pop(context),
          // ),
          centerTitle: false,
          title: Text(
            'Main Screen',
          ),
          elevation: 0.0,
        ),
        body: Container(
          child: SingleChildScrollView(
                    child: Padding(
              padding: const EdgeInsets.only(top:10.0, bottom: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Card(
                          elevation: 15,
                          color: Theme.of(context).primaryColor,
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Constants.toRecieve,
                                  style: TextStyle(color: Colors.black54, fontSize: 20),
                                ),
                                Text(
                                  'Rp. 3,000,000.00',
                                  style: TextStyle(color: Colors.black54, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          elevation: 15,
                          color: Theme.of(context).primaryColor,
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Constants.toPay,
                                  style: TextStyle(color: Colors.black54, fontSize: 20),
                                ),
                                Text(
                                  'Rp. 5,000,000.00',
                                  style: TextStyle(color: Colors.black54, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return SaleList();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 15,
                            color: Theme.of(context).primaryColor,
                            child: Container(
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pages,
                                    size: 60,
                                  ),
                                  Text(
                                    Constants.saleList,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return PartyList();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 15,
                            color: Theme.of(context).primaryColor,
                            child: Container(
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 60,
                                  ),
                                  Text(
                                    Constants.parties,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return StockItemList();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 15,
                            color: Theme.of(context).primaryColor,
                            child: Container(
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list,
                                    size: 60,
                                  ),
                                  Text(
                                    Constants.stockItems,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return PartyList();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 15,
                            color: Theme.of(context).primaryColor,
                            child: Container(
                              width: screenWidth * 0.4,
                              height: screenHeight * 0.2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 60,
                                  ),
                                  Text(
                                    Constants.party,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
