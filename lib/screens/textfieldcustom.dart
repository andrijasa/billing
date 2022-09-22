import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(String) validator;
  final Function(String) onChanged;
  final Function() onTap;
  final Widget suffixIcon;
  final Widget prefixIcon;
  final TextInputType keyboardType;
  final double widthRatio;
  final TextAlign textAlign;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;

  final String initialValue;

  TextFieldCustom(
      {Key key,
      @required this.label,
      this.suffixIcon,
      this.prefixIcon,
      this.controller,
      this.validator,
      this.keyboardType,
      this.widthRatio,
      this.onTap,
      this.textAlign,
      this.maxLines,
      this.onChanged,
      this.initialValue,
      this.inputFormatters})
      : super(key: key);

  @override
  _TextFieldCustomState createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  TextEditingController nameTextEditingController = TextEditingController();
  String _labelText;
  bool _autovalidate;

  double _widthRatio;

  @override
  void initState() {
    super.initState();
    _labelText = widget.label;
    _autovalidate = false;
    //nameTextEditingController=widget.controller;
    widget.controller.addListener(_hasStartedTyping);
    _widthRatio = (widget.widthRatio == null) ? 1 : widget.widthRatio;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _hasStartedTyping() {
    setState(() {
      if (widget.controller.text.isNotEmpty) {
        _labelText = widget.label;
      } else {
        _labelText = null;
      }
    });
  }

  void _onChanged(String value) {
    setState(() {
      _autovalidate = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * _widthRatio,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: TextFormField(
          inputFormatters: widget.inputFormatters,
          initialValue: widget.initialValue,
          maxLines: widget.maxLines,
          autovalidate: _autovalidate,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          // inputFormatters: <TextInputFormatter>[
          //   WhitelistingTextInputFormatter.digitsOnly
          // ],
          autofocus: false,
          textAlign: widget.textAlign,
          textInputAction: TextInputAction.done,
          controller: widget.controller,
          validator: widget.validator,
          // (value) {
          //   if (value.isEmpty) {
          //     return 'Please enter some text';
          //   }
          //   return null;
          // },
          style: TextStyle(
              color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green, width: 1.0),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.green, width: 2.0),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            labelText: _labelText,
            hintText: widget.label,
            alignLabelWithHint: true,
            hintStyle: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
            labelStyle: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
