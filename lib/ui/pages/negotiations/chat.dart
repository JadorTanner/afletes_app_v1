import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:flutter/material.dart';

Future<List<ChatMessage>> getNegotiationChat() async {
  return [];
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
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments;
    return BaseApp(FutureBuilder<List<ChatMessage>>(
        initialData: const [],
        future: getNegotiationChat(),
        builder: (context, snapshot) {
          List<Widget> items = [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: items,
          );
        }));
  }
}
