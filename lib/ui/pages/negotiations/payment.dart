// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compruebe su conexión a internet')));
      return {};
    }
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    if (Platform.isIOS) WebView.platform = CupertinoWebView();
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
                          newRow('Descripción',
                              data['data']['load']['description']),
                          newRow(
                              'Cantidad de vehículos',
                              data['data']['load']['vehicles_quantity']
                                  .toString()),
                          newRow(
                              'Cantidad de ayudantes',
                              data['data']['load']['helpers_quantity']
                                  .toString()),
                          newRow('Peso',
                              data['data']['load']['weight'].toString()),
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
                    child: PaymentMethods(data['data']['saldo_transportista']),
                  )),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            try {
                              Api api = Api();
                              Response response = await api
                                  .postData('negotiation/pay-negotiation', {
                                'amount': data['data']['load']['final_offer']
                                    .toString()
                                    .replaceAll('.00', ''),
                                'negotiation_id': widget.id
                              });

                              Map jsonResponse = jsonDecode(response.body);
                              if (response.statusCode == 200) {
                                if (jsonResponse['process_id'] != '') {
                                  showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                            child: WebView(
                                              initialUrl: apiUrl +
                                                  'bancard-view?process_id=' +
                                                  jsonResponse['data']
                                                      ['process_id'],
                                              javascriptMode:
                                                  JavascriptMode.unrestricted,
                                            ),
                                          ),
                                      barrierDismissible: false);
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Compruebe su conexión a internet')));
                            }
                          },
                          icon: const Icon(Icons.attach_money),
                          label: const Text('Realizar el pago'))
                    ],
                  )
                ]);
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
    children: [
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        data ?? '',
      )
    ],
  );
}

class PaymentMethods extends StatefulWidget {
  PaymentMethods(this.saldoTransportista, {Key? key}) : super(key: key);
  Map? saldoTransportista;
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
            }),
      ],
    );
  }
}
