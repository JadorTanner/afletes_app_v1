import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
      if (jsonDecode(user)['confirmed']) {
        if (jsonDecode(user)['habilitado']) {
          if (jsonDecode(user)['is_carrier']) {
            //ENVIAR UBICACION CUANDO CAMBIE
            LocationSettings locationSettings = const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 20,
            );
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position? position) {
              Api api = Api();
              api.postData('update-location', {
                'latitude': position!.latitude,
                'longitude': position.longitude,
              });
            });
          }
          Navigator.of(context).pushReplacementNamed(
              jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles');
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
