// ignore_for_file: non_constant_identifier_names

import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';

class Category {
  int? id;
  String name;
  Category({
    this.id,
    this.name = '',
  });
}

class StateModel {
  int? id;
  String name;
  StateModel({
    this.id,
    this.name = '',
  });
}

class City {
  int? id, state_id;
  String name;
  City({
    this.id,
    this.state_id,
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
      this.negotiationLoad});

  static getStateName(String stateString) {
    String st = '';
    switch (stateString) {
      case 'REJECTED_BY_LOADER':
        st = 'Rechazado';
        break;
      case 'REJECTED_BY_CARRIER':
        st = 'Rechazado';
        break;
      case 'EXPIRATED':
        st = 'Expirado';
        break;
      case 'OPEN':
        st = 'Abierto';
        break;
      case 'FINISHED':
        st = 'Aceptado';
        break;
      case 'IN_NEGOTIATION':
        st = 'Aceptado';
        break;
      case 'PENDING':
        st = 'Pendiente de pago';
        break;
      case 'PAID':
        st = 'Pagado';
        break;
      default:
        st = '';
        break;
    }
    return st;
  }

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
  String message, time;
  int senderId, negotiationId;
  bool isImage;

  ChatMessage(this.message, this.time, this.senderId, this.negotiationId,
      [this.isImage = false]);
}
