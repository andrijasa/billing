import 'package:billing/models/company.dart';
import 'package:billing/services/database.dart';
import 'package:billing/util/currencyInputFormatter.dart';
import 'package:billing/util/txt.dart';
import 'package:flutter/material.dart';
import 'package:billing/screens/notifications.dart';
import 'package:billing/util/comments.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/foods.dart';
import 'package:billing/widgets/badge.dart';
import 'package:billing/widgets/smooth_star_rating.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'textfieldcustom.dart';
//import 'package:flutter_form_builder/flutter_form_builder.dart';

class Product extends StatefulWidget {
  final ProductItem productData;
  final String mode;
  Product({this.productData, this.mode});
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> with TickerProviderStateMixin {
  bool isFav = false;
  int _valueChoiceChip = 0;
  List item = ['Product', 'Service'];
  TabController _nestedTabController;
  TextEditingController _searchController, _searchController2;
  String _searchText = "";

  String _appBarText;
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controller =
      List.generate(10, (i) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _appBarText = 'Product';

    _nestedTabController = new TabController(length: 2, vsync: this);

    if (widget.mode == 'Edit') {
      _controller[9].text = widget.productData.id.toString();
      _controller[0].text = widget.productData.itemName;
      _controller[1].text = widget.productData.code;
      _controller[2].text =
          CurrencyInputFormatter().toCurrency(widget.productData.salePrice);
      _controller[3].text =
          CurrencyInputFormatter().toCurrency(widget.productData.purchasePrice);
      _controller[4].text = widget.productData.openingStock.toString();
      _controller[5].text = widget.productData.asOfDate;
      _controller[6].text =
          CurrencyInputFormatter().toCurrency(widget.productData.atPrice);
      _controller[7].text = widget.productData.minStock.toString();
      _controller[8].text = widget.productData.itemLocation;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Column(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  iconSize: 22.0,
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
              Expanded(
                child: Text('Add Image',
                    style: TextStyle(
                      fontSize: 12.0,
                    )),
              )
            ],
          ),
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
            child: ListView(
              children: <Widget>[
                SizedBox(height: 10.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: List<Widget>.generate(
                    item.length,
                    (int index) {
                      return ChoiceChip(
                        label: CustomChoiceChip(
                            text: '${item[index]}'), //Text('${item[index]}'),
                        selected: _valueChoiceChip == index,
                        onSelected: (bool selected) {
                          setState(() {
                            _valueChoiceChip = selected ? index : null;
                            _appBarText = item[index];
                          });
                        },
                        selectedColor: Theme.of(context).accentColor,
                      );
                    },
                  ).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: Column(
                    children: [
                      TextFieldCustom(
                        controller: _controller[0],
                        label: Txt.productName,
                        textAlign: TextAlign.left,
                        validator: RequiredValidator(
                            errorText: Txt.enterAValidProductName),
                        suffixIcon: Container(
                          padding: EdgeInsets.fromLTRB(0, 3, 10, 3),
                          width: screenWidth * 0.3,
                          child: RaisedButton(
                            child: Text(
                              Txt.selectUnit,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {},
                          ),
                        ),
                      ),
                      TextFieldCustom(
                          controller: _controller[1],
                          label: Txt.barcode,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                // SizedBox(
                //   height: 5,
                // ),
                Card(
                  child: Column(children: <Widget>[
                    TabBar(
                      controller: _nestedTabController,
                      indicatorColor: Colors.green,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.black12,
                      //isScrollable: true,
                      tabs: <Widget>[
                        Container(
                          width: screenWidth * 0.5,
                          child: Tab(
                            text: Txt.pricingDetails,
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.5,
                          child: Tab(
                            text: Txt.stockDetails,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: screenHeight * 0.4,
                      //margin: EdgeInsets.only(left: 16.0, right: 16.0),
                      child: TabBarView(
                        controller: _nestedTabController,
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                TextFieldCustom(
                                  controller: _controller[2],
                                  label: Txt.salePrice,
                                  textAlign: TextAlign.right,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(
                                        maxDigits: Constants.maxDigits),
                                  ],
                                  validator: RequiredValidator(
                                      errorText: Txt.enterAValidNumber),
                                  keyboardType: TextInputType.number,
                                  widthRatio: 1,
                                ),
                                TextFieldCustom(
                                    controller: _controller[3],
                                    label: Txt.purcasePrice,
                                    textAlign: TextAlign.right,
                                    inputFormatters: [
                                      WhitelistingTextInputFormatter.digitsOnly,
                                      CurrencyInputFormatter(
                                          maxDigits: Constants.maxDigits),
                                    ],
                                    validator: RequiredValidator(
                                        errorText: Txt.enterAValidNumber),
                                    keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldCustom(
                                        controller: _controller[4],
                                        label: Txt.openingStock,
                                        textAlign: TextAlign.right,
                                        validator: RequiredValidator(
                                            errorText: Txt.enterAValidNumber),
                                        keyboardType: TextInputType.number,
                                        widthRatio: 0.9,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextFieldCustom(
                                        controller: _controller[5],
                                        label: Txt.asOfDate,
                                        textAlign: TextAlign.left,
                                        validator: RequiredValidator(
                                            errorText: Txt.enterAValidDate),
                                        keyboardType: TextInputType.datetime,
                                        widthRatio: 0.50,
                                        suffixIcon: Container(
                                          width: 5,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 3, 0, 3),
                                          //width: screenWidth * 0.3,
                                          child: IconButton(
                                              icon: Icon(Icons.date_range),
                                              onPressed: () async {
                                                final DateTime picked =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime(1901, 1),
                                                        lastDate:
                                                            DateTime(2100));
                                                if (picked != null)
                                                  setState(() {
                                                    _controller[5].text =
                                                        '${picked.day.toString()}/${picked.month.toString()}/${picked.year.toString()}';
                                                  });
                                              }),
                                        ),
                                      ),
                                      TextFieldCustom(
                                        controller: _controller[6],
                                        label: Txt.atPricePerUnit,
                                        textAlign: TextAlign.right,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter(
                                              maxDigits: Constants.maxDigits),
                                        ],
                                        validator: RequiredValidator(
                                            errorText: Txt.enterAValidNumber),
                                        keyboardType: TextInputType.number,
                                        widthRatio: 0.45,
                                      ),
                                    ]),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextFieldCustom(
                                        controller: _controller[7],
                                        label: Txt.minStock,
                                        textAlign: TextAlign.right,
                                        validator: RequiredValidator(
                                            errorText: Txt.enterAValidNumber),
                                        keyboardType: TextInputType.number,
                                        widthRatio: 0.50,
                                      ),
                                      TextFieldCustom(
                                        controller: _controller[8],
                                        label: Txt.itemLocation,
                                        textAlign: TextAlign.left,
                                        keyboardType: TextInputType.text,
                                        widthRatio: 0.45,
                                      ),
                                    ])
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          )),
      bottomNavigationBar: Container(
        height: 50.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            (widget.mode == 'Edit')
                ? Container(
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(Txt.deleteProduct),
                                content: Text(
                                    Txt.doYouReallyWantToDeleteThisProduct),
                                actions: [
                                  FlatButton(
                                    child: Text(Txt.cancel),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(Txt.delete),
                                    onPressed: () async {
                                      await Database(company: Constants.company)
                                          .removeProduct(widget.productData)
                                          .then((value) =>
                                              Navigator.of(context).pop());

                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                    //ProductField productClass;
                    List<ProductItem> productData;
                    final companyData =
                        Provider.of<Company>(context, listen: false);
                    productData = companyData?.product ?? [];
                    var uuid = new Uuid();
                    String iduid =
                        uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
                    // print(productData[productData.length-1].toString());
                    // print('ID: ${productData.last.id}');

                    Map<String, dynamic> product = {
                      'itemName': _controller[0].text,
                      'code': _controller[1].text,
                      'salePrice': CurrencyInputFormatter().toDouble(
                          (_controller[2].text == '')
                              ? '0'
                              : _controller[2].text),
                      'purchasePrice': CurrencyInputFormatter().toDouble(
                          (_controller[3].text == '')
                              ? '0'
                              : _controller[3].text),
                      'openingStock': double.parse((_controller[4].text == '')
                          ? '0'
                          : (_controller[4].text)),
                      'asOfDate': _controller[5].text,
                      'atPrice': CurrencyInputFormatter().toDouble(
                          (_controller[6].text == '')
                              ? '0'
                              : _controller[6].text),
                      'minStock': double.parse((_controller[7].text == '')
                          ? '0'
                          : (_controller[7].text)),
                      'itemLocation': _controller[8].text,
                      'id':
                          (widget.mode == 'Edit') ? _controller[9].text : iduid,
                    };

                    if (widget.mode == 'Edit') {
                      await Database(company: 'company')
                          .updateData(widget.productData, product);
                      //await Database(company: 'company').removeProduct2(_controller[0].text);

                    } else {
                      print(product.toString());
                      await Database(company: 'company').addData(product);
                    }

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
