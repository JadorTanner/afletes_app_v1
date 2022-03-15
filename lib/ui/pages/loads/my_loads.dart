import 'dart:convert';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
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
                categoryId: load['product_category_id']));
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

onLoadTap(int id, BuildContext context, Load load) async {
  try {
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
          attachments.add(Image.network(
            loadImgUrl + element['filename'],
            fit: BoxFit.cover,
          ));
        }
      }
      Size size = MediaQuery.of(context).size;
      await showModalBottomSheet(
        context: context,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        // enableDrag: true,
        constraints: BoxConstraints(
            minHeight: size.height * 0.1, maxHeight: size.height * 0.7),
        builder: (context) => Stack(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 400,
                        child: ImageViewer(attachments),
                      ),
                      Positioned(
                        bottom: -2,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFFFFFFFF)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 40,
                    ),
                    child: Text(data['product'] ?? '',
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    child: Text(data['description'] ?? ''),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.all(20),
                    child: LoadInformation(
                        data: data,
                        id: id,
                        textoInformacion: textoInformacion,
                        intialOfferController: intialOfferController),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextField(
                            enabled: false,
                            controller: intialOfferController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              label: Text('Oferta Inicial'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: () async {
                            //LLEVA AL DETALLE DE LA CARGA
                            Navigator.of(context)
                                .pushNamed('/create-load', arguments: {
                              'id': load.id,
                              'product': load.product,
                              'peso': load.weight,
                              'volumen': load.volumen,
                              'description': load.description,
                              'categoria': load.categoryId,
                              'unidadMedida': load.measurement,
                              'ofertaInicial': load.initialOffer,
                              'vehiculos': load.vehicleQuantity,
                              'ayudantes': load.helpersQuantity,
                              'originAddress': load.addressFrom,
                              'originCity': load.cityFromId,
                              'originState': load.stateFromId,
                              'originCoords':
                                  load.latitudeFrom + ',' + load.longitudeFrom,
                              'destinAddress': load.destinAddress,
                              'destinCity': load.destinCityId,
                              'destinState': load.destinStateId,
                              'destinCoords': load.latitudeFrom +
                                  ',' +
                                  load.destinLongitude,
                              'loadDate': load.pickUpDate,
                              'loadHour': load.pickUpTime,
                              'esperaCarga': load.loadWait,
                              'esperaDescarga': load.deliveryWait,
                              'observaciones': load.observations,
                              'isUrgent': load.isUrgent,
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF101010)),
                            foregroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFFFFFFFF)),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 10)),
                          ),
                          label: const Text('Ver más detalles'),
                          icon: const Icon(Icons.check),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 160,
              right: 160,
              top: 10,
              child: Container(
                height: 5,
                width: 2,
                constraints: const BoxConstraints(maxWidth: 2),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFC5C5C5),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 20,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                  ),
                ),
              ),
            ),
            data['is_urgent']
                ? Positioned(
                    left: 30,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(10),
                          left: Radius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'URGENTE',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      );
      ;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compruebe su conexión a internet')));
  }
}

class MyLoadsPage extends StatefulWidget {
  MyLoadsPage({Key? key}) : super(key: key);

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
                          index,
                          hasData: true,
                        ))
                : [
                    const Center(
                      child: Text('No hay cargas aún'),
                    )
                  ];
          } else {
            items = List.generate(
              5,
              (index) => LoadCard(
                index,
                hasData: false,
              ),
            );
          }
          return RefreshIndicator(
              child: ListView(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                children: [
                  TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/create-load'),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar carga')),
                  ...items
                ],
              ),
              onRefresh: () async => setState(() => {}));
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
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 10,
        child: GestureDetector(
          onTap: hasData
              ? () => onLoadTap(loads[index].id, context, loads[index])
              : null,
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                    width: 150,
                    child: hasData
                        ? Image.network(
                            loads[index].attachments.isNotEmpty
                                ? loadImgUrl +
                                    loads[index].attachments[0]['filename']
                                : 'https://magazine.medlineplus.gov/images/uploads/main_images/red-meat-v2.jpg',
                            loadingBuilder: (context, child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                  child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ));
                            },
                            fit: BoxFit.fitWidth,
                          )
                        : const SizedBox.shrink()),
                // ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      hasData
                          ? Text(
                              loads[index].product != ''
                                  ? loads[index].product
                                  : 'Producto',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          : CustomPaint(
                              painter: OpenPainter(100, 10, 10, -10),
                            ),
                      hasData
                          ? SizedBox(
                              width: 200,
                              child: Text(loads[index].addressFrom +
                                  ' - ' +
                                  loads[index].destinAddress))
                          : CustomPaint(
                              painter: OpenPainter(50, 10, 10, 20),
                            ),
                      hasData
                          ? Text(currencyFormat(loads[index].initialOffer))
                          : CustomPaint(
                              painter: OpenPainter(50, 10, 10, 20),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
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
          mainAxisExtent: 60,
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
          mainAxisExtent: 60,
          contents: Container(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['destination_address'] ?? ''),
                Text((data['destination_state_name'] ?? '') +
                    ' - ' +
                    (data['destination_city_name'] ?? '')),
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
