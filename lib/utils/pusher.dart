import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/loads.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PusherApi extends ChangeNotifier {
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  PusherChannelsFlutter get pusher => _pusher;
  disconnect() async {
    await _pusher.disconnect();
  }

  init(BuildContext context, NotificationsApi notificationsApi,
      TransportistsLocProvider transportistsLocProvider, ChatProvider chat,
      [bool isGenerator = false]) async {
    print('CANALES');
    print(_pusher.channels);
    if (_pusher.channels.isNotEmpty) {
      List channelNames = [];
      _pusher.channels.forEach((key, value) {
        channelNames.add(value.channelName);
      });
      for (var element in channelNames) {
        _pusher.unsubscribe(channelName: element);
      }
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (PusherApi().pusher.connectionState == 'DISCONNECTED') {
      _pusher.init(
        apiKey: Constants.pusherKey,
        cluster: 'us2',
        onConnectionStateChange: (currentState, previousState) async {
          if (currentState == 'DISCONNECTED') {
            await sharedPreferences.setBool('pusher_connected', false);
          } else if (currentState == 'CONNECTED') {
            await sharedPreferences.setBool('pusher_connected', true);
          }
        },
      );
    }
    String? userString = sharedPreferences.getString('user');
    Map? dataUser;
    if (userString != null) {
      dataUser = jsonDecode(userString);
      isGenerator = dataUser!['is_load_generator'];
    }

    await _pusher.subscribe(
      channelName: "negotiation-chat",
      onEvent: (event) async {
        print("onEvent: $event");
        if (event.eventName == 'App\\Events\\NegotiationChat') {
          try {
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
                    print('ENTRANDO');
                    if (jsonData['ask_location']) {
                      if (jsonData['ask_location']) {
                        Position position =
                            await Geolocator.getCurrentPosition();

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
                    print('PASA ASK LOCATION');
                    if ((chat.negotiationId == jsonData['negotiation_id'])) {
                      print('NEGOTIATION ID IGUAL A CONTEXT');
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

                      Api api = Api();
                      api.postData('read-notification', {
                        'negotiation_id': jsonData['negotiation_id'],
                      });

                      if (jsonData['paid']) {
                        chat.setCanOffer(false);
                        chat.setToPay(false);
                        chat.setPaid(true);
                        chat.setNegState(8);
                        chat.setLoadState(8);
                        chat.setShowDefaultMessages(true);
                      }
                      if (jsonData['normal_message'] && chat.negState == 6) {
                        chat.setCanOffer(true);
                      }
                      print('PASA NORMAL MESSAGE');
                      if (jsonData['negotiation_state'] != null) {
                        chat.setLoadState(jsonData['negotiation_state']);
                        chat.setShowDefaultMessages(true);
                        if (jsonData['negotiation_state'] == 13) {
                          chat.setShowDefaultMessages(false);
                          chat.setCanVote(true);
                        }
                      }
                      print('PASA NEG STATE');
                      if (jsonData['is_final_offer']) {
                        chat.setPaid(false);
                        chat.setCanOffer(false);
                        chat.setToPay(false);
                      }
                      print('PASA FINAL OFFER');

                      if (jsonData['accepted'] != null) {
                        chat.setCanOffer(false);
                        chat.setToPay(true);
                        chat.setPaid(false);
                      }
                      print('PASA ACCEPTED');
                      if (jsonData['rejected'] != null) {
                        chat.setCanOffer(false);
                        chat.setToPay(false);
                        chat.setPaid(false);
                      }
                      print('PASA REJECTED');
                    } else {
                      print('NEGOTIATION ID DIFERENTE A CONTEXT');
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
                      if (WidgetsBinding.instance.lifecycleState ==
                          AppLifecycleState.resumed) {
                        NotificationsApi.showNotification(
                          id: 1,
                          title: title,
                          body: jsonData['message'],
                          payload:
                              '{"route": "chat", "id":"${jsonData["negotiation_id"].toString()}"}',
                        );
                      }
                      // }
                    }
                  }
                }
              }
            }
          } catch (e) {
            print('ERROR AL RECIBIR MENSAJE');
            print(e);
            // if (!Platform.isAndroid) {
            if (WidgetsBinding.instance.lifecycleState ==
                AppLifecycleState.resumed) {
              NotificationsApi.showNotification(
                id: 11,
                title: 'Tiene un nuevo mensaje ',
                body: '',
              );
            }
            // }
          }
        }
      },
    );

    if (isGenerator) {
      await _pusher.subscribe(
        channelName: "transportist-location",
        onEvent: (event) async {
          if (event.eventName == 'App\\Events\\TransportistLocationEvent') {
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
        },
      );
    } else {
      await _pusher.subscribe(
        channelName: 'loads',
        onEvent: (event) {
          if (event.eventName == 'App\\Events\\LoadsEvent') {
            Map data = jsonDecode(event.data.toString());
            print(data);
            print('CARGAS LENGTH' + loads.length.toString());
            if (data['action'] == 'remove') {
              loads.removeWhere((element) => element.id == data['id']);
            } else if (data['action'] == 'add') {
              print('agregando carga');
              Map load = data['load'];
              loads.add(
                Load(
                  id: load['id'],
                  addressFrom: load['address'],
                  cityFromId: load['city_id'],
                  stateFromId: load['state_id'],
                  initialOffer: int.parse(
                      load['initial_offer'].toString().replaceAll('.00', '')),
                  longitudeFrom: load['longitude'],
                  latitudeFrom: load['latitude'],
                  destinLongitude: load['destination_longitude'],
                  destinLatitude: load['destination_latitude'],
                  destinAddress: load['destination_address'],
                  destinCityId: load['destination_city_id'],
                  destinStateId: load['destination_state_id'],
                  weight: double.parse(load['weight']),
                  product: load['product'] ?? '',
                  pickUpDate: load['pickup_at'],
                  pickUpTime: load['pickup_time'],
                  attachments: load['attachments'] ?? [],
                ),
              );
            }
            loadsMapKey.currentState!.setState(() {});
            print('CARGAS LENGTH' + loads.length.toString());
          }
        },
      );
    }
    _pusher.connect();

    notifyListeners();
  }
}
