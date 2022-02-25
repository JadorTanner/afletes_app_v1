import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

List<Negotiation> negotiations = [];

Future<List<Negotiation>> getNegotiations() async {
  Api api = Api();
  negotiations.clear();

  Response response = await api.getData('user/my-negotiations');
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      List data = jsonResponse['data'];
      data.asMap().forEach((key, negotiation) {
        negotiations.add(Negotiation(
            id: negotiation['id'],
            transportistId: negotiation['transportist_id'],
            generatorId: negotiation['generator_id'],
            vehicleId: negotiation['vehicle_id'],
            stateId: negotiation['negotiation_state_id'],
            fecha: negotiation['fecha'],
            negotiationLoad: Load(
                product: negotiation['negotiation_load'] != null
                    ? negotiation['negotiation_load']['product']
                    : '')));
      });
    }
  }
  return negotiations;
}

class MyNegotiations extends StatefulWidget {
  MyNegotiations({Key? key}) : super(key: key);

  @override
  State<MyNegotiations> createState() => _MyNegotiationsState();
}

class _MyNegotiationsState extends State<MyNegotiations> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(FutureBuilder<List<Negotiation>>(
        initialData: const [],
        future: getNegotiations(),
        builder: (context, snapshot) {
          List items = [];
          if (snapshot.connectionState == ConnectionState.done) {
            items = List.generate(
                negotiations.length,
                (index) => NegotiationCard(
                      index,
                      hasData: true,
                    ));
          } else {
            items = List.generate(
              5,
              (index) => NegotiationCard(
                index,
                hasData: false,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/vehicles'),
                  icon: const Icon(Icons.add),
                  label: const Text('Buscar transportistas')),
              ...items
            ],
          );
        }));
  }
}

class NegotiationCard extends StatelessWidget {
  NegotiationCard(
    this.index, {
    this.hasData = false,
    Key? key,
  }) : super(key: key);
  int index;
  bool hasData;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 10,
      child: GestureDetector(
        onTap: hasData
            ? () => {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        NegotiationChat(negotiations[index].id),
                  ))
                }
            : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Row(
            children: [
              CircleAvatar(
                maxRadius: 50,
                minRadius: 50,
                backgroundColor: Colors.white,
                child: Text(hasData
                    ? negotiations[index].negotiationLoad!.product
                    : ''),
              ),
              Column(
                children: [
                  hasData
                      ? Text(negotiations[index].negotiationLoad!.product != ''
                          ? negotiations[index].negotiationLoad!.product
                          : 'Producto')
                      : CustomPaint(
                          painter: OpenPainter(100, 10, 10, -10),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      hasData
                          ? Text('Algo')
                          : CustomPaint(
                              painter: OpenPainter(50, 10, 10, 20),
                            ),
                      hasData
                          ? Text('Algo más')
                          : CustomPaint(
                              painter: OpenPainter(100, 10, 65, 20),
                            ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
