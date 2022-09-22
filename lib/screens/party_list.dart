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

  bool sort;

  int _sortColumnIndex;
  bool _sortAscending;
  List<PartyItem> _searchResult = [];

  bool _firstLoaded;

  //List<PartyItem> _searchResult = [];

  void initState() {
    super.initState();
    sort = true;
    _sortColumnIndex = 0;
    _sortAscending = true;
    _firstLoaded = true;
    _appBarText = Constants.party;
    _searchQuery = '';
  }

  void _sort<T>(
      Comparable<T> getField(PartyItem d), int columnIndex, bool ascending) {
    _searchResult.sort((PartyItem a, PartyItem b) {
      if (!ascending) {
        final PartyItem c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    print(_sortColumnIndex);
    print(sort);
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency(
        name: Constants.currency, decimalDigits: Constants.decimalDigits);
    final companyData = Provider.of<Company>(context);

    if (_firstLoaded) {
      _searchResult.clear();
      List<PartyItem> partyData;
      partyData = companyData?.party ?? [];
      //partyData.sort();
      partyData.forEach((element) {
        if (element.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
          _searchResult.add(element);
        }
      });
      if (_searchResult.length > 0)
        setState(() {
          _firstLoaded = false;
        });
    }
    //_searchResult.sort((a, b) => a.toString().compareTo(b.toString()));
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
          'All $_appBarText',
        ),
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(Icons.add_alarm),
              onPressed: () {
                _searchResult
                    .sort((a, b) => a.toString().compareTo(b.toString()));
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
                  _firstLoaded = true;
                });
              });
            },
          ),
          (_searchResult.length != 0)
              ? Expanded(
                  //flex: 8,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      sortAscending: sort,
                      sortColumnIndex: _sortColumnIndex,
                      columns: [
                        DataColumn(
                          label: Text(Constants.partyName),
                          onSort: (int columnIndex, bool ascending) {
                            _sort<String>((PartyItem d) => d.name, columnIndex,
                                ascending);
                            setState(() {
                              sort = !sort;
                            });
                          },
                        ),
                        DataColumn(
                          label: Text(Constants.balance),
                          onSort: (int columnIndex, bool ascending) {
                            _sort<String>(
                                (PartyItem d) =>
                                    d.balance(companyData).toString(),
                                columnIndex,
                                ascending);
                            setState(() {
                              sort = !sort;
                            });
                          },
                        ),
                        
                      ],
                      //rows: (_hasLoad)? _filterEmployees: _employees
                      rows: _searchResult
                          .map(
                            (display) => DataRow(cells: [
                              DataCell(
                                Container(
                                    width: screenWidth * .5,
                                    child: Text(display.name)),
                                //  '${DateTime.fromMillisecondsSinceEpoch(employee.timestamp.toInt())}'),
                                //Text('${employee.timestamp.toString()}'),
                                // Add tap in the row and populate the
                                // textfields with the corresponding values to update
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return Party(
                                          partyData: _searchResult
                                              .where((element) =>
                                                  element.id == display.id)
                                              .elementAt(0),
                                          mode: 'Edit',
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              DataCell(
                                Container(
                                  width: screenWidth * .3,
                                  child: Row(
                                    children: [
                                      Text(
                                        formatCurrency.format(
                                            display.balance(companyData)),
                                      ),
                                      (display.balance(companyData) > 0)
                                    ? Container(
                                        width: screenWidth * .1,
                                        child: IconButton(
                                            icon: Icon(Icons.notifications),
                                            onPressed: null),
                                      )
                                    : Container(
                                        width: screenWidth * .1,
                                        child: Text('')),

                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return Party(
                                          partyData: _searchResult
                                              .where((element) =>
                                                  element.id == display.id)
                                              .elementAt(0),
                                          mode: 'Edit',
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                             
                            ]),
                          )
                          .toList(),
                    ),
                  ),
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
