import 'package:flutter/material.dart';

//input para contraseña
class PasswordInput extends StatefulWidget {
  PasswordInput({Key? key}) : super(key: key);

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: IconButton(
          onPressed: () => setState(() {
            obscure = !obscure;
          }),
          icon: Icon(obscure ? Icons.lock : Icons.lock_open),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            color: Color(0xFFAAAAAA),
          ),
        ),
      ),
      obscureText: obscure,
    );
  }
}
