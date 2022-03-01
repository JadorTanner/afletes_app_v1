// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/pages/loads/load_info.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

List loads = [];
GlobalKey<AnimatedListState> globalKey = GlobalKey<AnimatedListState>();

class Loads extends StatefulWidget {
  const Loads({Key? key}) : super(key: key);
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  TextEditingController textEditingController = TextEditingController();

  Future<List> getLoads([refresh = false]) async {
    Response response = await Api().getData('user/find-loads');

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      loads.clear();
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
          print(jsonResponse['data']);
          List data = jsonResponse['data']['data'];
          data.asMap().forEach((key, load) {
            loads.add(Load(
              id: load['id'],
              addressFrom: load['address'],
              cityFromId: load['city_id'],
              stateFromId: load['state_id'],
              initialOffer: int.parse(
                  load['initial_offer'].toString().replaceAll('.00', '')),
              longitudeFrom: load['longitude'],
              latitudeFrom: load['latitude'],
              destinLongitude: load['destination_longitude'],
              destinLatitude: load['destination_latitude'],
              destinAddress: load['destination_address'],
              destinCityId: load['destination_city_id'],
              destinStateId: load['destination_state_id'],
              product: load['product'] ?? '',
            ));
          });
          globalKey.currentState!
              .insertItem(0, duration: const Duration(milliseconds: 100));
          if (refresh) {
            setState(() {});
          }
        }
      }
    }

    return loads;
  }

  // late User user;

  @override
  void initState() {
    super.initState();
    getLoads();
    // constructUser();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      page,
    );
  }
}

class LoadCard extends StatelessWidget {
  LoadCard(this.load, {Key? key}) : super(key: key);
  Load load;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => LoadInfo(load))),
      child: Card(
        child: SizedBox(width: double.infinity, child: Text(load.addressFrom)),
      ),
    );
  }
}
