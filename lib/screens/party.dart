import 'package:billing/models/company.dart';
import 'package:billing/providers/app_provider.dart';
import 'package:billing/providers/screen_provider.dart';
import 'package:billing/screens/sale.dart';
import 'package:billing/services/database.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/currencyInputFormatter.dart';

import 'package:billing/util/txt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billing/screens/notifications.dart';
import 'package:billing/widgets/badge.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'textfieldcustom.dart';
//import 'package:flutter_form_builder/flutter_form_builder.dart';

class Party extends StatefulWidget {
  final PartyItem partyData;
  final String mode;

  Party({
    this.partyData,
    this.mode,
  });
  @override
  _PartyState createState() => _PartyState();
}

class _PartyState extends State<Party> with TickerProviderStateMixin {
  final formatCurrency = new NumberFormat.simpleCurrency(
      name: Constants.currency, decimalDigits: Constants.decimalDigits);
  bool isFav = false;
  int _value = 0;
  List item = [Constants.toPay, Constants.toRecieve];
  TabController _nestedTabController;

  String _appBarText;
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> _controller =
      List.generate(8, (i) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _appBarText = Constants.party;

    _nestedTabController = new TabController(length: 2, vsync: this);

    if (widget.mode == 'Edit') {
      _controller[0].text = widget.partyData.id;
      _controller[1].text = widget.partyData.name;
      _controller[2].text = widget.partyData.phoneNumber;
      _controller[3].text = widget.partyData.email;
      _controller[4].text = widget.partyData.address;
      _controller[5].text =
          CurrencyInputFormatter().toCurrency(widget.partyData.openingBalance);
      _controller[6].text = (widget.partyData.asOfDate.millisecondsSinceEpoch ==
              -2208945600 * 1000)
          ? ''
          : DateFormat('dd-MM-yyyy HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(
                  widget.partyData.asOfDate.millisecondsSinceEpoch))
              .toString();

      _controller[7].text = widget.partyData.toPayOrRecieve.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyData = Provider.of<Company>(context, listen: false);
    final screenProvider = Provider.of<ScreenProvider>(context);
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: Column(
                    children: [
                      TextFieldCustom(
                        controller: _controller[1],
                        textAlign: TextAlign.left,
                        label: Constants.name,
                        validator: RequiredValidator(errorText: Txt.enterName),
                        suffixIcon: Container(
                          padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                          //width: screenWidth * 0.3,
                          child: IconButton(
                            icon: Icon(
                              Icons.search,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      TextFieldCustom(
                        controller: _controller[2],
                        textAlign: TextAlign.left,
                        label: Constants.phoneNumber,
                      ),
                      TextFieldCustom(
                        controller: _controller[3],
                        textAlign: TextAlign.left,
                        label: Constants.emailAdrres,
                      ),
                    ],
                  ),
                ),
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
                            text: Constants.address,
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.5,
                          child: Tab(
                            text: Constants.openingBalance,
                          ),
                        ),
                      ]),
                  Container(
                    height: screenHeight * 0.3,
                    //margin: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: TabBarView(
                      controller: _nestedTabController,
                      children: <Widget>[
                        Container(
                          child: TextFieldCustom(
                              controller: _controller[4],
                              textAlign: TextAlign.left,
                              label: Constants.billingAddress,
                              keyboardType: TextInputType.text),
                        ),
                        Container(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFieldCustom(
                                        controller: _controller[5],
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter(
                                              maxDigits: Constants.maxDigits),
                                        ],
                                        textAlign: TextAlign.right,
                                        label: Constants.openingBalance,
                                        keyboardType: TextInputType.number),
                                  ),
                                  Expanded(
                                    child: TextFieldCustom(
                                      controller: _controller[6],
                                      textAlign: TextAlign.left,
                                      label: Constants.asOfDate,
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.date_range),
                                          onPressed: () async {
                                            final DateTime datePicked =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate:
                                                        DateTime(1901, 1),
                                                    lastDate: DateTime(2100));
                                            final TimeOfDay timePicked =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (BuildContext context,
                                                  Widget child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                          alwaysUse24HourFormat:
                                                              true),
                                                  child: child,
                                                );
                                              },
                                            );
                                            if (datePicked != null) {
                                              final _dateTime =
                                                  '${DateFormat('dd-MM-yyyy').format(datePicked)} ${timePicked.hour}:${timePicked.minute}';

                                              _controller[6].text = _dateTime;
                                            }
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: List<Widget>.generate(
                                  item.length,
                                  (int index) {
                                    return ChoiceChip(
                                      label: CustomChoiceChip(
                                          text:
                                              '${item[index]}'), //Text('${item[index]}'),
                                      selected: _value == index,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _value = selected ? index : null;
                                          _controller[7].text =
                                              index.toString();
                                        });
                                      },
                                      selectedColor:
                                          Theme.of(context).accentColor,
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ]))
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
                                title: Text(Txt.deleteParty),
                                content:
                                    Text(Txt.doYouReallyWantToDeleteThisParty),
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
                                          .removeParty(widget.partyData)
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
                    List<PartyItem> partyData;

                    partyData = companyData?.party ?? [];
                    var uuid = new Uuid();
                    String iduid =
                        uuid.v4(options: {'rng': UuidUtil.cryptoRNG});
                    //int id =partyData.last.id+1;

                    print(iduid);
                    //print('TIME: ${partyData.last.asOfDate}');

                    Map<String, dynamic> party = {
                      'id':
                          (widget.mode == 'Edit') ? _controller[0].text : iduid,
                      'name': _controller[1].text,
                      'phoneNumber': _controller[2].text,
                      'email': _controller[3].text,
                      'address': _controller[4].text,
                      'openingBalance': double.parse((_controller[5].text == '')
                          ? '0'
                          : CurrencyInputFormatter()
                              .toDouble(_controller[5].text)
                              .toString()),
                      'asOfDate': Timestamp.fromDate(
                          DateFormat('dd-MM-yyyy HH:mm')
                              .parse((_controller[6].text == '')
                                  ? '01-01-1900 12:00' // 2208945600
                                  : _controller[6].text)),
                      'toPayOrRecieve': int.parse((_controller[7].text == '')
                          ? '0'
                          : (_controller[7].text)),
                    };

                    if (widget.mode == 'Edit') {
                      await Database(company: Constants.company)
                          .updatePartyData(widget.partyData, party);

                      //print(CurrencyInputFormatter().toDouble(_controller[5].text));
                    } else {
                      screenProvider.setPartyName(_controller[1].text);
                      screenProvider.setPartyId(iduid);

                      await Database(company: Constants.company)
                          .addDataParty(party);
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
