import 'package:afletes_app_v1/models/common.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({this.negotiationId = 0});
  int negotiationId;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  addMessage(int id, ChatMessage message) {
    if (id == negotiationId) {
      _messages.insert(0, message);
      notifyListeners();
    }
  }

  // setMessages(List<ChatMessage> messages) {
  //   messages.forEach((message) {
  //     _messages.insert(0, message);
  //   });
  //   notifyListeners();
  // }
}
