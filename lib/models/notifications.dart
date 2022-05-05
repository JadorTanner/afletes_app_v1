import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

class NotificationsModel extends ChangeNotifier {
  int id, negotiationId, userId, senderId;
  String mensaje, sentAt;
  NotificationsModel({
    this.id = 0,
    this.senderId = 0,
    this.mensaje = '',
    this.sentAt = '',
    this.negotiationId = 0,
    this.userId = 0,
  });

  final List<NotificationsModel> notifications = [];
  // List<NotificationsModel> get notifications => notifications;

  addNotification(NotificationsModel notification) {
    try {
      print('AGREGANDO UNA NUEVA NOTIFICACION');
      notifications.add(notification);
      notifyListeners();
    } catch (e) {
      print('ERROR AL AGREGAR UNA NOTIFICACION');
      print(e);
    }
  }

  removeNotification(NotificationsModel notification) {
    try {
      notifications.removeWhere((item) => (notification.id == item.id ||
          notification.negotiationId == item.negotiationId));
      notifyListeners();
    } catch (e) {}
  }

  getNotifications() async {
    try {
      Api api = Api();
      Response response = await api.getData('get-notifications');
      print(response.body);
      Map jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['success']) {
          List nots = jsonResponse['data'];
          notifications.clear();
          for (Map element in nots) {
            addNotification(
              NotificationsModel(
                  id: element['id'],
                  mensaje: element['mensaje']
                      .replaceAll(Constants.htmlTagRegExp, ''),
                  negotiationId: element['negotiation_id'],
                  userId: element['user_id'],
                  senderId: element['created_by'],
                  sentAt: const Time().toString()),
            );
          }
        } else {
          throw Exception('Ha ocurrido un error al obtener las notificaciones');
        }
      } else {
        throw Exception('Ha ocurrido un error al obtener las notificaciones');
      }
    } catch (e) {
      print(e);
    }
  }

  readNotification(
      NotificationsModel notification, BuildContext context) async {
    try {
      Api api = Api();
      api.postData('read-notification', {
        'negotiation_id': notification.negotiationId,
      });
      Navigator.of(context).pushNamed(
          '/negotiation_id/' + notification.negotiationId.toString());
    } catch (e) {
      Navigator.of(context).pushNamed('/my-negotiations');
    }
  }
}
