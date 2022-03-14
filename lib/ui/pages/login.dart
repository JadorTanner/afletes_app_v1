import 'dart:async';
import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
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
      body: ListView(
        children: [
          Align(
            alignment: const AlignmentDirectional(-1, -1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(color: Colors.orange),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40, 20, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: textController1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  // onEditingComplete: () => {},
                  decoration: InputDecoration(
                    labelText: 'Email',
                    floatingLabelStyle: TextStyle(color: kBlack),
                    hintText: 'Ejemplo@gmail.com',
                    hintStyle: TextStyle(color: kInputBorder),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kInputBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kInputBorder,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: kInputBorder,
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
                  height: 20,
                ),
                PasswordField(),
                const SizedBox(
                  width: 100,
                  height: 20,
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
            text: TextSpan(
              children: [
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
              ],
            ),
          ),
          // const Spacer(),
          const SizedBox(
            width: 100,
            height: 20,
          ),
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

                PusherApi().init(context);

                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                Map user = jsonDecode(sharedPreferences.getString('user')!);

                //TOKEN PARA MENSAJES PUSH
                String? token = await FirebaseMessaging.instance.getToken();
                try {
                  await Api().postData('user/set-device-token',
                      {'id': user['id'], 'device_token': token ?? ''});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ha ocurrido un error')));
                }
                if (user['confirmed']) {
                  if (user['habilitado']) {
                    if (user['is_carrier']) {
                      //ENVIAR UBICACION CUANDO CAMBIE
                      LocationSettings locationSettings =
                          const LocationSettings(
                        accuracy: LocationAccuracy.best,
                        distanceFilter: 5,
                      );
                      Geolocator.getPositionStream(
                              locationSettings: locationSettings)
                          .listen((Position? position) {
                        Api api = Api();
                        api.postData('update-location', {
                          'latitude': position!.latitude,
                          'longitude': position.longitude,
                          'heading': position.heading,
                        });
                      });
                      Navigator.of(context).pushReplacementNamed('/loads');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/vehicles');
                    }
                  } else {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const WaitHabilitacion(),
                    ));
                  }
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ValidateCode(),
                  ));
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
        floatingLabelStyle: TextStyle(color: kBlack),
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        prefixIcon: Icon(
          Icons.lock,
          color: kInputBorder,
        ),
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
