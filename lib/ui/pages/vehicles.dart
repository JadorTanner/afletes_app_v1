import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/car_card.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Vehicles extends StatefulWidget {
  Vehicles({this.id = null, Key? key}) : super(key: key);

  int? id;

  @override
  _VehiclesState createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  List<Vehicle> vehicles = [];

  Future<List> getVehicles([int? id = null]) async {
    vehicles.clear();
    Response response = await Api().getData('user/find-vehicles');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      print(jsonResponse['data']['data'][0]['vehicleattachments']);
      print(jsonResponse['data']['data'][0]['vehicleBrand']);
      if (jsonResponse['success']) {
        if (jsonResponse['data']['data'].length > 0) {
          for (var vehicle in jsonResponse['data']['data']) {
            vehicles.add(Vehicle(
                id: vehicle['id'],
                licensePlate: vehicle['license_plate'],
                senacsa: vehicle['senacsa_authorization_attachment_id'] != null
                    ? true
                    : false,
                dinatran:
                    vehicle['dinatran_authorization_attachment_id'] != null
                        ? true
                        : false,
                imgs: vehicle['vehicleattachments'] ?? ''));
          }
        }
      }
    }

    return vehicles;
  }

  onVehicleTap(int id, BuildContext context) async {
    Api api = Api();

    Response response =
        await api.getData('vehicles/vehicle-info?vehicle_id=' + id.toString());
    print(response.body);
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      Map data = jsonResponse['data'];
      List images = data['imgs'] ?? [];
      List<Image> attachments = [];
      // Vehicle vehicle = Vehicle(
      //   id: data['id']
      // );

      TextStyle textoInformacion = const TextStyle(fontSize: 12);

      if (images.isNotEmpty) {
        for (var element in images) {
          attachments.add(Image.network(vehicleImgUrl + element['filename']));
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
                  Text('Chapa/dominio: ' + data['vehicle']['license_plate']),
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
                      Text(
                        'Unidad de medida: ' + data['vehicle']['unidad_medida'],
                        style: textoInformacion,
                      ),
                      Text(
                        'Capacidad Máxima: ' +
                            data['vehicle']['max_capacity'].toString(),
                        style: textoInformacion,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marca: ' + data['marca']['name'],
                        style: textoInformacion,
                      ),
                      Text(
                        'Modelo: ' + data['vehicle']['model'],
                        style: textoInformacion,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ButtonBar(
                children: [
                  TextButton.icon(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: ListView(
                              children: [Text('carga'), Text('carga')],
                            ),
                          ),
                        );
                        // Api api = Api();
                        // Response response = await api.postData(
                        //     'negotiation/start-negotiation', {
                        //   'load_id': id,
                        //   'initial_offer': intialOfferController.text
                        // });

                        // if (response.statusCode == 200) {
                        //   Map jsonResponse = jsonDecode(response.body);
                        //   if (jsonResponse['success']) {
                        //     Navigator.of(context).push(MaterialPageRoute(
                        //       builder: (context) => NegotiationChat(
                        //           jsonResponse['data']['negotiation_id']),
                        //     ));
                        //   }
                        // }
                      },
                      label: const Text('Negociar'),
                      icon: const Icon(Icons.check))
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getVehicles(widget.id),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: List.generate(
                  vehicles.length,
                  (index) => CarCard2(
                        vehicles[index],
                        onTap: () => onVehicleTap(vehicles[index].id, context),
                      )),
            );
          }
          return const CircularProgressIndicator();
        },
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
