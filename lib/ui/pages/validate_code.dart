// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool validated = false;
TextEditingController codeController = TextEditingController();

class ValidateCode extends StatelessWidget {
  const ValidateCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    codeController.text = 'ABCD';
    return WillPopScope(
      onWillPop: () async {
        if (!validated) {
          try {
            if (PusherApi().pusher.connectionState != '') {
              if (PusherApi().pusher.connectionState == 'CONNECTED') {
                PusherApi().disconnect();
              }
            }
          } catch (e) {}
        }
        validated = false;
        return true;
      },
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFED8232),
          ),
          // resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ingresa el código que hemos enviado a tu correo',
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CodeInput(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ReturnBack(
                        text: 'Volver a inicio',
                      ),
                    ),
                    Flexible(child: ValidateButton())
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text('No lo has recibido?'),
                //     TextButton(
                //         onPressed: () => {},
                //         child: const Text('Reenviar código')),
                //   ],
                // ),
              ],
            ),
          )),
    );
  }
}

class CodeInput extends StatefulWidget {
  const CodeInput({Key? key}) : super(key: key);

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  FocusNode focus = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CodeSquare(focus, 0),
        CodeSquare(focus, 1),
        CodeSquare(focus, 2),
        CodeSquare(
          focus,
          3,
          last: true,
        ),
      ],
    );
  }
}

class CodeSquare extends StatelessWidget {
  CodeSquare(
    this.focus,
    this.index, {
    this.last = false,
    Key? key,
  }) : super(key: key);

  final FocusNode focus;
  bool last;
  int index;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              counter: SizedBox.shrink(),
              counterStyle: TextStyle(color: Colors.white),
            ),
            maxLength: 1,
            keyboardType: TextInputType.number,
            textInputAction: last ? TextInputAction.done : TextInputAction.next,
            onChanged: (value) {
              if (value != '') {
                List<String> newCode = codeController.text.split('');
                newCode[index] = value;
                codeController.text = newCode.join('');
                FocusScope.of(context).nextFocus();
              } else {
                if (index != 0) {
                  FocusScope.of(context).previousFocus();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class ReturnBack extends StatefulWidget {
  ReturnBack({this.text = 'Validar', Key? key}) : super(key: key);
  String text;

  @override
  State<ReturnBack> createState() => ReturnBackState();
}

class ReturnBackState extends State<ReturnBack> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFF949494)),
        padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
          ),
        ),
      ),
      onPressed: () async {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.remove('user');
        sharedPreferences.remove('token');
        sharedPreferences.clear();

        try {
          if (PusherApi().pusher.connectionState != '') {
            if (PusherApi().pusher.connectionState == 'CONNECTED') {
              PusherApi().disconnect();
            }
          }
        } catch (e) {}
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/landing',
          ModalRoute.withName('/landing'),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class ValidateButton extends StatefulWidget {
  ValidateButton({this.text = 'Validar', Key? key}) : super(key: key);
  String text;

  @override
  State<ValidateButton> createState() => ValidateButtonState();
}

class ValidateButtonState extends State<ValidateButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFFED8232)),
        padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
          ),
        ),
      ),
      // onPressed: () => {
      //       setState(() => {
      //             isLoading = !isLoading,
      //           }),
      //       Future.delayed(const Duration(seconds: 3))
      //           .then((value) => setState(() => {
      //                 isLoading = !isLoading,
      //               }))
      //     },
      onPressed: isLoading
          ? null
          : () async {
              setState(() => {
                    isLoading = !isLoading,
                  });
              Api api = Api();
              Response response = await api
                  .postData('user/verify-code', {'code': codeController.text});
              Map responseBody = jsonDecode(response.body);
              if (responseBody['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('verificado con éxito')));
                setState(() => {
                      isLoading = !isLoading,
                    });
                SharedPreferences shared =
                    await SharedPreferences.getInstance();

                shared.setString(
                    'user', jsonEncode(responseBody['data']['user']));
                validated = true;
                if (responseBody['data']['user']['habilitado']) {
                  if (responseBody['data']['user']['is_carrier']) {
                    if (responseBody['data']['cant_vehicles'] <= 0) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                const CreateVehicleAfterReg()),
                        ModalRoute.withName(
                            '/create-vehicle-after-registration'),
                      );
                    } else {
                      try {
                        if (PusherApi().pusher.connectionState != '') {
                          if (PusherApi().pusher.connectionState ==
                              'CONNECTED') {
                            PusherApi().disconnect();
                          } else if (PusherApi().pusher.connectionState ==
                              'DISCONNECTED') {
                            PusherApi().init(
                                context,
                                context.read<NotificationsApi>(),
                                context.read<TransportistsLocProvider>(),
                                context.read<ChatProvider>());
                          }
                        }
                      } catch (e) {}
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/loads',
                        ModalRoute.withName('/loads'),
                      );
                    }
                  } else {
                    try {
                      if (PusherApi().pusher.connectionState != '') {
                        if (PusherApi().pusher.connectionState == 'CONNECTED') {
                          PusherApi().disconnect();
                        } else if (PusherApi().pusher.connectionState ==
                            'DISCONNECTED') {
                          PusherApi().init(
                              context,
                              context.read<NotificationsApi>(),
                              context.read<TransportistsLocProvider>(),
                              context.read<ChatProvider>());
                        }
                      }
                    } catch (e) {}
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/vehicles',
                      ModalRoute.withName('/vehicles'),
                    );
                  }
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const WaitHabilitacion()),
                    ModalRoute.withName('/wait-habilitacion'),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(responseBody['message'])));
                setState(() => {
                      isLoading = !isLoading,
                    });
              }
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            child: !isLoading
                ? Text(
                    widget.text,
                    style: const TextStyle(color: Colors.white),
                  )
                : const SizedBox(
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
