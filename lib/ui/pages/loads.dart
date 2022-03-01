// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/pages/loads/load_info.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
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
            loads.insert(
                0,
                Load(
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
          globalKey.currentState != null
              ? globalKey.currentState!
                  .insertItem(0, duration: const Duration(milliseconds: 100))
              : null;
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
      RefreshIndicator(
          child: FutureBuilder(
            future: getLoads(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.done
                ? AnimatedList(
                    key: globalKey,
                    initialItemCount: loads.length,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index, animation) => SizeTransition(
                      key: UniqueKey(),
                      sizeFactor: animation,
                      child: LoadCard(loads[index]),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          // child: ListView.builder(
          //   padding: const EdgeInsets.all(20),
          //   itemBuilder: (context, index) => LoadCard(loads[index]),
          // ),
          onRefresh: () => getLoads()),
    );
  }
}

// class LoadCard extends StatelessWidget {
//   LoadCard(this.load, {Key? key}) : super(key: key);
//   Load load;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.of(context)
//           .push(MaterialPageRoute(builder: (context) => LoadInfo(load))),
//       child: Card(
//         child: SizedBox(width: double.infinity, child: Text(load.addressFrom)),
//       ),
//     );
//   }
// }

class LoadCard extends StatelessWidget {
  LoadCard(
    this.load, {
    Key? key,
  }) : super(key: key);
  Load load;
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 10,
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LoadInfo(load))),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Row(
              children: [
                CircleAvatar(
                  maxRadius: 50,
                  minRadius: 50,
                  backgroundColor: Colors.white,
                  child: Image.network(
                    load.attachments.isNotEmpty
                        ? imgUrl + load.attachments[0]['filename']
                        : 'https://magazine.medlineplus.gov/images/uploads/main_images/red-meat-v2.jpg',
                    loadingBuilder:
                        (context, child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                          child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ));
                    },
                  ),
                ),
                Column(
                  children: [
                    Text(load.product != '' ? load.product : 'Producto'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(load.initialOffer.toString()),
                        Text(load.addressFrom),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
