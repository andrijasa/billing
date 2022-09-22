import 'dart:io';
import 'dart:typed_data';

import 'package:billing/models/company.dart';

import 'package:billing/screens/sale.dart';
import 'package:billing/screens/sale_print.dart';
import 'package:billing/util/const.dart';
import 'package:billing/util/getit.dart';
import 'package:billing/util/injector.dart';
import 'package:billing/util/loading.dart';
import 'package:billing/util/txt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:billing/screens/notifications.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:pdf/widgets.dart' as pw;
import 'print.dart';

class SaleList extends StatefulWidget {
  final SaleItem saleData;
  final String mode;

  SaleList({this.saleData, this.mode});
  @override
  _SaleListState createState() => _SaleListState();
}

class _SaleListState extends State<SaleList>
    with SingleTickerProviderStateMixin {
  SaleItemPdf saleItemPdf = locator<SaleItemPdf>();
  bool isFav = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveAsFile(BuildContext context, LayoutCallback build,
      PdfPageFormat pageFormat) async {
    final ScaffoldState scaffold = Scaffold.of(context);
    final Uint8List bytes = await build(pageFormat);

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final File file =
        File(appDocPath + '/' + '${saleItemPdf.invoiceNumber}.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes).then((value) => scaffold.showSnackBar(
          const SnackBar(
            content: Text('Document saved successfully'),
          ),
        ));
    OpenFile.open(file.path);
  }

  void _showPrintedToast(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Document printed successfully'),
      ),
    );
  }

  void _showSharedToast(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);

    scaffold.showSnackBar(
      const SnackBar(
        content: Text('Document shared successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = new NumberFormat.simpleCurrency(
        name: Constants.currency, decimalDigits: Constants.decimalDigits);
    final companyData = Provider.of<Company>(context);
    List<SaleItem> saleData;
    List<PartyItem> partyData;
    saleData = companyData?.sale ?? [];
    partyData = companyData?.party ?? [];

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
          'Sale List',
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
        ],
      ),
      body: (saleData.length != 0)
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(Constants.totalSale),
                      Text(
                        '${formatCurrency.format(companyData.totalSale)}',
                        softWrap: true,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: saleData.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Sale(
                                    saleData: saleData[index],
                                    mode: 'Edit',
                                  );
                                },
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          saleData[index].partyName(partyData),
                                          // partyData
                                          //     .where((element) =>
                                          //         element.id ==
                                          //         saleData[index].partyId)
                                          //     .elementAt(0)
                                          //     .name,
                                          softWrap: true,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(Constants.sale),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                          color: (saleData[index].paidStatus ==
                                                  'PAID')
                                              ? Colors.green
                                              : Colors.orange,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              saleData[index].paidStatus,
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(DateFormat('dd-MM-yyyy HH:mm')
                                          .format(saleData[index]
                                              .dateTime
                                              .toDate())),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Text('${Constants.total} : '),
                                        Text(formatCurrency.format(
                                            saleData[index].totalAmount)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${Constants.balance} : ${formatCurrency.format(saleData[index].balance)}',
                                        softWrap: true,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Wrap(
                                        children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.print,
                                                size: 30.0,
                                              ),
                                              onPressed: () {
                                                //pw.RichText.debug = true;
                                                saleItemPdf.saleItem =
                                                    saleData[index];
                                                saleItemPdf.partyName =
                                                    saleData[index]
                                                        .partyName(partyData);
                                                saleItemPdf.partyAddress =
                                                    saleData[index]
                                                        .partyAddress(
                                                            partyData);
                                                saleItemPdf.partyPhoneNumber =
                                                    saleData[index]
                                                        .partyPhoneNumber(
                                                            partyData);
                                                List<ProductItem> productData =
                                                    companyData?.product ?? [];
                                                saleItemPdf.productItem =
                                                    productData;
                                                saleItemPdf.paymentInfo =
                                                    Constants.paymentInfo;
                                                saleItemPdf.invoiceNumber =
                                                    (DateFormat('ddMMyyyyHHmm')
                                                        .format(saleData[index]
                                                            .dateTime
                                                            .toDate()));

                                                final actions =
                                                    <PdfPreviewAction>[
                                                  if (!kIsWeb)
                                                    PdfPreviewAction(
                                                      icon: const Icon(
                                                          Icons.save),
                                                      onPressed: _saveAsFile,
                                                    )
                                                ];
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) => //PrintPage()
                                                      Scaffold(
                                                          appBar: AppBar(
                                                            title:
                                                                Text(Txt.print),
                                                          ),
                                                          body: PdfPreview(
                                                            initialPageFormat:
                                                                PdfPageFormat
                                                                    .a4,
                                                            //maxPageWidth: 700,
                                                            build:
                                                                generateInvoice,
                                                            actions: actions,
                                                            onPrinted:
                                                                _showPrintedToast,
                                                            onShared:
                                                                _showSharedToast,
                                                          )),
                                                ));
                                              }),
                                          // Transform(
                                          //   alignment: Alignment.center,
                                          //   transform:
                                          //       Matrix4.rotationY(math.pi),
                                          //   child: IconButton(
                                          //     icon: Icon(Icons.reply),
                                          //     iconSize: 30.0,
                                          //     onPressed: () {
                                          //       Navigator.of(context).push(
                                          //         MaterialPageRoute(
                                          //           builder:
                                          //               (BuildContext context) {
                                          //             return Notifications();
                                          //           },
                                          //         ),
                                          //       );
                                          //     },
                                          //   ),
                                          // ),
                                          IconButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                size: 30.0,
                                              ),
                                              onPressed: () {
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content:
                                                      Text('Have a snack!'),
                                                ));
                                              }),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            )
          : Loading(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return Sale(
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
