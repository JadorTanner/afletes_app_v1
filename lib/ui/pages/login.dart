import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final FocusNode _emailFocus = FocusNode();
final FocusNode _passwordFocus = FocusNode();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

TextEditingController textController1 = TextEditingController();
TextEditingController textController2 = TextEditingController();

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isLoading = false;

  checkIfIssetUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('user') != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        context.read<User>().user.isCarrier ? '/loads' : '/vehicles',
        ModalRoute.withName(
            context.read<User>().user.isCarrier ? '/loads' : '/vehicles'),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  loginFunction() async {
    setState(() {
      isLoading = !isLoading;
    });

    if (textController1.text != '' && textController2.text != '') {
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
        } catch (e) {}
        if (user['confirmed']) {
          if (user['habilitado']) {
            if (user['is_carrier']) {
              await FirebaseMessaging.instance.subscribeToTopic("new-loads");
              //ENVIAR UBICACION CUANDO CAMBIE
              LocationSettings locationSettings = const LocationSettings(
                accuracy: LocationAccuracy.best,
                distanceFilter: 5,
              );
              await sharedPreferences.setBool('pusher_connected', true);

              try {
                if (PusherApi().pusher.connectionState != '') {
                  if (PusherApi().pusher.connectionState == 'CONNECTED') {
                    PusherApi().disconnect();
                  }
                  if (PusherApi().pusher.connectionState == 'DISCONNECTED') {
                    PusherApi().init(
                        context,
                        context.read<NotificationsApi>(),
                        context.read<TransportistsLocProvider>(),
                        context.read<ChatProvider>());
                  }
                }
              } catch (e) {}
              Geolocator.getPositionStream(locationSettings: locationSettings)
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
              if (sharedPreferences.getInt('vehicles')! > 0) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/loads', ModalRoute.withName('/loads'));
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const CreateVehicleAfterReg(),
                  ),
                  ModalRoute.withName('/create-vehicle-after-registration'),
                );
              }
            } else {
              await sharedPreferences.setBool('pusher_connected', true);
              try {
                if (PusherApi().pusher.connectionState != '') {
                  if (PusherApi().pusher.connectionState == 'CONNECTED') {
                    PusherApi().disconnect();
                  }
                  if (PusherApi().pusher.connectionState == 'DISCONNECTED') {
                    PusherApi().init(
                        context,
                        context.read<NotificationsApi>(),
                        context.read<TransportistsLocProvider>(),
                        context.read<ChatProvider>(),
                        true);
                  }
                } else {
                  PusherApi().init(
                      context,
                      context.read<NotificationsApi>(),
                      context.read<TransportistsLocProvider>(),
                      context.read<ChatProvider>(),
                      true);
                }
              } catch (e) {}
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/vehicles', ModalRoute.withName('/vehicles'));
            }
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const WaitHabilitacion(),
              ),
              ModalRoute.withName('/wait-habilitacion'),
            );
          }
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ValidateCode(),
            ),
            ModalRoute.withName('/validate-code'),
          );
        }
      } else {
        setState(() {
          isLoading = !isLoading;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifique sus datos'),
          ),
        );
      }
    } else {
      setState(() {
        isLoading = !isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
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
            FormContainer(isLoading, loginFunction),
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
      ),
    );
  }
}

class FormContainer extends StatelessWidget {
  FormContainer(this.isLoading, this.loginFunction, {Key? key})
      : super(key: key);
  bool isLoading;
  var loginFunction;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
            enabled: !isLoading,
            focus: _emailFocus,
          ),
          const SizedBox(
            width: 100,
            height: 20,
          ),
          PasswordField(
            'Contraseña',
            textController2,
            enabled: !isLoading,
            onSubmit: () async {
              loginFunction();
            },
            focus: _passwordFocus,
          ),
          const SizedBox(
            width: 100,
            height: 20,
          ),
          // const LoginButton(),
          TextButton.icon(
            onPressed: (isLoading ? null : loginFunction),
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
            label: const Text('Iniciar Sesión',
                style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
                backgroundColor: isLoading
                    ? MaterialStateProperty.all(const Color(0xFFA0A0A0))
                    : MaterialStateProperty.all(const Color(0xFFED8232))),
          ),

          const SizedBox(
            width: 100,
            height: 20,
          ),

          TextButton.icon(
            onPressed: () async {
              String text = """Estos son los Datos de Mi Cuenta Eko:
Titular
LEZCANO GIMENEZ LUIS ANGEL

Banco
Familiar

Nº de Teléfono
+595982494617

Nº de Cédula
6235280

N° de cuenta para transferencias desde Banco Familiar
81-276598

N° de cuenta para transferencias desde otros bancos
81276598""";
              try {
                String url =
                    Uri.parse("whatsapp://send?phone=595982494617&text=$text")
                        .toString();
                print(url);
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw Exception('No se puede abrir whatsapp');
                }
              } catch (e) {
                print('NO SE PUEDE ABRIR WHATSAPP');
                print(e);
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Lo sentimos, no podemos abrir whatsapp. Los datos han sido copiados.'),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.whatsapp,
              color: Colors.white,
              size: 30,
            ),
            label:
                const Text('Whatsapp', style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFED8232))),
          ),
          const SizedBox(
            width: 100,
            height: 20,
          ),
          // const Text('He olvidado mi contraseña',
          //     textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
