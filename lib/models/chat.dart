import 'package:afletes_app_v1/models/common.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider();
  int _negotiationId = 0;
  int get negotiationId => _negotiationId;

  int _loadId = 0;
  int get loadId => _loadId;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _canOffer = true;
  bool get canOffer => _canOffer;

  bool _canVote = true;
  bool get canVote => _canVote;

  bool _toPay = true;
  bool get toPay => _toPay;

  bool _paid = true;
  bool get paid => _paid;

  bool _showDefaultMessages = true;
  bool get showDefaultMessages => _showDefaultMessages;

  int _loadState = 0;
  int get loadState => _loadState;

  setNegotiationId(int id) {
    _negotiationId = id;
    notifyListeners();
  }

  addMessage(int id, ChatMessage message) {
    // if (id == negotiationId) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    message.message = message.message.replaceAll(exp, '');
    _messages.insert(0, message);
    notifyListeners();
    // }
  }

  clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  setMessages(List<ChatMessage> newMessages) {
    for (var message in newMessages) {
      _messages.insert(0, message);
    }
    notifyListeners();
  }

  setCanOffer(bool can) {
    _canOffer = can;
    notifyListeners();
  }

  setCanVote(bool can) {
    _canVote = can;
    notifyListeners();
  }

  setToPay(bool to) {
    _toPay = to;
    notifyListeners();
  }

  setPaid(bool isPaid) {
    _paid = isPaid;
    notifyListeners();
  }

  setShowDefaultMessages(bool show) {
    _showDefaultMessages = show;
    notifyListeners();
  }

  setLoadId(int id) {
    _loadId = id;
    notifyListeners();
  }

  setLoadState(int newState) {
    _loadState = newState;
    notifyListeners();
  }
}
