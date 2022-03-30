import 'package:afletes_app_v1/utils/globals.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatefulWidget {
  CustomFormField(this.controller, this.label,
      {this.maxLength = 255,
      this.maxLines = 1,
      this.radius = 10,
      this.type = TextInputType.text,
      this.autofocus = false,
      this.focus,
      this.showCursor,
      this.readOnly = false,
      this.enabled = true,
      this.onFocus,
      this.onChange,
      this.icon,
      this.defaultValue = '',
      this.hint = '',
      this.action = TextInputAction.next,
      Key? key})
      : super(key: key);
  bool autofocus;
  bool? showCursor;
  bool enabled;
  bool readOnly;
  FocusNode? focus;
  var onFocus;
  var onChange;
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
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.defaultValue != ''
        ? widget.defaultValue
        : widget.controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: widget.onFocus,
      maxLines: widget.maxLines,
      showCursor: widget.showCursor,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      focusNode: widget.focus ?? FocusNode(),
      controller: widget.controller,
      keyboardType: widget.type,
      textInputAction: widget.action,
      enabled: widget.enabled,
      maxLength: widget.maxLength != 255 ? widget.maxLength : null,
      // onChanged: (value) {
      //   onChange(value) ?? () => {};
      // },
      onEditingComplete: () {
        widget.action == TextInputAction.next
            ? FocusScope.of(context).nextFocus()
            : (widget.action == TextInputAction.done
                ? FocusScope.of(context).unfocus()
                : null);
        widget.onChange != null
            ? widget.onChange(widget.controller.text)
            : () => {};
      },
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: kInputBorder),
          borderRadius: BorderRadius.all(
            Radius.circular(widget.radius),
          ),
        ),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: kInputBorder,
                size: 22,
              )
            : null,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kBlack, style: BorderStyle.solid)),
        hintText: widget.hint,
        hintStyle: TextStyle(color: kInputBorder),
        label: Text(widget.label),
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
      {this.action = TextInputAction.done,
      this.enabled = true,
      this.onSubmit,
      this.focus,
      Key? key})
      : super(key: key);
  TextEditingController controller;
  String label;
  TextInputAction action;
  bool enabled;
  FocusNode? focus;
  var onSubmit;
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
      focusNode: widget.focus ?? FocusNode(),
      // onEditingComplete: () => {},
      enabled: widget.enabled,
      onSubmitted: (text) => widget.onSubmit(),
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
        contentPadding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: 20,
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
