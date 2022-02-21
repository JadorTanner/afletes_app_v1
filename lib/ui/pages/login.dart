import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TextEditingController textController1;
  late TextEditingController textController2;
  bool passwordVisibility = false;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    textController1 = TextEditingController();
    textController2 = TextEditingController();
    passwordVisibility = false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFED8232),
        ),
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: const AlignmentDirectional(-1, -1),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.35,
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
                      obscureText: false,
                      textInputAction: TextInputAction.next,
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
                    TextFormField(
                      controller: textController2,
                      obscureText: !passwordVisibility,
                      textInputAction: TextInputAction.none,
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
                    ),
                    const SizedBox(
                      width: 100,
                      height: 40,
                    ),
                    LoginButton(Future(() => login(
                        context, textController1.text, textController2.text))),
                    const SizedBox(
                      width: 100,
                      height: 20,
                    ),
                    const Text('He olvidado mi contraseña',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const Spacer(),
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton(this.login, {Key? key}) : super(key: key);
  final Future<bool> login;
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
              bool result = await widget.login;
              if (result) {
                setState(() {
                  isLoading = !isLoading;
                });
                Navigator.pushNamed(context, '/login');
              } else {
                setState(() {
                  isLoading = !isLoading;
                });
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
