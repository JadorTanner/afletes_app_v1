// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/load_card.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:timelines/timelines.dart';

List<Load> loads = [];

Future<List<Load>> getMyLoads() async {
  try {
    Response response = await Api().getData('user/my-loads');
    loads.clear();
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        var data = jsonResponse['data'];

        if (data.isNotEmpty) {
          data.asMap().forEach((key, load) {
            log(jsonEncode(load));
            loads.add(
              Load(
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
                attachments: load['attachments'],
                loadWait: load['wait_in_origin'].toString(),
                deliveryWait: load['wait_in_destination'].toString(),
                weight: double.parse(load['weight']),
                volumen:
                    load['volume'] != null ? double.parse(load['volume']) : 0,
                description: load['description'] ?? '',
                helpersQuantity: load['helpers_quantity'],
                vehicleQuantity: load['vehicles_quantity'],
                measurement: load['measurement_unit_id'].toString(),
                pickUpDate: load['pickup_at'],
                pickUpTime: load['pickup_time'],
                observations: load['observations'] ?? '',
                isUrgent: load['is_urgent'],
                categoryId: load['product_category_id'],
                state: load['load_state'] != null
                    ? load['load_state']['name']
                    : '',
              ),
            );
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
  } catch (e) {
    return [];
  }
}

class MyLoadsPage extends StatefulWidget {
  const MyLoadsPage({Key? key}) : super(key: key);

  @override
  State<MyLoadsPage> createState() => _MyLoadsPageState();
}

class _MyLoadsPageState extends State<MyLoadsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      Stack(
        children: [
          FutureBuilder(
            initialData: const [],
            future: getMyLoads(),
            builder: (context, snapshot) {
              List items = [];
              if (snapshot.connectionState == ConnectionState.done) {
                items = loads.isNotEmpty
                    ? List.generate(
                        loads.length,
                        (index) => LoadCard(
                          loads[index],
                          hasData: true,
                        ),
                      )
                    : [
                        const Center(
                          child: Text('No hay cargas aún'),
                        )
                      ];
              } else {
                items = List.generate(
                  5,
                  (index) => LoadCard(
                    null,
                    hasData: false,
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.only(
                  top: 80,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/create-load', arguments: null),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(vertical: 20)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Constants.kBlack,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(0)),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Agregar carga',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ...items
                ],
              );
            },
          ),
          Positioned(
            bottom: 60,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                border: Border.all(
                  color: Colors.grey,
                  style: BorderStyle.solid,
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
      title: 'Mis cargas',
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
          children: widget.attachments.isNotEmpty
              ? List.generate(
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
                      ))
              : [
                  Image.asset(
                    'assets/img/noimage.png',
                    fit: BoxFit.cover,
                  ),
                ],
        ),
        Positioned(
          bottom: 70,
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

class LoadInformation extends StatelessWidget {
  const LoadInformation({
    Key? key,
    required this.data,
    required this.id,
    required this.textoInformacion,
    required this.intialOfferController,
  }) : super(key: key);

  final Map data;
  final TextStyle textoInformacion;
  final TextEditingController intialOfferController;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Timeline(
      theme: TimelineThemeData(
        color: Colors.grey[400],
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          crossAxisExtent: double.infinity,
          // mainAxisExtent: 60,
          contents: Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['address'] ?? ''),
                Text((data['state']['name'] ?? '') +
                    ' - ' +
                    (data['city']['name'] ?? '')),
              ],
            ),
          ),
          node: const TimelineNode(
            indicator: OutlinedDotIndicator(),
            endConnector: DashedLineConnector(),
          ),
        ),
        TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          crossAxisExtent: double.infinity,
          // mainAxisExtent: 60,
          contents: Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(data['destination_address'] ?? ''),
                Text(
                  (data['destination_state_name'] ?? '') +
                      ' - ' +
                      (data['destination_city_name'] ?? ''),
                ),
              ],
            ),
          ),
          node: const TimelineNode(
            indicator: DotIndicator(),
            startConnector: DashedLineConnector(),
          ),
        ),
        // DotIndicator(
        //   color: Colors.red,
        //   size: 20,
        //   child: Text(data['address'] ?? ''),
        // ),
        // DotIndicator(
        //   color: Colors.red,
        //   size: 20,
        //   child: Text(data['destination_address'] ?? ''),
        // ),
      ],
    );
  }
}
