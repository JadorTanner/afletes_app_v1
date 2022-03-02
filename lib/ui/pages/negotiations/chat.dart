import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/chat_bubble.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/payment.dart';
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

late bool canOffer;

userData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  user = User(userData: jsonDecode(sharedPreferences.getString('user')!))
      .userFromArray();
}

Future<List<ChatMessage>> getNegotiationChat(id, BuildContext context) async {
  await userData();
  Api api = Api();

  context.read<ChatProvider>().clearMessages();
  context.read<ChatProvider>().setNegotiationId(id);
  // context.read<ChatProvider>().messages.forEach((element) {
  //   globalKey.currentState != null
  //       ? globalKey.currentState!
  //           .removeItem(0, (context, animation) => const SizedBox.shrink())
  //       : null;
  // });

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
        // globalKey.currentState!
        //     .insertItem(0, duration: const Duration(milliseconds: 100));
      });
    }
    receiverId = jsonResp['data']['negotiation']
        [user.isCarrier ? 'generator_id' : 'transportist_id'];
    if (jsonResp['data']['negotiation_state']['id'] != 6) {
      context.read<ChatProvider>().setCanOffer(false);
    } else {
      context.read<ChatProvider>().setCanOffer(true);
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
    // globalKey.currentState!
    //     .insertItem(0, duration: const Duration(milliseconds: 100));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(jsonResp['message']),
      duration: const Duration(seconds: 3),
    ));
  }
}

Future cancelNegotiation(id) async {
  Api api = Api();
  Response response = await api.postData('negotiation/reject', {
    'id': id,
  });

  print(response.body);
}

Future acceptNegotiation(id, context) async {
  Api api = Api();
  Response response = await api.postData('negotiation/accept', {
    'id': id,
  });

  print(response.body);
  if (response.statusCode == 200) {
    if (user.isLoadGenerator) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Payment(id),
      ));
    }
  }
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
            OfferInputSection(widget: widget),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => acceptNegotiation(widget.id, context),
                  icon: const Icon(Icons.check),
                  label: const Text('Aceptar'),
                ),
                TextButton.icon(
                  onPressed: () => cancelNegotiation(widget.id),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rechazar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OfferInputSection extends StatelessWidget {
  const OfferInputSection({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final NegotiationChat widget;

  @override
  Widget build(BuildContext context) {
    canOffer = context.watch<ChatProvider>().canOffer;
    return Row(
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
                  sendMessage(widget.id, context, context.read<ChatProvider>())
                },
                icon: const Icon(Icons.send),
                splashColor: Colors.red,
              ),
              const SizedBox(
                width: 20,
              ),
            ]
          : [],
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
    List<ChatMessage> chat = context.watch<ChatProvider>().messages;
    return ListView(
      reverse: true,
      children: List.generate(
          chat.length,
          (index) => chat[index].senderId != user.id
              ? MessageBubbleReceived(
                  chat[index].message,
                )
              : MessageBubbleSent(chat[index].message)),
    );
    // return AnimatedList(
    //   key: globalKey,
    //   reverse: true,
    //   padding: const EdgeInsets.all(20),
    //   itemBuilder: (context, index, animation) {
    //     return SizeTransition(
    //       key: UniqueKey(),
    //       sizeFactor: animation,
    //       child: chat[index].senderId != user.id
    //           ? MessageBubbleReceived(
    //               chat[index].message,
    //             )
    //           : MessageBubbleSent(chat[index].message),
    //     );
    //   },
    // );
  }
}
