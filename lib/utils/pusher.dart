import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PusherApi extends ChangeNotifier {
  final PusherClient _pusher = PusherClient(
    Constants.pusherKey,
    PusherOptions(
      encrypted: false,
      cluster: 'us2',
    ),
    autoConnect: true,
    enableLogging: true,
  );
  PusherClient get pusher => _pusher;

  Channel? pusherChannel;
  Channel? transportistsLocationChannel;

  disconnect() {
    pusher.cancelEventChannelStream();
    pusher.disconnect();
  }

  init(BuildContext context, NotificationsApi notificationsApi,
      TransportistsLocProvider transportistsLocProvider, ChatProvider chat,
      [bool isGenerator = false]) async {
    _pusher.onConnectionError((error) {
      disconnect();
      init(context, notificationsApi, transportistsLocProvider, chat,
          isGenerator);
    });

    pusherChannel = _pusher.subscribe("negotiation-chat");

    //EVENTOS DEL CHAT
    bindEvent(pusherChannel!, 'App\\Events\\NegotiationChat',
        (PusherEvent? event) async {
      try {
        if (event != null) {
          if (event.data != null) {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            String data = event.data.toString();

            Map jsonData = jsonDecode(data);
            if (sharedPreferences.getString('user') != null) {
              User user = User.userFromArray(
                  jsonDecode(sharedPreferences.getString('user')!));
              if (user.id != jsonData['sender_id']) {
                if (user.id == jsonData['user_id']) {
                  if (jsonData['ask_location']) {
                    if (jsonData['ask_location']) {
                      Position position = await Geolocator.getCurrentPosition();

                      Api api = Api();
                      api.postData('update-location', {
                        'latitude': position.latitude,
                        'longitude': position.longitude,
                        'heading': position.heading,
                      });

                      Map loc = {
                        'coords': {
                          'latitude': position.latitude,
                          'longitude': position.longitude,
                          'heading': position.heading,
                        }
                      };

                      try {
                        Api api = Api();
                        api.postData(
                          'user/send-location',
                          {
                            'negotiation_id': jsonData['negotiation_id'],
                            'user_id': jsonData['sender_id'],
                            'location': loc,
                          },
                        );
                      } on SocketException {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compruebe su conexión a internet'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ha ocurrido un error'),
                          ),
                        );
                      }
                    }
                  }
                  if ((chat.negotiationId == jsonData['negotiation_id'])) {
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('y-dd-MM kk:mm:ss').format(now);
                    chat.addMessage(
                      jsonData['negotiation_id'],
                      ChatMessage(
                        jsonData['message'],
                        formattedDate,
                        jsonData['sender_id'],
                        jsonData['negotiation_id'],
                        jsonData['is_location'],
                      ),
                    );

                    if (jsonData['normal_message'] &&
                        (chat.negState == 6 || chat.negState == 1)) {
                      chat.setCanOffer(true);
                    }
                    if (jsonData['negotiation_state'] != null) {
                      chat.setLoadState(jsonData['negotiation_state']);
                      if (jsonData['negotiation_state'] == 13) {
                        chat.setCanVote(true);
                      }
                    }
                    if (jsonData['is_final_offer']) {
                      chat.setPaid(false);
                      chat.setCanOffer(false);
                      chat.setToPay(false);
                    }

                    if (jsonData['accepted'] != null) {
                      chat.setCanOffer(false);
                      chat.setToPay(true);
                      chat.setPaid(false);
                    }
                    if (jsonData['paid']) {
                      chat.setCanOffer(false);
                      chat.setToPay(false);
                      chat.setPaid(true);
                      chat.setShowDefaultMessages(true);
                      chat.setLoadState(9);
                    }
                    if (jsonData['rejected'] != null) {
                      chat.setCanOffer(false);
                      chat.setToPay(false);
                      chat.setPaid(false);
                    }
                  } else {
                    String title = 'Tiene una nueva notificación';
                    if (jsonData['is_final_offer'] != null) {
                      if (jsonData['is_final_offer'].runtimeType == bool) {
                        if (jsonData['is_final_offer']) {
                          title = 'Ha recibido una oferta final';
                        }
                      }
                    }
                    if (jsonData['accepted'] != null) {
                      title = 'La negociación ha sido aceptada';
                    }
                    if (jsonData['paid']) {
                      title = 'La negociación ha sido pagada';
                    }
                    if (jsonData['rejected'] != null) {
                      title = 'La negociación ha sido rechazada';
                    }
                    DateTime now = DateTime.now();
                    String formattedDate =
                        DateFormat('y-M-d kk:mm').format(now);
                    notificationsApi.addNotification(
                      NotificationModel(
                        mensaje: jsonData['message']
                            .replaceAll(Constants.htmlTagRegExp, ''),
                        negotiationId: jsonData['negotiation_id'],
                        userId: jsonData['user_id'],
                        senderId: jsonData['sender_id'],
                        id: 1,
                        sentAt: formattedDate,
                      ),
                    );
                    // if (!Platform.isAndroid) {
                    NotificationsApi.showNotification(
                      id: 21,
                      title: title,
                      body: jsonData['message'],
                      payload:
                          '{"route": "chat", "id":"${jsonData["negotiation_id"].toString()}"}',
                    );
                    // }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        if (!Platform.isAndroid) {
          NotificationsApi.showNotification(
            id: 11,
            title: 'Tiene un nuevo mensaje ',
            body: '',
          );
        }
      }
    });
    // } else {
    //   //EVENTOS DEL CHAT
    //   //EVENTOS DE UBICACION DE TRANSPORTISTAS

    // }

    if (isGenerator) {
      Channel transportistsLocationChannel =
          pusher.subscribe("transportist-location");
      bindEvent(transportistsLocationChannel,
          'App\\Events\\TransportistLocationEvent', (PusherEvent? event) async {
        if (event != null) {
          if (event.data != null) {
            Map data = jsonDecode(event.data.toString());
            if (data['isLoggingOut']) {
              transportistsLocProvider.removeTransportist(
                  data['user_id'], data['vehicle_id']);
            } else {
              // TransportistsLocProvider().updateLocation(transportistId, vehicleId, latitude, longitude, heading)
              transportistsLocProvider.updateLocation(
                data['user_id'] ?? 0,
                data['vehicle_id'] ?? 0,
                double.parse((data['latitude'] != null
                    ? data['latitude'].toString()
                    : '0.0')),
                double.parse((data['longitude'] != null
                    ? data['longitude'].toString()
                    : '0.0')),
                double.parse((data['heading'] != null
                    ? data['heading'].toString()
                    : '0.0')),
                data['name'] ?? '',
              );
            }
          }
        }
      });
    }
    notifyListeners();
  }

  bindEvent(channel, eventName, callback) async {
    channel.bind(eventName, (PusherEvent? event) async {
      callback(event);
    });
  }

  triggerEvent(eventName, data) {
    pusherChannel!.trigger(eventName, data);
  }
}
