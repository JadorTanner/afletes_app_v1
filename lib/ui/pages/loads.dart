// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/components/google_map.dart';
import 'package:afletes_app_v1/ui/pages/loads/load_info.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

List<Load> loads = [];
GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
GlobalKey<OverlayState> stackKey = GlobalKey<OverlayState>();
late PageController pageController;

class Loads extends StatefulWidget {
  const Loads({Key? key}) : super(key: key);
  @override
  _LoadsState createState() => _LoadsState();
}

class _LoadsState extends State<Loads> {
  TextEditingController textEditingController = TextEditingController();

  Future<List<Load>> getLoads([refresh = false]) async {
    Response response = await Api().getData('user/find-loads');

    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      loads.forEach((element) {
        animatedListKey.currentState != null
            ? animatedListKey.currentState!
                .removeItem(0, (context, animation) => const SizedBox.shrink())
            : null;
      });
      loads.clear();
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
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
            animatedListKey.currentState != null
                ? animatedListKey.currentState!
                    .insertItem(0, duration: const Duration(milliseconds: 100))
                : null;
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
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder<List<Load>>(
          future: getLoads(),
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.done
                  ? Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        PageView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: pageController,
                          children: [
                            RefreshIndicator(
                                child: AnimatedList(
                                  key: animatedListKey,
                                  initialItemCount: loads.length,
                                  padding: const EdgeInsets.all(20),
                                  itemBuilder: (context, index, animation) {
                                    return SizeTransition(
                                      key: UniqueKey(),
                                      sizeFactor: animation,
                                      child: LoadCard(loads[index]),
                                    );
                                  },
                                ),
                                // child: ListView.builder(
                                //   padding: const EdgeInsets.all(20),
                                //   itemBuilder: (context, index) => LoadCard(loads[index]),
                                // ),
                                onRefresh: () => getLoads()),
                            snapshot.connectionState == ConnectionState.done
                                ? LoadsMap()
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  )
                          ],
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => {
                                      pageController.previousPage(
                                          duration:
                                              const Duration(milliseconds: 100),
                                          curve: Curves.bounceOut)
                                    },
                                icon: const Icon(Icons.list)),
                            IconButton(
                                onPressed: () => {
                                      pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 100),
                                          curve: Curves.bounceOut)
                                    },
                                icon: const Icon(Icons.map)),
                          ],
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator())),
    );
  }
}

class LoadsMap extends StatefulWidget {
  LoadsMap({Key? key}) : super(key: key);
  @override
  State<LoadsMap> createState() => _LoadsMapState();
}

class _LoadsMapState extends State<LoadsMap> {
  late List<OverlayEntry> initialEntries;

  onTapMarker(int id) async {
    Api api = Api();

    Response response = await api.getData('load/load-info?id=' + id.toString());

    print(id);
    print(response.body);
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      Map data = jsonResponse['data'];
      List images = data['attachments'] ?? [];
      List<Image> attachments = [];
      if (images.isNotEmpty) {
        for (var element in images) {
          attachments.add(Image.network(imgUrl + element['filename']));
        }
      }
      stackKey.currentState != null
          ? stackKey.currentState!.insert(
              OverlayEntry(
                builder: (context) => Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xAA4E4E4E),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: PageView(
                              children: List.generate(
                                  attachments.length,
                                  (index) => GestureDetector(
                                        onTap: () => showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: InteractiveViewer(
                                              panEnabled: true,
                                              minScale: 0.5,
                                              maxScale: 4,
                                              clipBehavior: Clip.none,
                                              child: attachments[index],
                                            ),
                                          ),
                                        ),
                                        child: attachments[index],
                                      )),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Carga nro: ' + id.toString()),
                              const SizedBox(
                                width: 20,
                              ),
                              Text('Oferta inicial: ' + data['initial_offer']),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('Salida'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Departamento: ' +
                                  (data['state'] != null
                                      ? data['state']['name']
                                      : '')),
                              const SizedBox(
                                width: 20,
                              ),
                              Text('Ciudad: ' +
                                  (data['city'] != null
                                      ? data['city']['name']
                                      : '')),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('Entrega'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Departamento: ' +
                                  (data['destinationState'] != null
                                      ? data['destinationState']['name']
                                      : '')),
                              const SizedBox(
                                width: 20,
                              ),
                              Text('Ciudad: ' +
                                  (data['destinationCity'] != null
                                      ? data['destinationCity']['name']
                                      : '')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ...initialEntries,
        AfletesGoogleMap(
          loads: loads,
          onTapMarker: onTapMarker,
        ),
      ],
    );
    // return Overlay(
    //   key: stackKey,
    //   initialEntries: initialEntries,
    // );
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
