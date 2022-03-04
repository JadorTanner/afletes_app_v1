import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

TextEditingController controller = TextEditingController();

startNegotiation(Load load, context) async {
  try {
    Api api = Api();

    Response response = await api.postData('negotiation/start-negotiation',
        {'load_id': load.id, 'initial_offer': controller.text});
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              NegotiationChat(jsonResponse['data']['negotiation_id'])));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compruebe su conexión a internet')));
  }
}

class LoadInfo extends StatelessWidget {
  LoadInfo(this.load, {Key? key}) : super(key: key);
  Load load;

  @override
  Widget build(BuildContext context) {
    controller.text = load.initialOffer.toString();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Text(load.id.toString()),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),
          IconButton(
            onPressed: () => startNegotiation(load, context),
            icon: Icon(Icons.check),
          )
        ],
      ),
    );
  }
}
