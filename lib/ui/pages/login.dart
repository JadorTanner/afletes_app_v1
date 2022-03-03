import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

TextEditingController textController1 = TextEditingController();
TextEditingController textController2 = TextEditingController();

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFED8232),
      ),
      // resizeToAvoidBottomInset: false,
      body: ListView(
        // mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: const AlignmentDirectional(-1, -1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFFED8232),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Hero(
                tag: 'splash-screen-loading',
                child: Lottie.asset('assets/lottie/camion.json'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  width: 100,
                  height: 40,
                ),
                TextFormField(
                  controller: textController1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  // onEditingComplete: () => {},
                  // onChanged: (value) => {print(value)},
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ejemplo@gmail.com',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFED8232),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFED8232),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    prefixIcon: const Icon(
                      Icons.alternate_email,
                      color: Color(0xFFED8232),
                    ),
                  ),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Ingresa un email';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  width: 100,
                  height: 40,
                ),
                PasswordField(),
                const SizedBox(
                  width: 100,
                  height: 40,
                ),
                LoginButton(),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                const Text('He olvidado mi contraseña',
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          // const Spacer(),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                const WidgetSpan(child: Text('Aún no tienes una cuenta? ')),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Crea una aquí!',
                      style: TextStyle(
                          color: Color(0xFFED8232),
                          fontSize: 16,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ])),
          // const Spacer(),
        ],
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton({Key? key}) : super(key: key);
  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: (isLoading
          ? null
          : () async {
              setState(() {
                isLoading = !isLoading;
              });
              bool isLogged = await User()
                  .login(context, textController1.text, textController2.text);
              if (isLogged) {
                setState(() {
                  isLoading = !isLoading;
                });
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                Map user = jsonDecode(sharedPreferences.getString('user')!);
                if (user['is_carrier']) {
                  Navigator.of(context).pushReplacementNamed('/loads');
                } else {
                  Navigator.of(context).pushReplacementNamed('/vehicles');
                }
              } else {
                setState(() {
                  isLoading = !isLoading;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ha ocurrido un error')));
              }
            }),
      icon: isLoading
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.app_registration,
              color: Colors.white,
              size: 30,
            ),
      label:
          const Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
      style: ButtonStyle(
          backgroundColor: isLoading
              ? MaterialStateProperty.all(const Color(0xFFA0A0A0))
              : MaterialStateProperty.all(const Color(0xFFED8232))),
    );
  }
}

class PasswordField extends StatefulWidget {
  PasswordField({Key? key}) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool passwordVisibility = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController2,
      obscureText: !passwordVisibility,
      // onEditingComplete: () => {},
      decoration: InputDecoration(
        labelText: 'Contraseña',
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFED8232),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFED8232),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        prefixIcon: const Icon(
          Icons.lock,
          color: Color(0xFFED8232),
        ),
        suffixIcon: InkWell(
          onTap: () => setState(
            () => passwordVisibility = !passwordVisibility,
          ),
          child: Icon(
            passwordVisibility
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xFFED8232),
            size: 22,
          ),
        ),
      ),
    );
  }
}
