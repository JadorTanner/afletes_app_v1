import 'package:afletes_app_v1/models/common.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider();
  int _negotiationId = 0;
  int get negotiationId => _negotiationId;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _canOffer = true;
  bool get canOffer => _canOffer;

  bool _toPay = true;
  bool get toPay => _toPay;

  setNegotiationId(int id) {
    _negotiationId = id;
  }

  addMessage(int id, ChatMessage message) {
    // if (id == negotiationId) {
    print(message.message);
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    message.message = message.message.replaceAll(exp, '');
    _messages.insert(0, message);
    notifyListeners();
    // }
  }

  clearMessages() {
    print('limpiando');
    _messages.clear();
    notifyListeners();
  }

  setMessages(List<ChatMessage> messages) {
    messages.forEach((message) {
      print(message.message);
      _messages.insert(0, message);
    });
    notifyListeners();
  }

  setCanOffer(bool can) {
    _canOffer = can;
    notifyListeners();
  }

  setToPay(bool to) {
    _toPay = to;
    notifyListeners();
  }
}
