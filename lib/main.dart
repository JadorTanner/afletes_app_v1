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
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

late AndroidNotificationChannel channel;
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
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
      child: AfletesApp(),
    ),
  );
}

class AfletesApp extends StatefulWidget {
  AfletesApp({Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<AfletesApp> createState() => _AfletesAppState();
}

class _AfletesAppState extends State<AfletesApp> {
  Route routes(RouteSettings settings) {
    // routes: {
    //   '/splash_screen': (context) => const SplashScreen(),
    //   '/login': (context) => const LoginPage(),
    //   '/register': (context) => const RegisterPage(),
    //   '/loads': (context) => const Loads(),
    //   '/vehicles': (context) => Vehicles(),
    //   '/my-loads': (context) => const MyLoadsPage(),
    //   '/create-load': (context) => const CreateLoadPage(),
    //   '/create-vehicle': (context) => const CreateVehicle(),
    //   '/my-vehicles': (context) => const MyVehiclesPage(),
    //   '/my-negotiations': (context) => const MyNegotiations(),
    //   '/pending-loads': (context) => const PendingLoadsPage(),
    // },
    if (settings.name != null) {
      if (settings.name!.startsWith("/negotiation_id/")) {
        try {
          int id = int.parse(settings.name!.split("/")[2]);
          print('RUTA DE NEGOCIACION A ID');
          return MaterialPageRoute(
            builder: (_) => NegotiationChat(id),
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
          );
        }
      } else if (settings.name == '/login') {
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      } else if (settings.name == '/register') {
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      } else if (settings.name == '/loads') {
        return MaterialPageRoute(builder: (_) => const Loads());
      } else if (settings.name == '/vehicles') {
        return MaterialPageRoute(builder: (_) => Vehicles());
      } else if (settings.name == '/my-loads') {
        return MaterialPageRoute(builder: (_) => const MyLoadsPage());
      } else if (settings.name == '/create-load') {
        return MaterialPageRoute(builder: (_) => CreateLoadPage(null));
      } else if (settings.name == '/create-vehicle') {
        return MaterialPageRoute(builder: (_) => const CreateVehicle());
      } else if (settings.name == '/my-vehicles') {
        return MaterialPageRoute(builder: (_) => const MyVehiclesPage());
      } else if (settings.name == '/my-negotiations') {
        return MaterialPageRoute(builder: (_) => const MyNegotiations());
      } else if (settings.name == '/pending-loads') {
        return MaterialPageRoute(builder: (_) => const PendingLoadsPage());
      }
    } else {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
      );
    }
    return MaterialPageRoute(
      builder: (_) => const SplashScreen(),
    );
  }

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

    NotificationsApi.onNotifications.stream.listen((event) async {
      Map data = jsonDecode(event!);

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? user = sharedPreferences.getString('user');
      print('#');
      print('-');
      print('#');
      print('NOTIFICATIONS API');
      print(data);
      print('#');
      print('-');
      print('#');
      if (data['route'] == 'chat') {
        print('Tiene route igual a chat');
        if (user != null && user != 'null') {
          print('Existe usuario');
          if (data['id'] != null) {
            print('tiene id');
            if (widget.navigatorKey.currentState != null) {
              print('tiene state');
              // Future.delayed(Duration.zero, () {
              //   widget.navigatorKey.currentState!.push(MaterialPageRoute(
              //     builder: (context) => NegotiationChat(data["id"]),
              //   ));
              // });
              widget.navigatorKey.currentState!
                  .pushNamed('/negotiation_id/' + data['id'].toString());
            } else {
              print('NO tiene state');
            }
          } else {
            print('NO tiene id');
            widget.navigatorKey.currentState!.pushReplacementNamed(
                jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles');
          }
        } else {
          print('NO existe usuario');
          widget.navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
        }
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => NegotiationChat(data['negotiation_id']),
        //   ),
        // );
      } else {
        print('NO tiene route igual a chat');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    NotificationsApi.init(context: context);
    listenNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      Map data = message.data;

      print('#');
      print('-');
      print('#');
      print('FIREBASE MESSAGE');
      print(data);
      print('#');
      print('-');
      print('#');
      if (notification != null && (android != null || apple != null)) {
        print('NOITIFICACION Y ANDROID O APPLE NO ESTAN VACIOS');
        if (data.keys.contains('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }

        if (Provider.of<ChatProvider>(context, listen: false).negotiationId !=
            int.parse(data['negotiation_id'])) {
          print('ID DE LA NEGOCIACION SON DIFERENTES');
          print(data);
          print([notification.title, notification.body, notification.hashCode]);
          NotificationsApi.showNotification(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            payload:
                '{"route": "chat", "id":"${data["negotiation_id"].toString()}"}',
          );
        } else {
          print('ID DE LA NEGOCIACION IGUALES');
        }
      } else {
        print('NOITIFICACION Y ANDROID O APPLE ESTAN VACIOS');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map data = message.data;

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      print('#');
      print('-');
      print('#');
      print('FIREBASE MESSAGE OPENED');
      print(message.data);
      print('#');
      print('-');
      print('#');

      if (notification != null && (android != null || apple != null)) {
        print('NOTIFICACION Y ANDROID NO NULOS');
        if (data.keys.contains('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }

        if (context.read<ChatProvider>().negotiationId !=
            data['negotiation_id']) {
          // Future.delayed(Duration.zero, () {
          // widget.navigatorKey.currentState!.push(MaterialPageRoute(
          //   builder: (context) => NegotiationChat(data["negotiation_id"]),
          // ));
          widget.navigatorKey.currentState!
              .pushNamed('/negotiation_id/' + data['negotiation_id']);
          // });
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
      // routes: {
      //   '/splash_screen': (context) => const SplashScreen(),
      //   '/login': (context) => const LoginPage(),
      //   '/register': (context) => const RegisterPage(),
      //   '/loads': (context) => const Loads(),
      //   '/vehicles': (context) => Vehicles(),
      //   '/my-loads': (context) => const MyLoadsPage(),
      //   '/create-load': (context) => const CreateLoadPage(),
      //   '/create-vehicle': (context) => const CreateVehicle(),
      //   '/my-vehicles': (context) => const MyVehiclesPage(),
      //   '/my-negotiations': (context) => const MyNegotiations(),
      //   '/pending-loads': (context) => const PendingLoadsPage(),
      // },
      onGenerateRoute: routes,
      navigatorKey: widget.navigatorKey,
    );
  }
}
