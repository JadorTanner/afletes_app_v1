// ignore_for_file: avoid_print

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
    // if (!fromPage) {
    _pusher.onConnectionStateChange((state) {
      print('\n\n\nESTADO DE CONECCION\n\n\n');
      print(
          "previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    _pusher.onConnectionError((error) {
      print('\n\n\nERROR EN PUSHER\n\n\n');
      print("error: ${error!.message}");

      disconnect();
      init(context, notificationsApi, transportistsLocProvider, chat,
          isGenerator);
    });

    pusherChannel = _pusher.subscribe("negotiation-chat");

    //EVENTOS DEL CHAT
    bindEvent(pusherChannel!, 'App\\Events\\NegotiationChat',
        (PusherEvent? event) async {
      try {
        print('EVENTO DE CHAT');
        if (event != null) {
          print('EVENTO NO ESTA VACIO');
          if (event.data != null) {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            String data = event.data.toString();
            print('DATA DEL PUSHER: ' + data);
            print(
                'USUARIO: ' + (sharedPreferences.getString('user') ?? 'VACÍO'));
            Map jsonData = jsonDecode(data);
            if (sharedPreferences.getString('user') != null) {
              User user = User.userFromArray(
                  jsonDecode(sharedPreferences.getString('user')!));
              if (user.id != jsonData['sender_id']) {
                if (user.id == jsonData['user_id']) {
                  print('user id');
                  print(user.id);
                  print(chat);
                  print(chat.negotiationId);
                  if (jsonData['ask_location']) {
                    print('Pide ubicación');
                    if (jsonData['ask_location']) {
                      print('enviar ubicacion por pusher');
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
                    print('ESTADO DE NEGOCIACION');
                    print(chat.negState);
                    if (jsonData['normal_message'] &&
                        (chat.negState == 6 || chat.negState == 1)) {
                      chat.setCanOffer(true);
                    }
                    if (jsonData['negotiation_state'] != null) {
                      print('tiene negociacion state');
                      chat.setLoadState(jsonData['negotiation_state']);
                      if (jsonData['negotiation_state'] == 13) {
                        chat.setCanVote(true);
                      }
                    }
                    if (jsonData['is_final_offer']) {
                      print('Es una oferta final');
                      chat.setPaid(false);
                      chat.setCanOffer(false);
                      chat.setToPay(false);
                    }

                    if (jsonData['accepted'] != null) {
                      print('Se acepto la negociacion');
                      chat.setCanOffer(false);
                      chat.setToPay(true);
                      chat.setPaid(false);
                    }
                    if (jsonData['paid']) {
                      print('Se pagó la negociacion');
                      chat.setCanOffer(false);
                      chat.setToPay(false);
                      chat.setPaid(true);
                      chat.setShowDefaultMessages(true);
                      chat.setLoadState(9);
                    }
                    if (jsonData['rejected'] != null) {
                      print('Se canceló la negociacion');
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
                    if (!Platform.isAndroid) {
                      NotificationsApi.showNotification(
                        id: 21,
                        title: title,
                        body: jsonData['message'],
                        payload:
                            '{"route": "chat", "id":"${jsonData["negotiation_id"].toString()}"}',
                      );
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        print("ERROR EN PUSHER");
        print(e);
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
        print('EVENTO DE LOCATION TRANSPORTISTA');
        if (event != null) {
          if (event.data != null) {
            Map data = jsonDecode(event.data.toString());
            print('DATOS DEL EVENTO TRANSPORTISTA LOCATION: ' +
                event.data.toString());
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
