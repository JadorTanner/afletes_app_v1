import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/chat_bubble.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

GlobalKey<AnimatedListState> globalKey = GlobalKey<AnimatedListState>();
TextEditingController oferta = TextEditingController();
int receiverId = 0;
User user = User();
List<ChatMessage> messages = [];

bool canOffer = true;

userData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  user = User(userData: jsonDecode(sharedPreferences.getString('user')!))
      .userFromArray();
}

Future<List<ChatMessage>> getNegotiationChat(id, BuildContext context) async {
  await userData();
  Api api = Api();
  context.read<ChatProvider>().clearMessages();

  Response response = await api.getData('negotiation/?id=' + id.toString());
  if (response.statusCode == 200) {
    Map jsonResp = jsonDecode(response.body);
    List listMessages = jsonResp['data']['messages'];
    if (listMessages.isNotEmpty) {
      listMessages.asMap().forEach((key, message) {
        // messages.add(ChatMessage(
        //     message['message'], message['sender_id'], message['id']));
        context.read<ChatProvider>().addMessage(
            id,
            ChatMessage(
                message['message'], message['sender_id'], message['id']));
        globalKey.currentState!.insertItem(
            context.read<ChatProvider>().messages.length - 1,
            duration: const Duration(milliseconds: 100));
      });
    }
    receiverId = jsonResp['data']['negotiation']
        [user.isCarrier ? 'generator_id' : 'transportist_id'];
    if (jsonResp['data']['negotiation_state']['id'] != 6) {
      canOffer = false;
    } else {
      canOffer = true;
    }
  }
  return [];
}

Future sendMessage(id, BuildContext context, ChatProvider chat) async {
  Api api = Api();
  Response response = await api.postData('negotiation/send-message', {
    'negotiation_id': id,
    'message': oferta.text,
    'is_final_offer': false,
    'user_id': receiverId
  });

  Map jsonResp = jsonDecode(response.body);
  if (jsonResp['success']) {
    // chatMessages.insert(0, ChatMessage(jsonResp['data']['message'], user.id));
    // context.read<ChatProvider>().addMessage(id, jsonResp['data']['message']);
    chat.addMessage(id, ChatMessage(jsonResp['data']['message'], user.id, id));
    globalKey.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 100));
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(jsonResp['message'])));
  }
}

Future cancelNegotiation(id) async {
  Api api = Api();
  Response response = await api.postData('negotiation/reject', {
    'id': id,
  });

  print(response.body);
}

class NegotiationChat extends StatefulWidget {
  NegotiationChat(this.id, {Key? key}) : super(key: key);
  int id;
  @override
  State<NegotiationChat> createState() => _NegotiationChatState();
}

class _NegotiationChatState extends State<NegotiationChat> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getNegotiationChat(widget.id, context),
      builder: (context, snapshot) => BaseApp(
        ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: ChatPanel(),
            ),
            Row(
              children: canOffer
                  ? [
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                          child: TextField(
                        controller: oferta,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Oferto'),
                      )),
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        onPressed: () => {
                          sendMessage(
                              widget.id, context, context.read<ChatProvider>())
                        },
                        icon: const Icon(Icons.send),
                        splashColor: Colors.red,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ]
                  : [],
            ),
            ButtonBar(
              children: [
                IconButton(onPressed: () => {}, icon: Icon(Icons.check)),
                IconButton(
                    onPressed: () => cancelNegotiation(widget.id),
                    icon: Icon(Icons.cancel)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ChatPanel extends StatefulWidget {
  ChatPanel({Key? key}) : super(key: key);

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  @override
  Widget build(BuildContext context) {
    ChatProvider chat = context.watch<ChatProvider>();
    return AnimatedList(
      key: globalKey,
      reverse: true,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index, animation) {
        return SizeTransition(
          key: UniqueKey(),
          sizeFactor: animation,
          child: chat.messages[index].senderId != user.id
              ? MessageBubbleReceived(
                  chat.messages[index].message,
                )
              : MessageBubbleSent(chat.messages[index].message),
        );
      },
    );
  }
}
