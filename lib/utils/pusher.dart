// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PusherApi extends ChangeNotifier {
  final PusherClient _pusher = PusherClient(
    pusherKey,
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

  init(BuildContext context, [bool isGenerator = false]) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');
    // if (!fromPage) {
    _pusher.onConnectionStateChange((state) {
      print('\n\n\nESTADO DE CONECCION\n\n\n');
      print(
          "previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    _pusher.onConnectionError((error) {
      print('\n\n\nERROR EN PUSHER\n\n\n');
      print("error: ${error!.message}");
    });

    pusherChannel = _pusher.subscribe("negotiation-chat");

    //EVENTOS DEL CHAT
    bindEvent(pusherChannel!, 'App\\Events\\NegotiationChat',
        (PusherEvent? event) async {
      if (event != null) {
        if (event.data != null) {
          print(event.data);
          ChatProvider chat = context.read<ChatProvider>();
          String data = event.data!;
          Map jsonData = jsonDecode(data);
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          String? negotiationId = sharedPreferences.getString('negotiation_id');
          User user =
              User(userData: jsonDecode(sharedPreferences.getString('user')!))
                  .userFromArray();
          Position position = await Geolocator.getCurrentPosition();
          if (user.id != jsonData['sender_id']) {
            if (user.id == jsonData['user_id']) {
              if (jsonData['ask_location'] == true) {
                Map loc = {
                  'coords': {
                    'latitude': position.latitude,
                    'longitude': position.longitude,
                  }
                };

                try {
                  Api api = Api();
                  await api.postData('user/send-location', {
                    'negotiation_id': jsonData['negotiation_id'],
                    'user_id': jsonData['sender_id'],
                    'location': loc
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Ha ocurrido un error. Compruebe su conexión a internet')));
                }
              }
              if ((chat.negotiationId == jsonData['negotiation_id']) ||
                  (negotiationId != null &&
                      int.parse(negotiationId) == jsonData['negotiation_id'])) {
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
                    jsonData['is_location'] ?? false,
                  ),
                );
                if (jsonData['negotiation_state'] != null) {
                  context
                      .read<ChatProvider>()
                      .setLoadState(jsonData['negotiation_state']);
                }
                if (jsonData['is_final_offer'] == 'true') {
                  context.read<ChatProvider>().setPaid(false);
                  context.read<ChatProvider>().setCanOffer(false);
                  context.read<ChatProvider>().setToPay(false);
                }
                if (jsonData['accepted'] != null) {
                  context.read<ChatProvider>().setCanOffer(false);
                  context.read<ChatProvider>().setToPay(true);
                  context.read<ChatProvider>().setPaid(false);
                }
              } else {
                NotificationsApi.showNotification(
                  id: 10,
                  title: 'Tiene una nueva notificación',
                  body: jsonData['message'],
                  payload:
                      '{"route": "chat", "id":${jsonData["negotiation_id"]}}',
                );
              }
            }
          }
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
            print('DATOS DE PARTE DEL GENERADOR');
            print(data);
            // TransportistsLocProvider().updateLocation(transportistId, vehicleId, latitude, longitude, heading)
            Provider.of<TransportistsLocProvider>(context).updateLocation(
              data['user_id'] ?? 0,
              data['vehicle_id'] ?? 0,
              data['latitude'] ?? '0.0',
              data['longitude'] ?? '0.0',
              data['heading'] ?? 0.0,
              data['name'] ?? '',
            );
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
