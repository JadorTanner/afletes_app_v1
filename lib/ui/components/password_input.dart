import 'package:flutter/material.dart';

//input para contraseña
class PasswordInput extends StatefulWidget {
  const PasswordInput({this.controller, Key? key}) : super(key: key);
  final TextEditingController? controller;
  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return
        // Container(
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //       boxShadow: [
        //         BoxShadow(
        //             blurRadius: 5, color: Color(0xAACCCCCC), offset: Offset(0, 5)),
        //       ],
        //       borderRadius: BorderRadius.all(
        //         Radius.circular(100),
        //       ),
        //     ),
        //     child:
        TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: IconButton(
          onPressed: () => setState(() {
            obscure = !obscure;
          }),
          icon: Icon(obscure ? Icons.lock : Icons.lock_open),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          borderSide: BorderSide(color: Color(0xFFAAAAAA)),
        ),
      ),
      obscureText: obscure,
    )
        // )
        ;
  }
}
