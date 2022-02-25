import 'package:afletes_app_v1/models/common.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider();
  int _negotiationId = 0;
  int get negotiationId => _negotiationId;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  setNegotiationId(int id) {
    _negotiationId = id;
  }

  addMessage(int id, ChatMessage message) {
    // if (id == negotiationId) {
    print(message.message);
    _messages.insert(_messages.isNotEmpty ? _messages.length - 1 : 0, message);
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
}
