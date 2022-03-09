import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  CustomFormField(this.controller, this.label,
      {this.maxLength = 255,
      this.maxLines = 1,
      this.radius = 10,
      this.type = TextInputType.text,
      this.autofocus = false,
      this.showCursor = null,
      this.readOnly = false,
      this.onFocus = null,
      this.icon = null,
      this.defaultValue = '',
      this.action = TextInputAction.next,
      Key? key})
      : super(key: key);
  bool autofocus;
  bool? showCursor;
  bool readOnly;
  var onFocus;
  TextEditingController controller;
  TextInputType type;
  int maxLength;
  int maxLines;
  double radius;
  Icon? icon;
  String label;
  String defaultValue;
  TextInputAction action;

  @override
  Widget build(BuildContext context) {
    controller.text = controller.text != '' ? controller.text : defaultValue;
    return TextField(
      onTap: onFocus,
      maxLines: maxLines,
      showCursor: showCursor,
      readOnly: readOnly,
      autofocus: autofocus,
      controller: controller,
      keyboardType: type,
      textInputAction: action,
      maxLength: maxLength != 255 ? maxLength : null,
      decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius))),
          prefixIcon: icon,
          label: Text(label),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 20,
          )),
    );
  }
}
