import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Loads extends StatefulWidget {
  Loads(this.getToken, {Key? key}) : super(key: key);

  void getToken;

  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  TextEditingController textEditingController = TextEditingController();

  Future sendMessage() async {
    Api api = Api();
    print('enviando');
    Response response = await api.postData('negotiation/send-message', {
      'message': int.parse(textEditingController.text),
      'negotiation_id': 5,
      'is_final_offer': false,
      'user_id': 1,
    });

    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextButton(
              onPressed: () => widget.getToken, child: Text('obtener token')),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: textEditingController,
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(onPressed: sendMessage, child: Text('Enviar mensaje')),
          const SizedBox(
            height: 20,
          ),
          ButtonBar(
            children: [
              TextButton(
                  onPressed: () =>
                      User().login(context, 'generador@gmail.com', '123456789'),
                  child: const Text('login')),
              TextButton(
                  onPressed: () async => {
                        print(await Load().createLoad({
                          'vehicle_type_id': 1,
                          'product_category_id': 1,
                          'product': 'Carne App',
                          'vehicles_quantity': 5,
                          'helpers_quantity': 1,
                          'weight': 100,
                          'measurement_unit_id': 1,
                          'initial_offer': 1000000,
                          'state_id': 7,
                          'city_id': 83,
                          'address': 'TEST DE APP',
                          'latitude': '-57,4564654',
                          'longitude': '-58,5645646',
                          'destination_state_id': 7,
                          'destination_city_id': 88,
                          'destination_address': 'TEST DESTINATION APP',
                          'destination_latitude': '-58,5665646',
                          'destination_longitude': '-58,5665646',
                          'pickup_at': '2021-02-20',
                          'pickup_time': '10:30',
                          'payment_term_after_delivery': 1,
                          'wait_in_origin': 10,
                          'wait_in_destination': 11,
                        }))
                      },
                  child: const Text('Crear carga')),
              IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/vehicles'),
                  icon: const Icon(Icons.agriculture)),
              TextButton(
                  onPressed: () => User().logout(),
                  child: const Text('Logout')),
            ],
          )
        ],
      ),
    );
  }
}
