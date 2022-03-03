// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/components/google_map.dart';
import 'package:afletes_app_v1/ui/pages/loads/load_info.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

List<Load> loads = [];
GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();
GlobalKey<OverlayState> stackKey = GlobalKey<OverlayState>();
late PageController pageController;

onLoadTap(int id, BuildContext context) async {
  Api api = Api();

  TextEditingController intialOfferController = TextEditingController();

  Response response = await api.getData('load/load-info?id=' + id.toString());

  Map jsonResponse = jsonDecode(response.body);
  if (jsonResponse['success']) {
    Map data = jsonResponse['data'];
    List images = data['attachments'] ?? [];
    List<Image> attachments = [];

    TextStyle textoInformacion = const TextStyle(fontSize: 12);

    intialOfferController.text = data['initial_offer'].toString();
    if (images.isNotEmpty) {
      for (var element in images) {
        attachments.add(Image.network(imgUrl + element['filename']));
      }
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: ImageViewer(attachments),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Carga nro: ' + id.toString()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Salida'),
                    Text(
                      'Departamento: ' +
                          (data['state'] != null ? data['state']['name'] : ''),
                      style: textoInformacion,
                    ),
                    Text(
                      'Ciudad: ' +
                          (data['city'] != null ? data['city']['name'] : ''),
                      style: textoInformacion,
                    ),
                    Text(
                      'Dirección: ' + (data['address'] ?? ''),
                      style: textoInformacion,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Entrega'),
                    Text(
                      'Departamento: ' + (data['destination_state_name'] ?? ''),
                      style: textoInformacion,
                    ),
                    Text(
                      'Ciudad: ' + (data['destination_city_name'] ?? ''),
                      style: textoInformacion,
                    ),
                    Text(
                      'Dirección: ' + (data['destination_address'] ?? ''),
                      style: textoInformacion,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Oferta inicial'),
            TextField(
              controller: intialOfferController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  helperText:
                      'Puedes cambiarlo para ofertar un precio diferente *'),
            ),
            (data['load_state_id'] == 1
                ? ButtonBar(
                    children: [
                      TextButton.icon(
                          onPressed: () async {
                            Api api = Api();
                            Response response = await api.postData(
                                'negotiation/start-negotiation', {
                              'load_id': id,
                              'initial_offer': intialOfferController.text
                            });

                            if (response.statusCode == 200) {
                              Map jsonResponse = jsonDecode(response.body);
                              if (jsonResponse['success']) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => NegotiationChat(
                                      jsonResponse['data']['negotiation_id']),
                                ));
                              }
                            }
                          },
                          label: const Text('Negociar'),
                          icon: const Icon(Icons.check))
                    ],
                  )
                : const SizedBox.shrink())
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatefulWidget {
  ImageViewer(this.attachments, {Key? key}) : super(key: key);
  List attachments;
  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int currentImage = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          onPageChanged: (value) => setState(() {
            currentImage = value;
          }),
          children: List.generate(
              widget.attachments.length,
              (index) => GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4,
                          clipBehavior: Clip.none,
                          child: widget.attachments[index],
                        ),
                      ),
                    ),
                    child: widget.attachments[index],
                  )),
        ),
        Positioned(
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.attachments.length,
              (index) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: index == currentImage
                      ? const Color(0xFF686868)
                      : const Color(0xFFEEEEEE),
                  border: Border.all(
                    color: index == currentImage
                        ? const Color(0xFF686868)
                        : const Color(0xFFEEEEEE),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
                weight: double.parse(load['weight']),
                product: load['product'] ?? '',
                attachments: load['attachments'] ?? [],
              ),
            );
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
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.done
              ? Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageController,
                      children: [
                        RefreshIndicator(
                            child: loads.length > 0
                                ? AnimatedList(
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
                                  )
                                : const Center(
                                    child: Text('No hay cargas disponibles'),
                                  ),
                            // child: ListView.builder(
                            //   padding: const EdgeInsets.all(20),
                            //   itemBuilder: (context, index) => LoadCard(loads[index]),
                            // ),
                            onRefresh: () => getLoads()),
                        snapshot.connectionState == ConnectionState.done
                            ? const LoadsMap()
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

/* class _LoadsState extends State<Loads> {
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
                weight: double.parse(load['weight']),
                product: load['product'] ?? '',
                attachments: load['attachments'] ?? [],
              ),
            );
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
                                ? const LoadsMap()
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
 */
class LoadsMap extends StatefulWidget {
  const LoadsMap({Key? key}) : super(key: key);
  @override
  State<LoadsMap> createState() => _LoadsMapState();
}

class _LoadsMapState extends State<LoadsMap>
    with AutomaticKeepAliveClientMixin {
  late List<OverlayEntry> initialEntries;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AfletesGoogleMap(
      loads: loads,
      onTapMarker: onLoadTap,
    );
    // return Overlay(
    //   key: stackKey,
    //   initialEntries: initialEntries,
    // );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
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
          // onTap: () => Navigator.of(context)
          //     .push(MaterialPageRoute(builder: (context) => LoadInfo(load))),
          onTap: () => onLoadTap(load.id, context),
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
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
