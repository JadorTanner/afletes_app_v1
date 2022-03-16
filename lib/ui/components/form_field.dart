// ignore_for_file: must_be_immutable, avoid_init_to_null, prefer_typing_uninitialized_variables

import 'package:afletes_app_v1/utils/globals.dart';
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
      this.hint = '',
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
  IconData? icon;
  String label;
  String defaultValue;
  String hint;
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
          borderSide: BorderSide(color: kInputBorder),
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: kInputBorder,
                size: 22,
              )
            : null,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kBlack, style: BorderStyle.solid)),
        hintText: hint,
        hintStyle: TextStyle(color: kInputBorder),
        label: Text(label),
        floatingLabelStyle: TextStyle(color: kBlack),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  PasswordField(this.label, this.controller,
      {this.action = TextInputAction.done, Key? key})
      : super(key: key);
  TextEditingController controller;
  String label;
  TextInputAction action;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisibility = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: passwordVisibility,
      textInputAction: widget.action,
      // onEditingComplete: () => {},
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: kInputBorder),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        hintStyle: TextStyle(color: kInputBorder),
        floatingLabelStyle: TextStyle(color: kBlack),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        hintText: 'Contraseña',
        prefixIcon: Icon(
          Icons.lock,
          color: kInputBorder,
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kBlack, style: BorderStyle.solid)),
        suffixIcon: InkWell(
          onTap: () => setState(
            () => passwordVisibility = !passwordVisibility,
          ),
          child: Icon(
            passwordVisibility
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: kInputBorder,
            size: 22,
          ),
        ),
      ),
    );
  }
}
