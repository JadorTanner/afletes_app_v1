import 'dart:convert';

import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsApi extends ChangeNotifier {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  final List<NotificationModel> notifications = [];

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

      NotificationsApi().getNotifications(context);
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
    _notifications.show(id, title, body, await _notificationDetails(),
        payload: payload);
  }

  addNotification(NotificationModel notification) {
    notifications.add(notification);
    notifyListeners();
  }

  removeNotification(NotificationModel notification) {
    notifications.removeWhere((item) => (notification.id == item.id ||
        notification.negotiationId == item.negotiationId));
    notifyListeners();
  }

  getNotifications(BuildContext context) async {
    Api api = Api();
    Response response = await api.getData('get-notifications');
    Map jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (jsonResponse['success']) {
        List nots = jsonResponse['data'];
        notifications.clear();
        for (Map element in nots) {
          context.read<NotificationsApi>().addNotification(
                NotificationModel(
                    id: element['id'],
                    mensaje: element['mensaje']
                        .replaceAll(Constants.htmlTagRegExp, ''),
                    negotiationId: element['negotiation_id'],
                    userId: element['user_id'],
                    senderId: element['created_by'],
                    sentAt: element['created_at']),
              );
        }
      } else {
        throw Exception('Ha ocurrido un error al obtener las notificaciones');
      }
    } else {
      throw Exception('Ha ocurrido un error al obtener las notificaciones');
    }
  }

  readNotification(NotificationModel notification, BuildContext context) async {
    int id = notification.negotiationId;
    try {
      Api api = Api();
      context.read<NotificationsApi>().removeNotification(notification);
      await api.postData('read-notification', {
        'negotiation_id': id,
      });
      Navigator.of(context).pushNamed('/negotiation_id/' + id.toString());
    } catch (e) {
      Navigator.of(context).pushNamed('/my-negotiations');
      context.read<NotificationsApi>().removeNotification(notification);
    }
  }
}
