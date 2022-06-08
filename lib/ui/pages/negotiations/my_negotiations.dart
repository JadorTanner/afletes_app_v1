import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

List<Negotiation> negotiations = [];
late User user;

Future<List<Negotiation>> getNegotiations(BuildContext context) async {
  try {
    Api api = Api();
    negotiations.clear();

    user = context.read<User>().user;

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
                finalOffer: int.parse(
                  negotiation['negotiation_load']['final_offer'] != null
                      ? negotiation['negotiation_load']['final_offer']
                          .replaceAll('.00', '')
                      : '0',
                ),
                stateId: negotiation['negotiation_load']['load_state']['id'],
              ),
              state: negotiation['negotiation_state']['name'],
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
  MyNegotiations({this.payment, Key? key}) : super(key: key);
  String? payment;
  @override
  State<MyNegotiations> createState() => _MyNegotiationsState();
}

class _MyNegotiationsState extends State<MyNegotiations> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.payment != null) {
      Future.delayed(
        Duration.zero,
        () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                widget.payment == 'success'
                    ? 'El pago se ha realizado con éxito'
                    : 'Ha ocurrido un error',
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check),
                )
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      Stack(
        children: [
          FutureBuilder<List<Negotiation>>(
            initialData: const [],
            future: getNegotiations(context),
            builder: (context, snapshot) {
              return Container(
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
                  primary: true,
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
                          Constants.kBlack,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
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
                          boxShadow: snapshot.connectionState ==
                                      ConnectionState.done &&
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
                                    ? () {
                                        int position = context
                                            .read<NotificationsApi>()
                                            .notifications
                                            .indexWhere((element) =>
                                                element.negotiationId ==
                                                negotiations[index].id);
                                        if (position != -1) {
                                          context
                                              .read<NotificationsApi>()
                                              .readNotification(
                                                  context
                                                      .read<NotificationsApi>()
                                                      .notifications[position],
                                                  context);
                                        } else {
                                          Navigator.of(context).pushNamed(
                                              '/negotiation_id/' +
                                                  negotiations[index]
                                                      .id
                                                      .toString());
                                        }
                                      }
                                    : () => {},
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(),
                                      clipBehavior: Clip.hardEdge,
                                      // padding: const EdgeInsets.all(10),
                                      width: double.infinity,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 110,
                                            height: 110,
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
                                                        Constants.loadImgUrl +
                                                            negotiations[index]
                                                                    .negotiationLoad!
                                                                    .attachments[
                                                                0]['filename'],
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
                                              negotiations.isNotEmpty
                                                  ? Text(
                                                      'Estado: ' +
                                                          Negotiation
                                                              .getStateName(
                                                                  negotiations[
                                                                          index]
                                                                      .state),
                                                    )
                                                  : CustomPaint(
                                                      painter: OpenPainter(
                                                          100, 10, 10, 25),
                                                    ),
                                              negotiations.isNotEmpty
                                                  ? ((negotiations[index]
                                                                  .stateId ==
                                                              2 ||
                                                          negotiations[index]
                                                                  .stateId ==
                                                              7 ||
                                                          negotiations[index]
                                                                  .stateId ==
                                                              8)
                                                      ? Text(
                                                          'Oferta final: ' +
                                                              negotiations[
                                                                      index]
                                                                  .negotiationLoad!
                                                                  .finalOffer
                                                                  .toString(),
                                                        )
                                                      : const SizedBox.shrink())
                                                  : const SizedBox.shrink(),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      child: negotiations.isNotEmpty
                                          ? Container(
                                              color: Colors.white,
                                              padding: const EdgeInsets.all(3)
                                                  .copyWith(left: 4, right: 4),
                                              child: Text(
                                                negotiations[index]
                                                    .id
                                                    .toString(),
                                              ))
                                          : const SizedBox.shrink(),
                                      top: 0,
                                      left: 0,
                                    ),
                                    negotiations.isNotEmpty
                                        ? context
                                                    .watch<NotificationsApi>()
                                                    .notifications
                                                    .indexWhere((element) =>
                                                        element.negotiationId ==
                                                        negotiations[index]
                                                            .id) !=
                                                -1
                                            ? const Positioned(
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  maxRadius: 10,
                                                ),
                                                top: 10,
                                                right: 10,
                                              )
                                            : const SizedBox.shrink()
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
