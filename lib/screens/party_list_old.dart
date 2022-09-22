import 'dart:async';

import 'package:billing/models/company.dart';
import 'package:billing/screens/party.dart';
import 'package:billing/screens/textfieldcustom.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PartyList extends StatefulWidget {
  @override
  _PartyListState createState() => _PartyListState();
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

class _PartyListState extends State<PartyList> {
   final _debouncer = Debouncer(milliseconds: 2000);
  String _appBarText;
  TextEditingController _controller = TextEditingController();

  String _searchQuery;

  //List<PartyItem> _searchResult = [];

  void initState() {
    super.initState();
    _appBarText = Constants.party;
    _searchQuery = '';
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency(name: Constants.currency,decimalDigits: Constants.decimalDigits);
    final companyData = Provider.of<Company>(context);
    List<PartyItem> _searchResult = [];
    List<PartyItem> partyData;
    partyData = companyData?.party ?? [];
    //partyData.sort();
    partyData.forEach((element) {
      if (element.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        _searchResult.add(element);
      }
    });
    //_searchResult.sort((a, b) => a.toString().compareTo(b.toString()));
    
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
          'All $_appBarText',
        ),
        elevation: 0.0,
        actions: [
          IconButton(icon: Icon(Icons.add_alarm), onPressed: (){
            _searchResult.sort((a, b) => a.toString().compareTo(b.toString()));
          })
        ],
      ),
      body: Column(
        children: [
      TextFieldCustom(
        controller: _controller,
        textAlign: TextAlign.left,
        label: Constants.searchPartyName,
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.close,
          ),
          onPressed: () {
           
            setState(() {
              _controller.text = _searchQuery = '';
            });
          },
        ),
        onChanged: (String value) {
           _debouncer.run(() {
          setState(() {
            _searchQuery = _controller.text;
          });
        });},
      ),
      Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Constants.partyName),
              Text(Constants.amount),
            ],
          ),
        ),
      ),
      (_searchResult.length != 0)
          ? Expanded(
                      child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResult.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(_searchResult[index].name),
                        trailing: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(formatCurrency.format(companyData.balance(_searchResult[index].id))),
                            (companyData.balance(_searchResult[index].id)>0)
                            ?IconButton(
                              icon: Icon(
                                Icons.notifications_none,
                              ),
                              onPressed: () {},
                            )
                            :SizedBox(width: 50, ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return Party(
                                  partyData: _searchResult[index],
                                  mode: 'Edit',
                                );
                              },
                            ),
                          );
                        },
                      ),
                      //Divider(),
                    ],
                  );
                }),
          )
          : Loading(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Party(
                  mode: 'Add',
                );
              },
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).accentColor,
      ),
    );
  }
}
