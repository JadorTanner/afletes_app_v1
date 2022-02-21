// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Loads extends StatefulWidget {
  const Loads({Key? key}) : super(key: key);
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  TextEditingController textEditingController = TextEditingController();
  List loads = [];

  // Future sendMessage() async {
  //   Api api = Api();
  //   Response response = await api.postData('negotiation/send-message', {
  //     'message': int.parse(textEditingController.text),
  //     'negotiation_id': 5,
  //     'is_final_offer': false,
  //     'user_id': 1,
  //   });
  // }

  // constructUser() async {
  //   user = await User().getUser();
  //   setState(() {});
  // }

  Future<List> getLoads() async {
    Response response = await Api().getData('user/find-loads');

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
          jsonResponse.forEach((key, load) {
            loads.add(Load(
              id: load.id,
              addressFrom: load.address,
              cityFrom: load.city_id,
              stateFromId: load.state_id,
              initialOffer: load.initial_offer,
              longitudeFrom: load.longitude,
              latitudeFrom: load.latitude,
              destinLongitude: load.destination_longitude,
              destinLatitude: load.destination_latitude,
              destinAddress: load.destination_address,
              destinCityId: load.destination_city_id,
              destinStateId: load.destination_state_id,
              product: load.product,
            ));
          });
        }
      }
    }

    return loads;
  }

  // late User user;

  @override
  void initState() {
    super.initState();
    // constructUser();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getLoads(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: List.generate(
                  loads.length, (index) => LoadCard(loads[index])),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class LoadCard extends StatelessWidget {
  LoadCard(this.load, {Key? key}) : super(key: key);
  Load load;

  @override
  Widget build(BuildContext context) {
    return Text(load.addressFrom);
  }
}
