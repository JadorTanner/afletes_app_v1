import 'dart:async';
import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/loads.dart';
import 'package:afletes_app_v1/ui/pages/loads/create_load.dart';
import 'package:afletes_app_v1/ui/pages/loads/my_loads.dart';
import 'package:afletes_app_v1/ui/pages/loads/pending_loads.dart';
import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/my_negotiations.dart';
import 'package:afletes_app_v1/ui/pages/register.dart';
import 'package:afletes_app_v1/ui/pages/splash_screen.dart';
import 'package:afletes_app_v1/ui/pages/vehicles.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/create_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/my_vehicles.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

late AndroidNotificationChannel channel;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('#');
  print('#');
  print('#');
  print('BACKGROUND FIREBASE MESSAGE');
  print(message.data);
  print('#');
  print('#');
  print('#');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
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
        ChangeNotifierProvider<Load>(create: (context) => Load()),
        ChangeNotifierProvider<TransportistsLocProvider>(
            create: (context) => TransportistsLocProvider()),
        ChangeNotifierProvider<User>(create: (context) => User()),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(),
        ),
        ChangeNotifierProvider<PusherApi>(
          create: (context) => PusherApi(),
        ),
      ],
      child: const AfletesApp(),
    ),
  );
}

class AfletesApp extends StatefulWidget {
  const AfletesApp({Key? key}) : super(key: key);

  @override
  State<AfletesApp> createState() => _AfletesAppState();
}

class _AfletesAppState extends State<AfletesApp> {
  listenNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');
    print('DATOS DE USUARIO ANTES DE INIT PUSHER');
    print(user);
    if (user != null) {
      Map data = jsonDecode(user);
      PusherApi().init(context, context.read<TransportistsLocProvider>(),
          context.read<ChatProvider>(), data['is_load_generator']);
    }

    NotificationsApi.onNotifications.stream.listen((event) {
      Map data = jsonDecode(event!);

      print('#');
      print('-');
      print('#');
      print('NOTIFICATIONS API');
      print(data);
      print('#');
      print('-');
      print('#');
      if (data['route'] == 'chat') {
        if (data['id'] != null) {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => NegotiationChat(data['id']),
            ));
          }
        } else {
          if (user != null && user != 'null') {
            navigatorKey.currentState!.pushReplacementNamed(
                jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles');
          } else {
            navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
          }
        }
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => NegotiationChat(data['negotiation_id']),
        //   ),
        // );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    NotificationsApi.init();
    listenNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      Map data = message.data;

      print('#');
      print('-');
      print('#');
      print('FIREBASE MESSAGE');
      print(data);
      print('#');
      print('-');
      print('#');
      if (notification != null && android != null) {
        if (data.keys.contains('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }
        if (context.read<ChatProvider>().negotiationId == 0) {
          // NotificationsApi.showNotification(
          //   id: notification.hashCode,
          //   title: notification.title,
          //   body: notification.body,
          //   payload: '{"route": "chat", "id":${data["negotiation_id"]}}',
          // );
          navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
            builder: (context) =>
                NegotiationChat(int.parse(data["negotiation_id"])),
          ));
        } else {
          if (context.read<ChatProvider>().negotiationId !=
              data['negotiation_id']) {
            navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  NegotiationChat(int.parse(data["negotiation_id"])),
            ));
            // NotificationsApi.showNotification(
            //   id: notification.hashCode,
            //   title: notification.title,
            //   body: notification.body,
            //   payload: '{"route": "chat", "id":${data["negotiation_id"]}}',
            // );
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map data = message.data;

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      print('#');
      print('-');
      print('#');
      print('FIREBASE MESSAGE OPENED');
      print(message.data);
      print('#');
      print('-');
      print('#');

      if (notification != null && android != null) {
        print('NOTIFICACION Y ANDROID NO NULOS');
        if (data.keys.contains('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }
        if (context.read<ChatProvider>().negotiationId == 0) {
          // NotificationsApi.showNotification(
          //   id: notification.hashCode,
          //   title: notification.title,
          //   body: notification.body,
          //   payload: '{"route": "chat", "id":${data["negotiation_id"]}}',
          // );

          navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
            builder: (context) =>
                NegotiationChat(int.parse(data["negotiation_id"])),
          ));
        } else {
          if (context.read<ChatProvider>().negotiationId !=
              data['negotiation_id']) {
            navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  NegotiationChat(int.parse(data["negotiation_id"])),
            ));
            // NotificationsApi.showNotification(
            //   id: notification.hashCode,
            //   title: notification.title,
            //   body: notification.body,
            //   payload: '{"route": "chat", "id":${data["negotiation_id"]}}',
            // );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afletes',
      theme: ThemeData(
        fontFamily: 'Afletes',
        dividerColor: const Color(0xBBF58633),
        primaryColor: const Color(0xFFF58633),
        backgroundColor: const Color(0xFFF58633),
        textTheme: const TextTheme(
          bodyText1:
              TextStyle(color: Color(0xFF101010), fontWeight: FontWeight.w200),
          bodyText2:
              TextStyle(color: Color(0xFF101010), fontWeight: FontWeight.w200),
          headline5: TextStyle(
            fontWeight: FontWeight.w700,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(
              color: Color(0xFFBDBDBD),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
      initialRoute: '/splash_screen',
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/loads': (context) => const Loads(),
        '/vehicles': (context) => Vehicles(),
        '/my-loads': (context) => const MyLoadsPage(),
        '/create-load': (context) => const CreateLoadPage(),
        '/create-vehicle': (context) => const CreateVehicle(),
        '/my-vehicles': (context) => const MyVehiclesPage(),
        '/my-negotiations': (context) => const MyNegotiations(),
        '/pending-loads': (context) => const PendingLoadsPage(),
      },
      navigatorKey: navigatorKey,
    );
  }
}
