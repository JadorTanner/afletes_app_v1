import 'dart:convert';

import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:pusher_client/pusher_client.dart';
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
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Align(
            alignment: const AlignmentDirectional(-1, -1),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(color: Colors.white),
              child: Image.asset(
                'assets/icons/logo-naranja.png',
                width: 50,
                height: 50,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40, 20, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomFormField(
                  textController1,
                  'Email',
                  hint: 'Ejemplo@gmail.com',
                  icon: Icons.alternate_email,
                  type: TextInputType.emailAddress,
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                PasswordField('Contraseña', textController2),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                const LoginButton(),
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
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                Map user = jsonDecode(sharedPreferences.getString('user')!);

                //TOKEN PARA MENSAJES PUSH
                try {
                  String? token = await FirebaseMessaging.instance.getToken();
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
                      PusherApi().init(context);
                      Geolocator.getPositionStream(
                              locationSettings: locationSettings)
                          .listen((Position? position) {
                        if (position != null) {
                          Api api = Api();
                          api.postData('update-location', {
                            'latitude': position.latitude,
                            'longitude': position.longitude,
                            'heading': position.heading,
                          });
                        }
                      });
                      Navigator.of(context).pushReplacementNamed('/loads');
                    } else {
                      PusherApi().init(context, true);
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
