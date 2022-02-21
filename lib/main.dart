import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/home.dart';
import 'package:afletes_app_v1/ui/pages/loads.dart';
import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/ui/pages/register.dart';
import 'package:afletes_app_v1/ui/pages/vehicles.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

late AndroidNotificationChannel channel;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(AfletesApp());
}

class AfletesApp extends StatefulWidget {
  AfletesApp({Key? key}) : super(key: key);

  @override
  State<AfletesApp> createState() => _AfletesAppState();
}

class _AfletesAppState extends State<AfletesApp> {
  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');
    if (user != null) {
      await Api().postData('user/set-device-token',
          {'id': jsonDecode(user)['id'], 'device_token': token ?? ''});
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      print(message);
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                icon: 'launch_background',
                channelDescription: channel.description),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afletes',
      initialRoute: '/login',
      debugShowCheckedModeBanner: false,
      routes: {
        '/splashscreen': (context) => const Vehicles(),
        '/vehicles': (context) => const Vehicles(),
        '/loads': (context) => const Loads(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const Home()
      },
    );
  }
}
