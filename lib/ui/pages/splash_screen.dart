import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool passwordVisibility = false;

  changeScreen() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var user = sharedPreferences.getString('user');
    if (user != null && user != 'null') {
      Navigator.of(context).pushReplacementNamed(
          jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void initState() {
    super.initState();
    changeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFed8d23),
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
            tag: 'splash-screen-loading',
            child: Lottie.asset('assets/lottie/camion.json')),
      ),
    );
  }
}

class SRegisterPage extends StatefulWidget {
  SRegisterPage({Key? key}) : super(key: key);

  @override
  State<SRegisterPage> createState() => SRegisterPageState();
}

class SRegisterPageState extends State<SRegisterPage> {
  bool passwordVisibility = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Email',
                  Icons.alternate_email,
                  hint: 'Ejemplo@gmail.com',
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Nombre',
                  Icons.person,
                  hint: 'José',
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Cédula',
                  Icons.article,
                  hint: '9888777',
                  action: TextInputAction.done,
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        ListView(
          children: [
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
                    obscureText: false,
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
                    obscureText: !passwordVisibility,
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
                  RegisterButton(
                    Future<bool>.delayed(
                        const Duration(seconds: 3), () => true),
                    text: 'Registrarse',
                  ),
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
      ],
    ));
  }
}

class RegisterFormField extends StatelessWidget {
  RegisterFormField(this.label, this.icon,
      {this.hint = '', this.action = TextInputAction.next, Key? key})
      : super(key: key);

  String label = '';
  String hint = '';
  IconData icon;
  TextInputAction action;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFED8232),
        ),
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return 'Ingresa un valor';
        }

        return null;
      },
    );
  }
}

class RegisterButton extends StatefulWidget {
  RegisterButton(this.callBack, {this.text = 'Iniciar Sesión', Key? key})
      : super(key: key);
  String text;
  Future<bool> callBack;

  @override
  State<RegisterButton> createState() => RegisterButtonState();
}

class RegisterButtonState extends State<RegisterButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: !isLoading
          ? TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFED8232)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                ),
              ),
              onPressed: () => {
                    setState(() => {
                          isLoading = !isLoading,
                        }),
                    Future.delayed(const Duration(seconds: 3))
                        .then((value) => setState(() => {
                              isLoading = !isLoading,
                            }))
                  },
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
              ))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
