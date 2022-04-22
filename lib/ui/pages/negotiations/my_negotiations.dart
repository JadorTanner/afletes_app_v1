import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

List<Negotiation> negotiations = [];

Future<List<Negotiation>> getNegotiations() async {
  try {
    Api api = Api();
    negotiations.clear();

    Response response = await api.getData('user/my-negotiations');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        List data = jsonResponse['data'];
        data.asMap().forEach((key, negotiation) {
          negotiations.add(
            Negotiation(
              id: negotiation['id'],
              transportistId: negotiation['transportist_id'],
              generatorId: negotiation['generator_id'],
              vehicleId: negotiation['vehicle_id'],
              stateId: negotiation['negotiation_state_id'],
              fecha: negotiation['fecha'],
              withPerson: user.isCarrier
                  ? negotiation['generator']['full_name'] ?? ''
                  : negotiation['transportist']['full_name'] ?? '',
              negotiationLoad: Load(
                id: negotiation['negotiation_load']['id'],
                product: negotiation['negotiation_load']['product'] ?? '',
                description:
                    negotiation['negotiation_load']['description'] ?? '',
                weight: double.parse(negotiation['negotiation_load']['weight']
                    .replaceAll('.00', '')),
                attachments:
                    negotiation['negotiation_load']['attachments'] ?? [],
                initialOffer: int.parse(
                  negotiation['negotiation_load']['initial_offer']
                      .replaceAll('.00', ''),
                ),
              ),
            ),
          );
        });
      }
    }
    return negotiations;
  } catch (e) {
    return [];
  }
}

class MyNegotiations extends StatefulWidget {
  const MyNegotiations({Key? key}) : super(key: key);

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
          return RefreshIndicator(
            onRefresh: () {
              setState(() {});
              return Future(() => {});
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              margin: const EdgeInsets.only(
                top: 70,
                left: 20,
                right: 20,
              ),
              child: ListView(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                children: [
                  Text(
                    'Mis negociaciones',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(user.isCarrier ? '/loads' : '/vehicles'),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 20)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        kBlack,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: Text(
                      user.isCarrier
                          ? 'Buscar cargas'
                          : 'Buscar transportistas',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...List.generate(
                    snapshot.connectionState == ConnectionState.done
                        ? (negotiations.isNotEmpty ? negotiations.length : 1)
                        : 7,
                    (index) => Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow:
                            snapshot.connectionState == ConnectionState.done &&
                                    negotiations.isNotEmpty
                                ? [
                                    const BoxShadow(
                                      blurRadius: 5,
                                      color: Color(0xAAA7A7A7),
                                    ),
                                  ]
                                : [],
                      ),
                      child: (snapshot.connectionState ==
                                  ConnectionState.done &&
                              negotiations.isEmpty)
                          ? Container(
                              padding: const EdgeInsets.all(10),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text('No hay negociaciones'),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: negotiations.isNotEmpty
                                  ? () => {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => NegotiationChat(
                                              negotiations[index].id),
                                        ))
                                      }
                                  : () => {},
                              child: Container(
                                decoration: const BoxDecoration(),
                                clipBehavior: Clip.hardEdge,
                                // padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      // alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: snapshot.connectionState ==
                                              ConnectionState.done
                                          ? (negotiations[index]
                                                  .negotiationLoad!
                                                  .attachments
                                                  .isNotEmpty
                                              ? Image.network(
                                                  loadImgUrl +
                                                      negotiations[index]
                                                              .negotiationLoad!
                                                              .attachments[0]
                                                          ['filename'],
                                                  fit: BoxFit.cover,
                                                )
                                              : const SizedBox.shrink())
                                          : const SizedBox.shrink(),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        negotiations.isNotEmpty
                                            ? Text(negotiations[index]
                                                        .negotiationLoad!
                                                        .product !=
                                                    ''
                                                ? negotiations[index]
                                                    .negotiationLoad!
                                                    .product
                                                : 'Producto')
                                            : CustomPaint(
                                                painter: OpenPainter(
                                                    50, 10, 10, -40),
                                              ),
                                        negotiations.isNotEmpty
                                            ? Text(negotiations[index]
                                                        .negotiationLoad!
                                                        .negWith !=
                                                    ''
                                                ? negotiations[index]
                                                    .negotiationLoad!
                                                    .negWith
                                                : user.isCarrier
                                                    ? 'Generador'
                                                    : 'Transportista')
                                            : CustomPaint(
                                                painter: OpenPainter(
                                                    100, 10, 10, -25),
                                              ),
                                        negotiations.isNotEmpty
                                            ? Text('Oferta inicial: ' +
                                                negotiations[index]
                                                    .negotiationLoad!
                                                    .initialOffer
                                                    .toString())
                                            : CustomPaint(
                                                painter: OpenPainter(
                                                    150, 10, 10, -5),
                                              ),
                                        negotiations.isNotEmpty
                                            ? Text('Peso: ' +
                                                negotiations[index]
                                                    .negotiationLoad!
                                                    .weight
                                                    .toString())
                                            : CustomPaint(
                                                painter: OpenPainter(
                                                    100, 10, 10, 15),
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
