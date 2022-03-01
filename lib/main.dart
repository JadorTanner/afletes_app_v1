import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/home.dart';
import 'package:afletes_app_v1/ui/pages/loads.dart';
import 'package:afletes_app_v1/ui/pages/loads/create_load.dart';
import 'package:afletes_app_v1/ui/pages/loads/my_loads.dart';
import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/my_negotiations.dart';
import 'package:afletes_app_v1/ui/pages/register.dart';
import 'package:afletes_app_v1/ui/pages/splash_screen.dart';
import 'package:afletes_app_v1/ui/pages/vehicles.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/create_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/my_vehicles.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

late AndroidNotificationChannel channel;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
PusherOptions options = PusherOptions(
  encrypted: false,
  cluster: 'us2',
);
PusherClient pusher =
    PusherClient(pusherKey, options, autoConnect: true, enableLogging: true);

//PERMISOS DE LOCALIZACION

Future _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Servicios de localizacion están deshabilitadas.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Se ha denegado el permiso.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error('Permisos denegados completamente.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
}
//PERMISOS DE LOCALIZACION

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatProvider>(
            create: (context) => ChatProvider())
      ],
      child: AfletesApp(),
    ),
  );
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
      Response response = await Api().postData('user/set-device-token',
          {'id': jsonDecode(user)['id'], 'device_token': token ?? ''});
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
    pusher.onConnectionStateChange((state) {
      print(
          "previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      print("error: ${error!.message}");
    });

// Subscribe to a private channel
    Channel pusherChannel = pusher.subscribe("negotiation-chat");

// Bind to listen for events called "order-status-updated" sent to "private-orders" channel
    pusherChannel.bind('App\\Events\\NegotiationChat',
        (PusherEvent? event) async {
      print(event);
      print(event!.data);
      Map jsonData = jsonDecode(event.data!);
      print(jsonData);
      ChatProvider chat = context.read<ChatProvider>();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      User user =
          User(userData: jsonDecode(sharedPreferences.getString('user')!))
              .userFromArray();
      print(user.id);
      if (user.id != jsonData['sender_id']) {
        if (chat.negotiationId == jsonData['negotiation_id']) {
          chat.addMessage(
            jsonData['negotiation_id'],
            ChatMessage(jsonData['message'], jsonData['sender_id'],
                jsonData['negotiation_id']),
          );
        }
      }
    });

    _determinePosition();
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
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
              channelDescription: channel.description,
            ),
          ),
        );
      }
    });
  }

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
        '/home': (context) => const Home(),
        '/loads': (context) => const Loads(),
        '/vehicles': (context) => Vehicles(),
        '/my-loads': (context) => MyLoadsPage(),
        '/create-load': (context) => CreateLoadPage(),
        '/create-vehicle': (context) => CreateVehicle(),
        '/my-vehicles': (context) => MyVehiclesPage(),
        '/my-negotiations': (context) => MyNegotiations(),
      },
    );
  }
}
