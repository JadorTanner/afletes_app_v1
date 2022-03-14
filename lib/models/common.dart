import 'dart:convert';

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Category {
  int? id;
  String name;
  Category({
    this.id = null,
    this.name = '',
  });
}

class StateModel {
  int? id;
  String name;
  StateModel({
    this.id = null,
    this.name = '',
  });
}

class City {
  int? id, state_id;
  String name;
  City({
    this.id = null,
    this.state_id = null,
    this.name = '',
  });
}

class Negotiation {
  int id, transportistId, generatorId, loadId, vehicleId, stateId;
  String fecha, state, withPerson;

  Load? negotiationLoad;

  Negotiation(
      {this.id = 0,
      this.generatorId = 0,
      this.transportistId = 0,
      this.loadId = 0,
      this.vehicleId = 0,
      this.stateId = 0,
      this.fecha = '',
      this.state = '',
      this.withPerson = '',
      this.negotiationLoad = null});

  //TIPOS DE MENSAJES
  // 1 - Mensaje de oferta
  sendMessage(int negotiationId, int message,
      [int type = 1, bool isFinal = false]) async {
    try {
      Api api = Api();
      return await api.postData('negotiation/send-message', {
        'message': message,
        'negotiation_id': negotiationId,
        'is_final_offer': isFinal
      });
    } catch (e) {
      return Future(() => {});
    }
  }
}

class ChatMessage {
  String message;
  int senderId, negotiationId;
  bool isImage;

  ChatMessage(this.message, this.senderId, this.negotiationId,
      [this.isImage = false]);
}
