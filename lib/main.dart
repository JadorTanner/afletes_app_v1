import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/utils/constants.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/landing.dart';
import 'package:afletes_app_v1/ui/pages/loads.dart';
import 'package:afletes_app_v1/ui/pages/loads/create_load.dart';
import 'package:afletes_app_v1/ui/pages/loads/my_loads.dart';
import 'package:afletes_app_v1/ui/pages/loads/pending_loads.dart';
import 'package:afletes_app_v1/ui/pages/login.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/my_negotiations.dart';
import 'package:afletes_app_v1/ui/pages/notifications.dart';
import 'package:afletes_app_v1/ui/pages/register.dart';
import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/ui/pages/vehicles.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/create_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/vehicles/my_vehicles.dart';
import 'package:afletes_app_v1/ui/pages/wait_habilitacion.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    if (message.data.containsKey('negotiation_id')) {
      try {
        navigatorKey.currentState!.pushNamed(
            '/negotiation_id/' + message.data['negotiation_id'].toString());
      } catch (e) {}
    }
  });
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  /// To verify things are working, check out the native platform logs.

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
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  } else {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
  }

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? userString = sharedPreferences.getString('user');
    if (userString != null) {
      Map user = jsonDecode(userString);
      Api().postData('user/set-device-token', {
        'id': user['id'],
        'device_token': FirebaseMessaging.instance.getToken()
      });
    }
  });

  Route routes(RouteSettings settings) {
    if (settings.name != null) {
      if (settings.name!.startsWith("/negotiation_id/")) {
        try {
          int id = int.parse(settings.name!.split("/")[2]);

          return MaterialPageRoute(
            builder: (_) => NegotiationChat(id),
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
          );
        }
      } else if (settings.name == '/landing') {
        return MaterialPageRoute(
          builder: (_) => const LandingPage(),
        );
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
      } else if (settings.name == '/notifications') {
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      } else if (settings.name == '/create-load') {
        return MaterialPageRoute(
            builder: (_) => CreateLoadPage(), settings: settings);
      } else if (settings.name == '/create-vehicle') {
        return MaterialPageRoute(
            builder: (_) => const CreateVehicle(), settings: settings);
      } else if (settings.name == '/my-vehicles') {
        return MaterialPageRoute(builder: (_) => const MyVehiclesPage());
      } else if (settings.name == '/my-negotiations' ||
          settings.name!.startsWith("/my-negotiations")) {
        try {
          if (settings.name!.split("?").length > 1) {
            String status = settings.name!.split("?")[1];
            return MaterialPageRoute(
                builder: (_) => MyNegotiations(payment: status.split('=')[1]));
          } else {
            return MaterialPageRoute(builder: (_) => MyNegotiations());
          }
        } catch (e) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
          );
        }
      } else if (settings.name == '/pending-loads') {
        return MaterialPageRoute(builder: (_) => const PendingLoadsPage());
      } else if (settings.name == '/create-vehicle-after-registration') {
        return MaterialPageRoute(builder: (_) => const CreateVehicleAfterReg());
      } else if (settings.name == '/wait-habilitacion') {
        return MaterialPageRoute(builder: (_) => const WaitHabilitacion());
      } else if (settings.name == '/validate-code') {
        return MaterialPageRoute(builder: (_) => const ValidateCode());
      } else {
        return MaterialPageRoute(
          builder: (_) => const AfletesApp(),
        );
      }
    } else {
      return MaterialPageRoute(
        builder: (_) => const AfletesApp(),
      );
    }
  }

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
        // ChangeNotifierProvider<PusherApi>(
        //   create: (context) => PusherApi(),
        // ),
        ChangeNotifierProvider<NotificationsApi>(
          create: (context) => NotificationsApi(),
        ),
      ],
      child: MaterialApp(
        title: 'Afletes',
        theme: ThemeData(
          fontFamily: 'Afletes',
          dividerColor: const Color(0xBBF58633),
          primaryColor: const Color(0xFFF58633),
          backgroundColor: const Color(0xFFF58633),
          textTheme: const TextTheme(
            bodyText1: TextStyle(
                color: Color(0xFF101010), fontWeight: FontWeight.w200),
            bodyText2: TextStyle(
                color: Color(0xFF101010), fontWeight: FontWeight.w200),
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
        onGenerateRoute: routes,
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return child!;
        },
        // home: WillPopScope(
        //   onWillPop: () async {
        //     return !await navigatorKey.currentState!.maybePop();
        //   },
        //   child: LayoutBuilder(
        //     builder: (context, constraints) {
        //       return Navigator(
        //         key: navigatorKey,
        //         onGenerateRoute: routes,
        //       );
        //     },
        //   ),
        // ),
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
      ),
    ),
  );
}

class AfletesApp extends StatefulWidget {
  const AfletesApp({Key? key}) : super(key: key);

  @override
  State<AfletesApp> createState() => _AfletesAppState();
}

class _AfletesAppState extends State<AfletesApp>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late ChatProvider chatProvider;
  late NotificationsApi notificationsApiProvider;
  changeScreen() async {
    FlutterNativeSplash.remove();
    // If the system can show an authorization request dialog
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
        TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Esta aplicación utiliza información sensible',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    'Por motivos de funcionamiento de la aplicación y de seguridad para usted y los demás usuarios, afletes recopila datos como su nombre, email, dirección física y ubicación. Sus fotos son accesibles solo al momento de realizar una carga o crear un nuevo vehículo.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Estos datos son guardados de manera segura y no son publicados, compartidos ni utilizados con fines de lucro.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ),
          );
        },
      );
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      await AppTrackingTransparency.requestTrackingAuthorization();
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');

    if (user != null) {
      // if (permission == LocationPermission.always ||
      //     permission == LocationPermission.whileInUse) {
      context.read<User>().setUser(User.userFromArray(jsonDecode(user)));
      context.read<User>().setOnline(jsonDecode(user)['online']);
      int permission = await Constants.determinePosition();
      if (permission == 1) {
        context.read<User>().setLocationEnabled(true);
        LocationSettings locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
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
      if (jsonDecode(user)['confirmed']) {
        if (jsonDecode(user)['habilitado']) {
          if (jsonDecode(user)['is_carrier']) {
            // await context.read<Load>().getPendingLoad(context);
            //ENVIAR UBICACION CUANDO CAMBIE

            if (sharedPreferences.getInt('vehicles')! > 0) {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                '/loads',
                ModalRoute.withName('/loads'),
              );
            } else {
              navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const CreateVehicleAfterReg(),
                  ),
                  ModalRoute.withName('/create-vehicle-after-registration'));
            }
          } else {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
                '/vehicles', ModalRoute.withName('/vehicles'));
          }
        } else {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const WaitHabilitacion(),
            ),
            ModalRoute.withName('/wait-habilitacion'),
          );
        }
      } else {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ValidateCode(),
          ),
          ModalRoute.withName('/validate-code'),
        );
      }
      // } else {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) {
      //         return LocationPermissions(route: '/login');
      //       },
      //     ),
      //   );
      // }
    } else {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        '/landing',
        ModalRoute.withName('/landing'),
      );
    }
  }

  listenNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');

    if (user != null) {
      PusherApi().init(
        context,
        context.read<NotificationsApi>(),
        context.read<TransportistsLocProvider>(),
        context.read<ChatProvider>(),
      );
    }

    NotificationsApi.onNotifications.stream.listen((event) async {
      Map data = jsonDecode(event!);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? user = sharedPreferences.getString('user');

      if (data['route'] == 'chat') {
        if (user != null && user != 'null') {
          if (data['id'] != null) {
            if (navigatorKey.currentState != null) {
              // Future.delayed(Duration.zero, () {
              //   navigatorKey.currentState!.push(MaterialPageRoute(
              //     builder: (context) => NegotiationChat(data["id"]),
              //   ));
              // });
              navigatorKey.currentState!
                  .pushNamed('/negotiation_id/' + data['id'].toString());
            } else {}
          } else {
            navigatorKey.currentState!.pushNamedAndRemoveUntil(
              jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles',
              ModalRoute.withName(
                  jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles'),
            );
          }
        } else {
          navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
        }
        // navigatorKey.currentState!.pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => NegotiationChat(data['negotiation_id']),
        //   ),
        // );
      } else {}
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      if (message != null) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        AppleNotification? apple = message.notification?.apple;
        Map data = message.data;

        try {
          if (notification != null && (android != null || apple != null)) {
            if (data.containsKey('alta')) {
              SharedPreferences shared = await SharedPreferences.getInstance();
              if (shared.getString('user') != null) {
                Map user = jsonDecode(shared.getString('user')!);
                user['habilitado'] = true;
                shared.setString('user', jsonEncode(user));
              }
            }

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              if (data.containsKey('negotiation_id')) {
                if (chatProvider.negotiationId !=
                    int.parse(data['negotiation_id'])) {
                  // NotificationsApi.showNotification(
                  //     id: 50,
                  //     title: message.notification!.title ?? 'Título',
                  //     body: message.notification!.body ?? '',
                  //     payload:
                  //         '{"route": "chat", "id":"${data["negotiation_id"].toString()}"}');
                  Navigator.of(context).pushNamed(
                      '/negotiation_id/' + data['negotiation_id'].toString());
                }
              }
            });
          }
        } catch (e) {}
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      Map data = message.data;

      try {
        if (notification == null && (android == null && apple == null)) {
          return;
        }
        if (data.containsKey('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }

        if (data.containsKey('negotiation_id')) {
          if (chatProvider.negotiationId != int.parse(data['negotiation_id'])) {
            NotificationsApi.showNotification(
              id: 1,
              title: notification!.title,
              body: notification.body,
              payload:
                  '{"route": "chat", "id":"${data["negotiation_id"].toString()}"}',
            );
          }
        }
        if (message.from == '/topics/new-loads' ||
            message.from == 'new-loads') {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            if (user['is_carrier']) {
              NotificationsApi.showNotification(
                id: notification.hashCode,
                title: notification!.title,
                body: notification.body,
              );
            }
          }
        }
      } catch (e) {}
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      Map data = message.data;

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      if (notification != null && (android != null || apple != null)) {
        if (data.keys.contains('alta')) {
          SharedPreferences shared = await SharedPreferences.getInstance();
          if (shared.getString('user') != null) {
            Map user = jsonDecode(shared.getString('user')!);
            user['habilitado'] = true;
            shared.setString('user', jsonEncode(user));
          }
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (data.containsKey('negotiation_id')) {
            navigatorKey.currentState!
                .pushNamed('/negotiation_id/' + data['negotiation_id']);
          }
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      try {
        PusherApi().disconnect();
      } catch (e) {}
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    notificationsApiProvider = context.read<NotificationsApi>();
    WidgetsBinding.instance.addObserver(this);
    NotificationsApi.init(context: context);
    listenNotifications();
    changeScreen();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // changeScreen();
    return Scaffold(
      body: Center(
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
