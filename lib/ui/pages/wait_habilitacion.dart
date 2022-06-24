// ignore_for_file: must_be_immutable

import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitHabilitacion extends StatelessWidget {
  const WaitHabilitacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          if (PusherApi().pusher.connectionState != '') {
            if (PusherApi().pusher.connectionState == 'CONNECTED') {
              PusherApi().disconnect();
            }
          }
        } catch (e) {
          print('ERROR AL DESCONECTARSE EN LOGIN');
          print(e);
        }
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
              const Text(
                  'Tu cuenta está siendo verificada, te enviaremos un correo cuando tu cuenta haya sido habilitada'),
              ReturnBack(
                text: 'Volver a inicio',
              ),
            ],
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      },
      child: Text(
        widget.text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
