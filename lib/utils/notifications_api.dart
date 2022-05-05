import 'dart:convert';

import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'notificationchannel',
        'notifications',
        channelDescription: 'canal de notificaciones',
        importance: Importance.max,
        channelShowBadge: true,
      ),
      iOS: IOSNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false, context}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');
    if (user != null) {
      Provider.of<User>(context, listen: false).setUser(
        User.userFromArray(
          jsonDecode(user),
        ),
      );

      NotificationsModel().getNotifications();
    }

    const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: IOSInitializationSettings());
    await _notifications.initialize(
      settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notifications
        .show(id, title, body, await _notificationDetails(), payload: payload)
        .then((value) => print('SE HA MOSTRADO LA NOTIFICACIÓN'));
  }
}
