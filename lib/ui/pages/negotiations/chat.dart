import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/chat_bubble.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<AnimatedListState> globalKey = GlobalKey<AnimatedListState>();
List<ChatMessage> chatMessages = [];
TextEditingController oferta = TextEditingController();
int receriverId = 0;
User user = User();

bool canOffer = true;

userData() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  user = User(userData: jsonDecode(sharedPreferences.getString('user')!))
      .userFromArray();
}

Future<List<ChatMessage>> getNegotiationChat(id) async {
  await userData();
  Api api = Api();
  chatMessages.clear();

  Response response = await api.getData('negotiation/?id=' + id.toString());
  if (response.statusCode == 200) {
    Map jsonResp = jsonDecode(response.body);
    List listMessages = jsonResp['data']['messages'];
    if (listMessages.isNotEmpty) {
      listMessages.asMap().forEach((key, message) {
        chatMessages.add(ChatMessage(message['message'], message['sender_id']));
      });
    }
    receriverId = jsonResp['data']['negotiation']
        [user.isCarrier ? 'generator_id' : 'transportist_id'];
    if (jsonResp['data']['negotiation_state']['id'] != 6) {
      canOffer = false;
    } else {
      canOffer = true;
    }
  }
  return [];
}

Future sendMessage(id, context) async {
  Api api = Api();
  Response response = await api.postData('negotiation/send-message', {
    'negotiation_id': id,
    'message': oferta.text,
    'is_final_offer': false,
    'user_id': receriverId
  });

  Map jsonResp = jsonDecode(response.body);
  if (jsonResp['success']) {
    chatMessages.insert(0, ChatMessage(jsonResp['data']['message'], user.id));
    globalKey.currentState!
        .insertItem(0, duration: const Duration(milliseconds: 100));
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(jsonResp['message'])));
  }
}

class NegotiationChat extends StatefulWidget {
  NegotiationChat({Key? key}) : super(key: key);

  @override
  State<NegotiationChat> createState() => _NegotiationChatState();
}

class _NegotiationChatState extends State<NegotiationChat> {
  late final arguments;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      arguments = ModalRoute.of(context)!.settings.arguments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<ChatMessage>>(
        initialData: const [],
        future: getNegotiationChat(arguments['id']),
        builder: (context, snapshot) {
          List<Widget> items = [];
          if (snapshot.connectionState == ConnectionState.done) {
            items = List.generate(
              chatMessages.length,
              (index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: chatMessages[index].senderId != user.id
                      ? MessageBubbleReceived(
                          chatMessages[index].message,
                        )
                      : MessageBubbleSent(chatMessages[index].message)),
            );
          }
          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: AnimatedList(
                  key: globalKey,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  initialItemCount: items.length,
                  itemBuilder: (context, index, animation) {
                    return SizeTransition(
                        key: UniqueKey(),
                        sizeFactor: animation,
                        child: items[index]);
                  },
                ),
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
                          onPressed: () =>
                              {sendMessage(arguments['id'], context)},
                          icon: const Icon(Icons.send),
                          splashColor: Colors.red,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ]
                    : [],
              )
            ],
          );
        },
      ),
    );
  }
}

// class ChatMessages extends StatefulWidget {
//   const ChatMessages({
//     Key? key,
//     required this.items,
//   }) : super(key: key);
//   final List<Widget> items;

//   // static updateList of(BuildContext context) => context.findAncestorStateOfType(const TypeMatcher<_StartupPageState>());

//   @override
//   State<ChatMessages> createState() => _ChatMessagesState();
// }

// class _ChatMessagesState extends State<ChatMessages> {
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedList(
//       key: globalKey,
//       reverse: true,
//       padding: const EdgeInsets.all(20),
//       initialItemCount: widget.items.length,
//       itemBuilder: (context, index, animation) => SizeTransition(
//         key: UniqueKey(),
//         sizeFactor: animation,
//         child: Card(
//             margin: const EdgeInsets.all(10),
//             elevation: 7,
//             color: Colors.orange,
//             child: widget.items[index]),
//       ),
//     );
//   }
// }
