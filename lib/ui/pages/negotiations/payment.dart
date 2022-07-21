// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/my_negotiations.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

TextEditingController razon = TextEditingController();
TextEditingController ruc = TextEditingController();
TextEditingController method = TextEditingController();

class Payment extends StatefulWidget {
  Payment(this.id, {Key? key}) : super(key: key);
  int id;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Future<Map> getPaymentData() async {
    try {
      Api api = Api();

      Response response = await api.getData(
          'negotiation/payment?negotiation_id=' + widget.id.toString());
      return jsonDecode(response.body);
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compruebe su conexión a internet'),
        ),
      );
      return {};
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error'),
        ),
      );
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<Map>(
        future: getPaymentData(),
        builder: (context, snapshot) {
          Map? data = snapshot.data;
          if (data != null) {
            razon.text = data['data']['generator']['legal_name'] ??
                data['data']['generator']['last_name'] +
                    ' ' +
                    data['data']['generator']['first_name'];
            ruc.text = data['data']['generator']['document_number'];
            method.text = '0';
            return ListView(
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Tu pedido',
                      textScaleFactor: 1.3,
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        TextField(
                          controller: razon,
                          decoration: const InputDecoration(
                              label: Text('Razón social *'),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          controller: ruc,
                          decoration: const InputDecoration(
                              label: Text('RUC / C.I. *'),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        newRow(
                            'Vehículo',
                            data['data']['vehicle']['brand'] +
                                ' - ' +
                                data['data']['vehicle']['model']),
                        newRow('Producto', data['data']['load']['product']),
                        newRow(
                            'Descripción', data['data']['load']['description']),
                        newRow(
                            'Cantidad de vehículos',
                            data['data']['load']['vehicles_quantity']
                                .toString()),
                        newRow(
                            'Cantidad de ayudantes',
                            data['data']['load']['helpers_quantity']
                                .toString()),
                        newRow(
                            'Peso', data['data']['load']['weight'].toString()),
                        (data['data']['load']['volume'] != null
                            ? newRow('Volumen',
                                data['data']['load']['volume'].toString())
                            : const SizedBox.shrink()),
                        newRow(
                            'Precio',
                            data['data']['load']['final_offer']
                                .toString()
                                .replaceAll('.00', '')),
                        newRow('Dirección de partida',
                            data['data']['load']['address']),
                        newRow('Dirección de destino',
                            data['data']['load']['destination_address']),
                      ],
                    ),
                  ),
                ),
                Card(
                    child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PaymentMethods(
                      data['data']['saldo_transportista'],
                      data['data']['load']['final_offer']
                          .toString()
                          .replaceAll('.00', '')),
                )),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          Api api = Api();
                          Response response = await api.postData(
                            'negotiation/pay-negotiation',
                            {
                              'amount': data['data']['load']['final_offer']
                                  .toString()
                                  .replaceAll('.00', ''),
                              'negotiation_id': widget.id,
                              'metodo': method.text,
                            },
                          );

                          Map jsonResponse = jsonDecode(response.body);
                          if (response.statusCode == 200) {
                            if (method.text == '2') {
                              if (jsonResponse['process_id'] != '') {
                                String url = Constants.apiUrl +
                                    'bancard-view?app=true&process_id=' +
                                    jsonResponse['data']['process_id'];

                                try {
                                  if (await canLaunch(url)) {
                                    try {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                '/my-negotiations');
                                      });
                                    } catch (e) {
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MyNegotiations(),
                                          ),
                                        );
                                      });
                                    }
                                    await launch(url);
                                  } else {
                                    throw "Could not launch $url";
                                  }
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: const Text(
                                        'No hemos podido abrir el formulario. Por favor, ingrese desde la web para realizar el pago.',
                                      ),
                                      actions: [
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          icon: const Icon(Icons.check),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                // showDialog(
                                //   context: context,
                                //   builder: (context) => Dialog(
                                //     child: WebView(
                                //       initialUrl: Constants.apiUrl +
                                //           'bancard-view?process_id=' +
                                //           jsonResponse['data']['process_id'],
                                //       javascriptMode:
                                //           JavascriptMode.unrestricted,
                                //     ),
                                //   ),
                                //   barrierDismissible: false,
                                // );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Aguardamos su pago.'),
                                ),
                              );
                              // Navigator.of(context).pushNamedAndRemoveUntil(
                              //   '/my-negotiations',
                              //   ModalRoute.withName('/my-negotiations'),
                              // );
                              try {
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/my-negotiations');
                                });
                              } catch (e) {
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => MyNegotiations(),
                                    ),
                                  );
                                });
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ha ocurrido un error'),
                              ),
                            );
                          }
                        } on SocketException {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compruebe su conexión a internet'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ha ocurrido un error'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.attach_money),
                      label: const Text('Realizar el pago'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                  onPressed: () async {
                    String text = '';
                    try {
                      Response textResponse = await get(
                          Uri.parse(Constants.apiUrl + 'datos-transferencia'));
                      if (textResponse.statusCode == 200) {
                        text = textResponse.body;
                      } else {
                        throw Exception();
                      }
                    } catch (e) {
                      text = """Razon Social: Arroba Paraguay SRL
                      Ruc N°: 80110965-5
                      Cta.Cte. Banco Itau N°: 0212014""";
                    }
                    try {
                      String url = Uri.parse(
                              "whatsapp://send?phone=595983473816&text=$text")
                          .toString();
                      print(url);
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw Exception('No se puede abrir whatsapp');
                      }
                    } catch (e) {
                      print('NO SE PUEDE ABRIR WHATSAPP');
                      print(e);
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Lo sentimos, no podemos abrir whatsapp. Los datos han sido copiados.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.whatsapp,
                    color: Colors.white,
                    size: 30,
                  ),
                  label: const Text('Whatsapp',
                      style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFFED8232))),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

Row newRow(String title, data) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        width: 10,
      ),
      Flexible(
        child: Text(
          data ?? '',
          softWrap: true,
        ),
      ),
    ],
  );
}

class PaymentMethods extends StatefulWidget {
  PaymentMethods(this.saldoTransportista, this.finalOffer, {Key? key})
      : super(key: key);
  Map? saldoTransportista;
  String finalOffer;
  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  int selectedMethod = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione un método de pago',
          textScaleFactor: 1.3,
        ),
        widget.saldoTransportista != null
            ? ((widget.saldoTransportista!['saldo_actual'] -
                        (double.parse(widget.finalOffer) * 0.25)) >=
                    0
                ? RadioListTile(
                    title: const Text('Efectivo'),
                    value: 1,
                    groupValue: selectedMethod,
                    onChanged: (int? newVal) {
                      setState(() {
                        method.text = newVal.toString();
                        selectedMethod = newVal!;
                      });
                    })
                : const SizedBox.shrink())
            : const SizedBox.shrink(),
        RadioListTile(
          title: const Text('Bancard'),
          value: 2,
          groupValue: selectedMethod,
          onChanged: (int? newVal) {
            setState(() {
              method.text = newVal.toString();
              selectedMethod = newVal!;
            });
          },
        ),
      ],
    );
  }
}
