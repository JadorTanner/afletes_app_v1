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

//PERMISOS DE LOCALIZACION
Future _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.value(4);
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.value(2);
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return Future.value(1);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    // Permissions are denied forever, handle appropriately.
    return Future.value(3);
  }
}
//PERMISOS DE LOCALIZACION

/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
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
            builder: (_) => const CreateLoadPage(), settings: settings);
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
      }
    } else {
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
      );
    }

    return MaterialPageRoute(
      builder: (_) => const LoginPage(),
    );
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
        ChangeNotifierProvider<PusherApi>(
          create: (context) => PusherApi(),
        ),
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
        home: AfletesApp(navigatorKey),
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
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

class AfletesApp extends StatefulWidget {
  const AfletesApp(this.navigatorKey, {Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AfletesApp> createState() => _AfletesAppState();
}

class _AfletesAppState extends State<AfletesApp> {
  late ChatProvider chatProvider;
  late NotificationsApi notificationsApiProvider;
  changeScreen() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      FlutterNativeSplash.remove();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              children: [
                Text(
                  'Esta aplicación necesita acceder a su ubicación',
                  style: Theme.of(context).textTheme.headline4,
                ),
                const Text(
                    'Afletes recopila datos de ubicación para habilitar la búsqueda de vehículos disponibles en tiempo real, ubicación de las cargas disponibles e información de ubicación de la carga incluso cuando la aplicación está cerrada o no está en uso".')
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  int permission = await _determinePosition();
                  if (permission == 1) {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    var user = sharedPreferences.getString('user');

                    if (user != null && user != 'null') {
                      if (jsonDecode(user)['confirmed']) {
                        if (jsonDecode(user)['habilitado']) {
                          if (jsonDecode(user)['is_carrier']) {
                            //ENVIAR UBICACION CUANDO CAMBIE
                            LocationSettings locationSettings =
                                const LocationSettings(
                              accuracy: LocationAccuracy.best,
                              distanceFilter: 20,
                            );
                            Geolocator.getPositionStream(
                                    locationSettings: locationSettings)
                                .listen((Position? position) {
                              Api api = Api();
                              api.postData('update-location', {
                                'latitude': position!.latitude,
                                'longitude': position.longitude,
                                'heading': position.heading,
                              });
                            });
                          }
                          widget.navigatorKey.currentState!
                              .pushNamedAndRemoveUntil(
                            jsonDecode(user)['is_carrier']
                                ? '/loads'
                                : '/vehicles',
                            ModalRoute.withName(jsonDecode(user)['is_carrier']
                                ? '/loads'
                                : '/vehicles'),
                          );
                        } else {
                          widget.navigatorKey.currentState!.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const WaitHabilitacion(),
                            ),
                            ModalRoute.withName('/wait-habilitacion'),
                          );
                        }
                      } else {
                        widget.navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ValidateCode(),
                          ),
                          ModalRoute.withName('/wait-habilitacion'),
                        );
                      }
                    } else {
                      widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
                          '/login', ModalRoute.withName('/login'));
                    }
                  } else if (permission == 4) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: const Text(
                                  'Por favor habilite los servicios de ubicación'),
                              actions: [
                                IconButton(
                                    onPressed: () =>
                                        widget.navigatorKey.currentState!.pop(),
                                    icon: const Icon(Icons.check))
                              ],
                            )).then((value) {
                      widget.navigatorKey.currentState!.pop();
                      changeScreen();
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: const Text(
                                  'Esta aplicación require permisos de ubicación'),
                              actions: [
                                IconButton(
                                    onPressed: () =>
                                        widget.navigatorKey.currentState!.pop(),
                                    icon: const Icon(Icons.check))
                              ],
                            )).then((value) {
                      widget.navigatorKey.currentState!.pop();
                      changeScreen();
                    });
                  }
                },
                child: const Text('Acepto'),
              ),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(children: const [
                                  Text(
                                      'Para hacer uso de esta aplicación, es necesario que nos brinde permisos a su ubicación.'),
                                  Text(
                                      'Si no puede ver la solicitud, vaya a configuración > aplicaciones > afletes y borre todos los datos de la aplicación o bien, desinstale la aplicación y vuelva a instalarla.'),
                                ]),
                              ),
                            ));
                  },
                  child: const Text('No acepto'))
            ],
          );
        },
        barrierDismissible: false,
      );
    } else {
      FlutterNativeSplash.remove();
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? user = sharedPreferences.getString('user');

      if (user != null) {
        context.read<User>().setUser(User.userFromArray(jsonDecode(user)));
        if (jsonDecode(user)['confirmed']) {
          if (jsonDecode(user)['habilitado']) {
            if (jsonDecode(user)['is_carrier']) {
              await context.read<Load>().getPendingLoad(context);
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

              if (sharedPreferences.getInt('vehicles')! > 0) {
                widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  '/loads',
                  ModalRoute.withName('/loads'),
                );
              } else {
                widget.navigatorKey.currentState!.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const CreateVehicleAfterReg(),
                    ),
                    ModalRoute.withName('/create-vehicle-after-registration'));
              }
            } else {
              widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  '/vehicles', ModalRoute.withName('/vehicles'));
            }
          } else {
            widget.navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const WaitHabilitacion(),
              ),
              ModalRoute.withName('/wait-habilitacion'),
            );
          }
        } else {
          widget.navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ValidateCode(),
            ),
            ModalRoute.withName('/validate-code'),
          );
        }
      } else {
        widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
          '/login',
          ModalRoute.withName('/login'),
        );
      }
    }
  }

  listenNotifications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');

    if (user != null) {
      Map data = jsonDecode(user);
      PusherApi().init(
          context,
          notificationsApiProvider,
          context.read<TransportistsLocProvider>(),
          chatProvider,
          data['is_load_generator']);
    }

    NotificationsApi.onNotifications.stream.listen((event) async {
      Map data = jsonDecode(event!);

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? user = sharedPreferences.getString('user');

      if (data['route'] == 'chat') {
        if (user != null && user != 'null') {
          if (data['id'] != null) {
            if (widget.navigatorKey.currentState != null) {
              // Future.delayed(Duration.zero, () {
              //   widget.navigatorKey.currentState!.push(MaterialPageRoute(
              //     builder: (context) => NegotiationChat(data["id"]),
              //   ));
              // });
              widget.navigatorKey.currentState!
                  .pushNamed('/negotiation_id/' + data['id'].toString());
            } else {}
          } else {
            widget.navigatorKey.currentState!.pushNamedAndRemoveUntil(
              jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles',
              ModalRoute.withName(
                  jsonDecode(user)['is_carrier'] ? '/loads' : '/vehicles'),
            );
          }
        } else {
          widget.navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
        }
        // widget.navigatorKey.currentState!.pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => NegotiationChat(data['negotiation_id']),
        //   ),
        // );
      } else {}
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      /* if (message != null) {
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
                return true;
              }
            }

            if (data.containsKey('negotiation_id')) {
              if (chatProvider.negotiationId !=
                  int.parse(data['negotiation_id'])) {
                Navigator.of(context).pushNamed(
                    '/negotiation_id/' + data['negotiation_id'].toString());
                return true;
              }
            }
            NotificationsApi.showNotification(
              id: 50,
              title: message.notification!.title ?? 'Título',
              body: message.notification!.body ?? '',
            );
          }
        } catch (e) {}
      } */
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;
      Map data = message.data;

      try {
        if (notification != null && (android != null || apple != null)) {
          if (WidgetsBinding.instance.lifecycleState !=
              AppLifecycleState.resumed) {
            if (data.containsKey('alta')) {
              SharedPreferences shared = await SharedPreferences.getInstance();
              if (shared.getString('user') != null) {
                Map user = jsonDecode(shared.getString('user')!);
                user['habilitado'] = true;
                shared.setString('user', jsonEncode(user));
              }
            }

            if (data.containsKey('negotiation_id')) {
              if (chatProvider.negotiationId !=
                  int.parse(data['negotiation_id'])) {
                NotificationsApi.showNotification(
                  id: notification.hashCode,
                  title: notification.title,
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
                    title: notification.title,
                    body: notification.body,
                  );
                }
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
                    title: notification.title,
                    body: notification.body,
                  );
                }
              }
            }
          }
        } else {}
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

        if (chatProvider.negotiationId != data['negotiation_id']) {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NotificationsApi.init(context: context);
    chatProvider = context.read<ChatProvider>();
    notificationsApiProvider = context.read<NotificationsApi>();
    listenNotifications();

    changeScreen();
    return Scaffold(
      body: Column(
        children: const [],
      ),
    );
  }
}
