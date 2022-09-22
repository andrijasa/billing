import 'dart:async';

import 'package:billing/models/company.dart';
import 'package:billing/providers/app_provider.dart';
import 'package:billing/providers/screen_provider.dart';
import 'package:billing/screens/product.dart';
import 'package:billing/screens/sale.dart';
import 'package:billing/services/database.dart';
import 'package:billing/util/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing/screens/notifications.dart';
import 'package:billing/widgets/badge.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'textfieldcustom.dart';
//import 'package:flutter_form_builder/flutter_form_builder.dart';

class Billed extends StatefulWidget {
  final BilledItem billedItemData;
  final String mode;
  
  Billed({this.billedItemData, this.mode,});
  @override
  _BilledState createState() => _BilledState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _BilledState extends State<Billed> with TickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 2000);
  bool isFav = false;
  int _value = 0;
  List item = [Constants.toPay, Constants.toRecieve];
  BilledItem billedItemDataNew = new BilledItem();
  

  String _appBarText;
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controller =
      List.generate(6, (i) => TextEditingController());

  var dropdownValue = 'BOX';

  bool _showItems;

  String _searchQuery;

  @override
  void initState() {
    super.initState();
    _appBarText = Constants.billedItem;
    _showItems = false;
    _searchQuery ='';

  

    if (widget.mode == 'Edit') {
      _controller[0].text = widget.billedItemData.productId;
      _controller[1].text = widget.billedItemData.qty.toString();
      _controller[2].text = widget.billedItemData.unit;
      _controller[3].text = widget.billedItemData.rate.toString();
      _controller[4].text = '';
      _controller[5].text = '';
     
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyData =Provider.of<Company>(context, listen: false);
    final billed =Provider.of<ScreenProvider>(context);
    
    List<ProductItem> _searchResult = [];
    List<ProductItem> productData;
    productData = companyData?.product ?? [];
    productData.forEach((element) {
      if (element.itemName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        _searchResult.add(element);
      }
    });

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
          '${widget.mode} $_appBarText',
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: IconBadge(
              icon: Icons.settings,
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
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
            child: Stack(
              children: [
                ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          
                          TextFieldCustom(
                              controller: _controller[0],
                              textAlign: TextAlign.left,
                              label: Constants.productServiceName,
                              validator: RequiredValidator(
                                  errorText: 'enter a valid number'),
                              keyboardType: TextInputType.number,
                              onTap: (){
                                setState(() {
                                  _showItems = true;
                                });
                              },
                              onChanged: (String value) {
                            _debouncer.run(() {
                              setState(() {
                                _searchQuery = value;

                                _showItems = true;
                              });
                            }
                              );
                              })
                          
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          
                          Row(
                            children: [
                              Expanded(
                                flex:2,
                                                          child: TextFieldCustom(
                                    controller: _controller[1],
                                    textAlign: TextAlign.left,
                                    label: Constants.quantity,
                                    validator: RequiredValidator(
                                        errorText: 'enter a valid number'),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                             
                                              _controller[4].text =
                                                  (double.parse(_controller[3].text)*double.parse(value)).toString();
                                              _controller[5].text =
                                                  (double.parse(_controller[3].text)*double.parse(value)).toString();
                                              billedItemDataNew.qty = double.parse(value);
                                              print(billedItemDataNew.qty);
                                            },),
                              ),
                              Expanded(
                                flex:1,
                                                          child: Column(children: [
                                  Text(Constants.unit,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  DropdownButton<String>(
                                    value: dropdownValue,
                                    icon: Icon(Icons.arrow_downward),
                                    iconSize: 24,
                                    elevation: 16,
                                    //style: TextStyle(color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownValue = newValue;
                                      });
                                    },
                                    items: <String>[
                                      'BOX',
                                      'BKS',
                                      'PCS'
                                    ].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],),
                              )
                            ],
                          ),
                          TextFieldCustom(
                              controller: _controller[3],
                              textAlign: TextAlign.left,
                              label: Constants.ratePriceUnit,
                              validator: RequiredValidator(
                                  errorText: 'enter a valid number'),
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    Card(
                            child: Row(children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 130,
                              alignment: Alignment.center,
                              color: Theme.of(context).primaryColor,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  Constants.totals,
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 14,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            children: [
                                              Text(Constants.subtotal,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700)),
                                              Text(Constants.rateXQty,
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ),
                                        
                                        
                                        Expanded(
                                          flex: 2,
                                          child: TextFieldCustom(
                                              controller: _controller[4],
                                              label: '',
                                              textAlign: TextAlign.right,
                                              keyboardType: TextInputType.number),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(Constants.totalAmount,
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                        
                                        Expanded(
                                          flex: 2,
                                          child: TextFieldCustom(
                                              controller: _controller[5],
                                              label: '',
                                              textAlign: TextAlign.right,
                                              keyboardType: TextInputType.number),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ])),
                  ],
                ),
                (_showItems)
                    ? Positioned(
                        //top: 100,

                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(10, 70, 10, 10),
                          child: Card(
                              elevation: 2,
                              margin: EdgeInsets.all(5),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      //width: double.infinity,
                                      padding: EdgeInsets.all(5),
                                      color: Theme.of(context).primaryColor,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _showItems = false;
                                              });
                                            },
                                            child: Text(
                                              Constants.showing,
                                              style: TextStyle(
                                                  color: Colors.blueGrey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.add_shopping_cart,
                                                  size: 22.0,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showItems = false;
                                                  });
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return Product(
                                                          mode: 'Add',
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _showItems = false;
                                                  });
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return Product(
                                                          mode: 'Add',
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  Constants.addProductService,
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _searchResult.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                                '${_searchResult[index].itemName}'),
                                            trailing: Wrap(
                                              children: [
                                                Text('5.000.000'),
                                                Icon(
                                                  Icons.call_made,
                                                  color: Colors.red,
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _showItems = false;
                                              });
                                              _controller[0].text =
                                                  _searchResult[index].itemName;
                                              
                                              billedItemDataNew.productId = _searchResult[index].id;
                                              
                                              _controller[3].text =  
                                                  _searchResult[index].salePrice.toString();
                                              billedItemDataNew.rate = _searchResult[index].salePrice;

                                              //partyAdd.setPartyAdd(_searchResult[index].name);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ])),
                        ),
                      )
                    : Container(),
              ],
            ),
          )),
      bottomNavigationBar: Container(
        height: 50.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            (widget.mode=='Edit')?
            Container(
              width: screenWidth * 0.5,
              child: RaisedButton(
                child: Text(
                  Constants.delete.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                color: Theme.of(context).buttonColor,
                onPressed: () async {
                  
                    //    await Database(company:  Constants.company)
                    //        .removeParty(widget.billedItemData);

                   

                    // Navigator.pop(context);
                },
              ),
            )
            : Container(
              width: screenWidth * 0.5,
              child: RaisedButton(
                child: Text(
                  Constants.cancel.toUpperCase(),
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                color: Theme.of(context).buttonColor,
                onPressed: () {Navigator.pop(context);},
              ),
            ),
            Container(
              width: screenWidth * 0.5,
              child: RaisedButton(
                child: Text(
                  "SAVE",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    billedItemDataNew.unit =  dropdownValue.toString();
                    print(billedItemDataNew.qty);
                    billed.setBilledItem(billedItemDataNew);

                    Navigator.pop(context);

                  }
                },
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

class CustomChoiceChip extends StatelessWidget {
  final String text;

  CustomChoiceChip({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      decoration: BoxDecoration(
          //color: Colors.black54,
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14.0),
      ),
    );
  }
}
