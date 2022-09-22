import 'package:flutter/material.dart';

class Constants {
  static String company = 'company';
  static var currency = 'IDR';
  static var decimalDigits = 0;
  static var maxDigits = 10;
  static var locale = 'en_US';
  //static String formatCurrency = '#,##0';
  static String appName = "Restaurant App UI KIT";
  static String paymentInfo =
      'Dapur Puteri Andrea\nJl. Labu Hijau 8 No. 383 Perum Bengkuring\nSamarinda, Kalimantan Timur, 75118\nHP: 0811557269\nBank Mandiri: 148000000000';

  //Colors for theme
//  Color(0xfffcfcff);
  static Color lightPrimary = Colors.green[100];
  static Color darkPrimary = Colors.black;
  static Color lightAccent = Colors.green;
  static Color darkAccent = Colors.red[400];
  static Color lightBG = Colors.green[50];
  static Color darkBG = Colors.black;
  static Color ratingBG = Colors.yellow[600];

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: darkBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
//      iconTheme: IconThemeData(
//        color: lightAccent,
//      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: lightBG,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
//      iconTheme: IconThemeData(
//        color: darkAccent,
//      ),
    ),
  );

  static String party = "Party";
  static String partyBalance = "Party balance: ";
  static String addParty = 'Add Party';

  static String showingParties = 'Showing Parties';

  static String billedItems = 'Billed Items';

  static String addItem = 'Add Item';

  static String discount = 'Discount %';

  static String taxAndDiscount = 'Tax & Discount';

  static String tax = 'Tax';

  static String totals = 'Totals';

  static String totalAmount = 'Total Amount';

  static String recieved = 'Recieved';

  static String balanceDue = 'Balance Due';

  static String paymentType = 'Payment Type';

  static String addDescription = 'Add Description';

  static String date = 'Date';

  static var name = 'Name';

  static var phoneNumber = 'Phone Number';

  static var emailAdrres = 'Email Address';

  static var openingBalance = 'Opening Balance';

  static var address = 'Address';

  static var billingAddress = 'Billing Address';

  static var asOfDate = 'As Of Date';

  static var toPay = 'To Pay';

  static var toRecieve = 'To Recieve';

  static String amount = 'Amount';

  static String partyName = 'Party Name';

  static var searchPartyName = 'Search Party Name';

  static String delete = 'Delete';

  static String cancel = 'Cancel';

  static String billedItem = 'Billed Item';

  static var productServiceName = 'Product / Service Name';

  static var quantity = 'Quantity';

  static String unit = 'Unit';

  static var ratePriceUnit = 'Rate (Price/Unit)';

  static String subtotal = 'Subtotal';

  static String rateXQty = 'Rate X Qty';

  static String showing = 'Showing';

  static String addProductService = 'Add Product/Service';

  static String totalSale = 'Total Sale';

  static String sale = 'Sale';

  static String total = 'Total';

  static var balance = 'Balance';

  static String saleList = 'Sale List';

  static String stockItems = 'Stock Items';

  static String parties = 'Parties';

  static String remainder = 'Remainder';
}
