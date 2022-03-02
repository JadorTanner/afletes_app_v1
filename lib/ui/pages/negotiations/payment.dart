import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Payment extends StatelessWidget {
  Payment(this.id, {Key? key}) : super(key: key);
  int id;

  getPaymentData() async {
    Api api = Api();

    Response response = await api
        .getData('negotiation/payment?negotiation_id=' + id.toString());
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(FutureBuilder(
      future: getPaymentData(),
      builder: (context, snapshot) => ListView(
        children: [Text('Monto: ' + 'algún monto')],
      ),
    ));
  }
}
