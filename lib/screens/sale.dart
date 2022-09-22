import 'dart:async';

import 'package:billing/models/company.dart';
import 'package:billing/providers/app_provider.dart';
import 'package:billing/providers/screen_provider.dart';
import 'package:billing/screens/billed.dart';
import 'package:billing/screens/party.dart';
import 'package:billing/screens/upload_images.dart';
import 'package:billing/services/database.dart';
import 'package:billing/services/image_picker.dart';
import 'package:billing/util/currencyInputFormatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing/screens/notifications.dart';
import 'package:billing/util/comments.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/foods.dart';
import 'package:billing/widgets/badge.dart';
import 'package:billing/widgets/smooth_star_rating.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'textfieldcustom.dart';
import 'dart:math' as math;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

//import 'package:flutter_form_builder/flutter_form_builder.dart';

class Sale extends StatefulWidget {
  final SaleItem saleData;
  final String mode;

  Sale({this.saleData, this.mode});
  @override
  _SaleState createState() => _SaleState();
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

class _SaleState extends State<Sale> with TickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 2000);
  bool isFav = false;
  int _value = 1;

  String _appBarText;
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controller =
      List.generate(10, (i) => TextEditingController());

  bool _show;

  IconData _iconToggle;

  bool _toggleBilledItems;

  bool _recieved;

  String dropdownValue = 'Cash';

  GlobalKey _keyParty = GlobalKey();

  double positionRed;

  bool _showDescriptionTextField;

  String _dateTime;
  String _searchQuery;

  String _partyId;
  List<BilledItem> billedItemData = [];

  bool _toggleMode;

  String _saleId;

  //List<BilledItem> billedItemData = [];

  @override
  void initState() {
    super.initState();
    _appBarText = 'Sale';
    _show = false;
    _toggleBilledItems = true;
    _iconToggle = Icons.expand_more;

    _showDescriptionTextField = false;
    _dateTime = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    _searchQuery = '';

    //_totalBilledItems = 0;

    if (widget.mode == 'Edit') {
      _toggleMode = true;
      _saleId = widget.saleData.id;
      _dateTime = DateFormat('dd-MM-yyyy HH:mm')
          .format(widget.saleData.dateTime.toDate());
      //_controller[0].text = widget.saleData.partyId.toString();

      _partyId = widget.saleData.partyId;
      billedItemData = widget.saleData.billedItem;
      //_controller[2].text = widget.saleData.billedItem;
      _controller[1].text = widget.saleData.discount.toString();

      _controller[3].text = widget.saleData.tax.toString();
      _controller[6].text =
          CurrencyInputFormatter().toCurrency(widget.saleData.recieved);
      _recieved = (widget.saleData.recieved != 0) ? true : false;

      //_controller[6].text = widget.saleData.paymentType;
      _controller[8].text = widget.saleData.discription;
      //_controller[8].text = widget.saleData.image;
    } else {
      _toggleMode = false;
      _recieved = false;
      //_controller[0].text = widget.saleData.id.toString();
      _partyId = '';
      _controller[1].text = '0.0';
      _controller[2].text = '0.0';
      _controller[3].text = '0.0';
      _controller[4].text = '0.0';
      _controller[5].text = CurrencyInputFormatter().toCurrency(0);
      _controller[6].text = CurrencyInputFormatter().toCurrency(0);
      _controller[7].text = CurrencyInputFormatter().toCurrency(0);
      //_controller[8].text = widget.saleData.image;
      //_controller[9].text = widget.saleData.dateTime.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleIcon() {
    if (_toggleBilledItems) {
      setState(() {
        _toggleBilledItems = false;
        _iconToggle = Icons.expand_less;
      });
    } else {
      setState(() {
        _toggleBilledItems = true;
        _iconToggle = Icons.expand_more;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency(
        name: Constants.currency, decimalDigits: Constants.decimalDigits);
    final companyData = Provider.of<Company>(context);
    //final partyAdd = Provider.of<AppProvider>(context);
    final screenProvider = Provider.of<ScreenProvider>(context);

    List<Asset> images = List<Asset>();
    images = screenProvider.getAssetImage;

    double _totalBilledItems = 0;

    List<PartyItem> _searchResult = [];

    List<PartyItem> partyData;

    partyData = companyData?.party ?? [];
    partyData.forEach((element) {
      if (element.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        _searchResult.add(element);
      }
    });

    if (screenProvider.getPartyId != null) {
      _controller[0].text = screenProvider.getPartyName;
      _partyId = screenProvider.getPartyId;
    }

    if (_toggleMode) {
      _controller[0].text = widget.saleData.partyName(partyData);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.saleData.billedItem.forEach((element) {
          screenProvider.setBilledItem(element);
        });
      });

      setState(() {
        _toggleMode = false;
      });
    } else {
      billedItemData = screenProvider.getBilledItems ?? [];
    }

    List<ProductItem> productData;
    productData = companyData?.product ?? [];

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
            ),
            onPressed: () => {
                  screenProvider.clearBilledItems(),
                  Navigator.pop(context),
                }),
        centerTitle: false,
        title: Text(
          '${widget.mode} $_appBarText',
        ),
        elevation: 0.0,
        actions: <Widget>[
          Column(
            children: [
              Expanded(
                child: Transform(
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
              ),
            ],
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
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
            child: Stack(
              children: [
                ListView(
                  children: <Widget>[
                    //SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      //alignment: WrapAlignment.center,
                      children: [
                        Text(
                          '${Constants.date} : ',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          _dateTime,
                          //_dateTime.toString(),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () async {
                              final DateTime datePicked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1901, 1),
                                  lastDate: DateTime(2100));
                              final TimeOfDay timePicked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget child) {
                                  return MediaQuery(
                                    data: MediaQuery.of(context)
                                        .copyWith(alwaysUse24HourFormat: true),
                                    child: child,
                                  );
                                },
                              );
                              if (datePicked != null)
                                setState(() {
                                  _dateTime =
                                      '${DateFormat('dd-MM-yyyy').format(datePicked)} ${timePicked.hour}:${timePicked.minute}';

                                  _controller[9].text = _dateTime;
                                });
                            }),
                      ],
                    ),

                    Card(
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                Constants.partyBalance,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                formatCurrency
                                    .format(companyData.balance(_partyId)),
                                //'${Constants.currency} ${formatCurrency.format(companyData.balance(_partyId))}',
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFieldCustom(
                          key: _keyParty,
                          textAlign: TextAlign.left,
                          controller: _controller[0],
                          label: Constants.party,
                          onTap: () {
                            final RenderBox renderBoxRed =
                                _keyParty.currentContext.findRenderObject();
                            setState(() {
                              _show = true;
                              positionRed =
                                  renderBoxRed.localToGlobal(Offset.zero).dy;
                            });
                          },
                          onChanged: (String value) {
                            _debouncer.run(() {
                              setState(() {
                                _searchQuery = value;

                                _show = true;
                              });
                            });

                            //screenProvider.setPartyName(null);
                          },
                        ),
                      ]),
                    ),
                    // SizedBox(
                    //   height: 5,
                    // ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Container(
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(_iconToggle),
                                        onPressed: () {
                                          _toggleIcon();
                                        },
                                      ),
                                      Text(
                                        Constants.billedItems,
                                        style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                      icon: FaIcon(FontAwesomeIcons.qrcode),
                                      onPressed: () {})
                                ],
                              ),
                            ),
                            (_toggleBilledItems)
                                ? Container(
                                    //height: 200,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: billedItemData.length,
                                      itemBuilder: (context, index) {
                                        _totalBilledItems = _totalBilledItems +
                                            (billedItemData[index].qty *
                                                billedItemData[index].rate);
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          // Add Your Code here.
                                          _controller[2].text = formatCurrency
                                              .format((double.parse(
                                                          _controller[1].text) /
                                                      100) *
                                                  _totalBilledItems);
                                          //.toStringAsFixed(1);
                                          _controller[5].text = formatCurrency
                                              .format(_totalBilledItems -
                                                  (double.parse(_controller[1]
                                                              .text) /
                                                          100) *
                                                      _totalBilledItems);

                                          _controller[7].text = formatCurrency
                                              .format((CurrencyInputFormatter()
                                                      .toDouble(
                                                          _controller[5].text) -
                                                  CurrencyInputFormatter()
                                                      .toDouble(_controller[6]
                                                          .text)));
                                          //.toStringAsFixed(1);
                                        });

                                        //if(_recieved == false){
                                        print(
                                            double.parse(_controller[1].text));
                                        //print(double.parse(_controller[2].text));
                                        print(_totalBilledItems);
                                        print(
                                            '=========================${(double.parse(_controller[1].text) / 100) * _totalBilledItems}');
                                        //}
                                        return Column(
                                          children: [
                                            Card(
                                              color: Colors.grey[50],
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          productData
                                                              .where((element) =>
                                                                  element.id ==
                                                                  billedItemData[
                                                                          index]
                                                                      .productId)
                                                              .elementAt(0)
                                                              .itemName,

                                                          // billedItemData[index]
                                                          //     .productId,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                      Text(
                                                          formatCurrency.format(
                                                              billedItemData[
                                                                          index]
                                                                      .qty *
                                                                  billedItemData[
                                                                          index]
                                                                      .rate),
                                                          //'${Constants.currency} ${(billedItemData[index].qty * billedItemData[index].rate).toString()}',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text('Item Subtotal ',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                      Text(
                                                          '${billedItemData[index].qty} ${billedItemData[index].unit} X ${formatCurrency.format(billedItemData[index].rate)} = ${formatCurrency.format(billedItemData[index].qty * billedItemData[index].rate)} ',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                            (_toggleBilledItems)
                                ? Container(
                                    child: RaisedButton(
                                      color: Theme.of(context).accentColor,
                                      child: Text(Constants.addItem,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return Billed(
                                                mode: 'Add',
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
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
                              Constants.taxAndDiscount,
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
                                      child: Text(Constants.discount,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFieldCustom(
                                        controller: _controller[1],
                                        label: '%',
                                        textAlign: TextAlign.end,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          if (_controller[1].text == '')
                                            value = '0';
                                          _controller[2].text = formatCurrency
                                              .format((_totalBilledItems *
                                                      double.parse(value)) /
                                                  100);
                                          //.toStringAsFixed(1);
                                          _controller[5].text = formatCurrency
                                              .format((_totalBilledItems -
                                                  ((_totalBilledItems *
                                                          double.parse(value)) /
                                                      100)));
                                          //.toStringAsFixed(1);
                                          _controller[7].text = formatCurrency
                                              .format((_totalBilledItems -
                                                      ((_totalBilledItems *
                                                              double.parse(
                                                                  value)) /
                                                          100)) -
                                                  CurrencyInputFormatter()
                                                      .toDouble(
                                                          _controller[6].text));
                                          //.toStringAsFixed(1);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldCustom(
                                        controller: _controller[2],
                                        label: 'Amount',
                                        textAlign: TextAlign.right,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter(
                                              maxDigits: Constants.maxDigits),
                                        ],
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          if (_controller[2].text.toString() ==
                                              '') value = '0';
                                          _controller[1].text =
                                              ((CurrencyInputFormatter()
                                                              .toDouble(value) /
                                                          _totalBilledItems) *
                                                      100)
                                                  .toStringAsFixed(1);
                                          _controller[5].text = formatCurrency
                                              .format(_totalBilledItems -
                                                  CurrencyInputFormatter()
                                                      .toDouble(value));
                                          //.toStringAsFixed(1);
                                          _controller[7].text = formatCurrency
                                              .format((_totalBilledItems -
                                                      CurrencyInputFormatter()
                                                          .toDouble(value)) -
                                                  CurrencyInputFormatter()
                                                      .toDouble(
                                                          _controller[6].text));
                                          //.toStringAsFixed(1);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(Constants.tax,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFieldCustom(
                                          controller: _controller[3],
                                          label: '%',
                                          textAlign: TextAlign.end,
                                          keyboardType: TextInputType.number),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldCustom(
                                          controller: _controller[4],
                                          label: 'Amount',
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ])),
                    Card(
                        child: Row(children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 190,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          Checkbox(
                                              value: _recieved,
                                              onChanged: (value) {
                                                setState(() {
                                                  _recieved = value;
                                                });
                                                if (_recieved == false)
                                                  _controller[6].text = '0.0';
                                              }),
                                          Text(Constants.recieved,
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
                                        controller: _controller[6],
                                        label: '',
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            _recieved = true;
                                          });

                                          if (_controller[6].text == '')
                                            value = '0';
                                          _controller[7].text = (double.parse(
                                                      _controller[5].text) -
                                                  double.parse(value))
                                              .toStringAsFixed(1);
                                          //_controller[5].text = _controller[7].text =((_totalBilledItems-((_totalBilledItems*double.parse(value))/100))).toStringAsFixed(1);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(Constants.balanceDue,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFieldCustom(
                                          controller: _controller[7],
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Constants.paymentType,
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
                                '+ Add Bank A/c',
                                'Cash',
                                'Checque'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                (!_showDescriptionTextField)
                                    ? RaisedButton(
                                        color: Theme.of(context).accentColor,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add_comment,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(Constants.addDescription,
                                                style: TextStyle(
                                                    color:
                                                        Constants.lightPrimary,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showDescriptionTextField = true;
                                          });
                                        },
                                      )
                                    : Container(),
                                (_showDescriptionTextField)
                                    ? Expanded(
                                        child: TextFieldCustom(
                                          maxLines: 5,
                                          controller: _controller[8],
                                          label: Constants.addDescription,
                                          textAlign: TextAlign.left,
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                    child: IconButton(
                                  icon: Icon(Icons.add_a_photo),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return UploadImages();
                                        },
                                      ),
                                    );
                                  },
                                )),
                              ],
                            ),
                            Container(
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                children: List.generate(images.length, (index) {
                                  Asset asset = images[index];
                                  print(asset.getByteData(quality: 100));
                                  return Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: AssetThumb(
                                          asset: asset,
                                          width: 300,
                                          height: 300,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                (_show)
                    ? Positioned(
                        //top: 100,

                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(10, positionRed - 25, 10, 10),
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
                                                _show = false;
                                              });
                                            },
                                            child: Text(
                                              Constants.showingParties,
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
                                                  Icons.person_add,
                                                  size: 22.0,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _show = false;
                                                  });
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return Party(
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
                                                    _show = false;
                                                  });
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return Party(
                                                          mode: 'Add',
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  Constants.addParty,
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
                                                '${_searchResult[index].name}'),
                                            trailing: Wrap(
                                              children: [
                                                Text(
                                                    '${Constants.currency} ${formatCurrency.format(companyData.balance(_searchResult[index].id))}'),
                                                (companyData.balance(
                                                            _searchResult[index]
                                                                .id) >
                                                        0)
                                                    ? Icon(
                                                        Icons.call_received,
                                                        color: Colors.green,
                                                      )
                                                    : Icon(
                                                        Icons.call_made,
                                                        color: Colors.red,
                                                      )
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _show = false;
                                              });
                                              screenProvider.setPartyId(null);
                                              screenProvider.setPartyName(null);
                                              _controller[0].text =
                                                  _searchResult[index].name;
                                              _partyId =
                                                  _searchResult[index].id;
                                              //print(_partyId);
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
            Container(
              width: screenWidth * 0.5,
              child: RaisedButton(
                child: Text(
                  "DELETE",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                color: Theme.of(context).buttonColor,
                onPressed: () async {
                  await Database(company: 'company')
                      .removeSale(widget.saleData);
                  screenProvider.clearBilledItems();
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
                    var uuid = new Uuid();
                    String iduid =
                        uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
                    List<String> imageUrls = <String>[]; // TODO: use model

                    for (var imageFile in images) {
                      await Database().postImage(imageFile).then((downloadUrl) {
                        imageUrls.add(downloadUrl.toString());
                      });
                    }

                    Map<String, dynamic> saleItem = {
                      'id': (widget.mode == 'Edit') ? _saleId : iduid,
                      'dateTime': Timestamp.fromDate(
                          DateFormat('dd-MM-yyyy HH:mm').parse((_dateTime == '')
                              ? '01-01-1900 12:00' // 2208945600
                              : _dateTime)),
                      'partyId': _partyId,
                      'billedItem': billedItemData //TODO: use model
                          .asMap()
                          .entries
                          .map((e) => {
                                'productId': e.value.productId,
                                'qty': e.value.qty,
                                'unit': e.value.unit,
                                'rate': e.value.rate
                              })
                          .toList(),
                      'discount': double.parse((_controller[1].text == '')
                          ? '0'
                          : (_controller[1].text)),
                      'tax': double.parse((_controller[3].text == '')
                          ? '0'
                          : (_controller[3].text)),
                      'recieved': CurrencyInputFormatter().toDouble(
                          (_controller[6].text == '')
                              ? '0'
                              : (_controller[6].text)),
                      'paymentType': dropdownValue,
                      'discription': _controller[8].text,
                      'image': imageUrls
                          .asMap()
                          .entries
                          .map((e) => {
                                'url': e.value,
                              })
                          .toList(),
                    };

                    if (widget.mode == 'Edit') {
                      await Database(company: 'company')
                          .updateSaleData(widget.saleData, saleItem);
                      //await Database(company: 'company').removeProduct2(_controller[0].text);

                    } else {
                      print(saleItem.toString());

                      await Database(company: Constants.company)
                          .addDataSale(saleItem);
                    }
                    screenProvider.clearBilledItems();
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
