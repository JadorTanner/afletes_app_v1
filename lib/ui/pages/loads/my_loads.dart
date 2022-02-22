import 'dart:convert';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

List<Load> loads = [];

Future<List<Load>> getMyLoads() async {
  Response response = await Api().getData('user/my-loads');
  loads.clear();
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      var data = jsonResponse['data']['data'];
      if (data.isNotEmpty) {
        print(data[0]);
        data.asMap().forEach((key, load) {
          loads.add(Load(
            id: load['id'],
            addressFrom: load['address'],
            cityFromId: load['city_id'],
            stateFromId: load['state_id'],
            initialOffer: double.parse(load['initial_offer']).toInt(),
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
        return loads;
      } else {
        loads = [];
      }
    } else {
      loads = [];
    }
  }

  return loads;
}

class MyLoadsPage extends StatelessWidget {
  const MyLoadsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<Load>>(
        initialData: const [],
        future: getMyLoads(),
        builder: (context, snapshot) {
          List items = [];
          if (snapshot.connectionState == ConnectionState.done) {
            items = List.generate(
                loads.length,
                (index) => LoadCard(
                      index,
                      hasData: true,
                    ));
          } else {
            items = List.generate(
              5,
              (index) => LoadCard(
                index,
                hasData: false,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/create-load'),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar carga')),
              ...items
            ],
          );
        },
      ),
      title: 'Mis cargas',
    );
  }
}

class LoadCard extends StatelessWidget {
  LoadCard(
    this.index, {
    this.hasData = false,
    Key? key,
  }) : super(key: key);
  int index;
  bool hasData;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          children: [
            CircleAvatar(
              maxRadius: 50,
              minRadius: 50,
              backgroundColor: Colors.white,
              child: hasData
                  ? Image.network(
                      'https://magazine.medlineplus.gov/images/uploads/main_images/red-meat-v2.jpg',
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
                    )
                  : null,
            ),
            Column(
              children: [
                hasData
                    ? Text(loads[index].product != ''
                        ? loads[index].product
                        : 'Producto')
                    : CustomPaint(
                        painter: OpenPainter(100, 10, 10, -10),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    hasData
                        ? Text(loads[index].initialOffer.toString())
                        : CustomPaint(
                            painter: OpenPainter(50, 10, 10, 20),
                          ),
                    hasData
                        ? Text(loads[index].addressFrom)
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
    );
  }
}
