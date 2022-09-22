import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'const.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  
  CurrencyInputFormatter({this.maxDigits});
  final int maxDigits;

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (maxDigits != null && newValue.selection.baseOffset > maxDigits) {
      return oldValue;
    }

    double value = double.parse(newValue.text);
    final formatter = new NumberFormat.simpleCurrency(
        locale: Constants.locale,
        name: Constants.currency,
        decimalDigits: Constants.decimalDigits);
    var _decimalDigits;
    switch (Constants.decimalDigits) {
      case 0:
        {
          _decimalDigits = 1;
          break;
        }
      case 1:
        {
          _decimalDigits = 10;
          break;
        }
      case 2:
        {
          _decimalDigits = 100;
          break;
        }

        break;
      default:
    }
    String newText = formatter.format(value / _decimalDigits);
    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }

  double toDouble(String value)  {
    
    var _decimalDigits;
    switch (Constants.decimalDigits) {
      case 0:
        {
          _decimalDigits = 1;
          break;
        }
      case 1:
        {
          _decimalDigits = 10;
          break;
        }
      case 2:
        {
          _decimalDigits = 100;
          break;
        }

        break;
      default:
    }
    

    String _onlyDigits = value.replaceAll(RegExp('[^0-9]'), "");
    double _doubleValue = double.parse(_onlyDigits) / _decimalDigits;
    return _doubleValue;
  }

  String toCurrency(double value){
    final formatter = new NumberFormat.simpleCurrency(
        locale: Constants.locale,
        name: Constants.currency,
        decimalDigits: Constants.decimalDigits);
    return formatter.format(value);
  }

  
}

