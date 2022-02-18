import 'package:afletes_app_v1/ui/pages/home.dart';
import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/ui/pages/register.dart';
import 'package:afletes_app_v1/ui/pages/splash_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(AfletesApp());

class AfletesApp extends StatelessWidget {
  const AfletesApp({Key? key}) : super(key: key);
  // List<Map> cars = [
  //   {'domain': 'AAAA-111'},
  //   {'domain': 'AAAA-112'},
  //   {'domain': 'AAAA-113'},
  //   {'domain': 'AAAA-114'},
  //   {'domain': 'AAAA-115'},
  //   {'domain': 'AAAA-116'},
  // ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afletes',
      initialRoute: '/splash_screen',
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash_screen': (context) => SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => const Home()
      },
    );
  }
}
