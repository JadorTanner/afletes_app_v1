import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/ui/components/trayecto_carga.dart';
import 'package:afletes_app_v1/ui/pages/loads/my_loads.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/chat.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

onLoadTap(
  int id,
  BuildContext context,
  Load load, [
  bool isCarrier = false,
  var setLoadMarkers,
  var onClose,
  bool isFinalOffer = false,
]) async {
  try {
    Map data = {};
    List<Image> attachments = [];
    Size size = MediaQuery.of(context).size;
    TextStyle textoInformacion = const TextStyle(fontSize: 12);
    TextEditingController intialOfferController = TextEditingController();
    List images = [];

    Api api = Api();

    Response response = await api.getData('load/load-info?id=' + id.toString());
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      attachments.clear();
      data = jsonResponse['data'];
      images = data['attachments'] ?? [];

      intialOfferController.text = isFinalOffer
          ? (data['final_offer'] ?? 0).toString()
          : data['initial_offer'].toString();
      if (images.isNotEmpty) {
        for (var element in images) {
          attachments.add(Image.network(
            Constants.loadImgUrl + element['filename'],
            fit: BoxFit.cover,
          ));
        }
      }
      await showModalBottomSheet(
        context: context,
        barrierColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        enableDrag: true,
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
                padding: const EdgeInsets.only(bottom: 60),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  isFinalOffer
                      ? Container(
                          color: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.all(20),
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                        child: VerTrayecto(load),
                                      ));
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.location_on),
                                Text('Ver trayecto'),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 10),
                    child: Row(children: [
                      const Icon(Icons.calendar_month),
                      const SizedBox(
                        width: 20,
                      ),
                      Text('Fecha de carga: ' + load.pickUpDate),
                    ]),
                  ),
                  Container(
                    color: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 20),
                    child: Row(children: [
                      const Icon(Icons.timer),
                      const SizedBox(
                        width: 20,
                      ),
                      Text('Hora de carga: ' + load.pickUpTime),
                    ]),
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
                            // enabled: isCarrier,
                            controller: intialOfferController,
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              print('NUEVO VALOR: ' + val);
                            },
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              label: Text(
                                'Oferta ' +
                                    (isFinalOffer ? 'Final' : 'Inicial'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        isCarrier
                            ? (data['load_state_id'] == 1
                                ? NegociarButton(load.id, setLoadMarkers,
                                    intialOfferController:
                                        intialOfferController)
                                : (load.negotiationId != 0
                                    ? TextButton.icon(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NegotiationChat(
                                                      load.negotiationId),
                                            ),
                                          );
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFF101010)),
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color(0xFFFFFFFF)),
                                          padding: MaterialStateProperty.all<
                                                  EdgeInsets>(
                                              const EdgeInsets.symmetric(
                                                  vertical: 18,
                                                  horizontal: 10)),
                                        ),
                                        label: const Text('Ver chat'),
                                        icon: const Icon(Icons.check),
                                      )
                                    : const SizedBox.shrink()))
                            : TextButton.icon(
                                onPressed: () async {
                                  Navigator.of(context).pop();
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
                                    'originCoords': load.latitudeFrom +
                                        ',' +
                                        load.longitudeFrom,
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
                                    'imgs': images
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF101010)),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFFFFFFFF)),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
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
      ).then((value) {
        setLoadMarkers != null ? setLoadMarkers() : null;
        onClose != null ? onClose() : null;
      });
    } else {
      throw Exception();
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Ha ocurrido un error')));
    print(e);
  }
}

class NegociarButton extends StatefulWidget {
  NegociarButton(
    this.id,
    this.setLoadMarkers, {
    Key? key,
    required this.intialOfferController,
  }) : super(key: key);
  final TextEditingController intialOfferController;
  int id;
  var setLoadMarkers;
  @override
  State<NegociarButton> createState() => _NegociarButtonState();
}

class _NegociarButtonState extends State<NegociarButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading
          ? null
          : () async {
              setState(() {
                isLoading = true;
              });
              try {
                Api api = Api();
                Response response = await api.postData(
                    'negotiation/start-negotiation', {
                  'load_id': widget.id,
                  'initial_offer': widget.intialOfferController.text
                });
                if (widget.setLoadMarkers != null) {
                  widget.setLoadMarkers();
                }
                Navigator.of(context).pop();
                if (response.statusCode == 200) {
                  Map jsonResponse = jsonDecode(response.body);
                  if (jsonResponse['success']) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NegotiationChat(
                          jsonResponse['data']['negotiation_id']),
                    ));
                  }
                }
                setState(() {
                  isLoading = false;
                });
              } on SocketException {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compruebe su conexión a internet'),
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ha ocurrido un error'),
                  ),
                );
                setState(() {
                  isLoading = false;
                });
              }
            },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF101010)),
        foregroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFFFFFFFF)),
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 18, horizontal: 10)),
      ),
      child: isLoading
          ? const SizedBox(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
              height: 20,
              width: 20,
            )
          : const Text('Negociar'),
    );
  }
}

class LoadCard extends StatefulWidget {
  LoadCard(this.load,
      {this.hasData = false,
      this.isCarrier = false,
      this.isFinalOffer = false,
      this.onTap,
      this.onClose,
      Key? key})
      : super(key: key);
  Load? load;
  bool hasData, isCarrier, isFinalOffer;
  var onTap;
  var onClose;

  @override
  State<LoadCard> createState() => _LoadCardState();
}

class _LoadCardState extends State<LoadCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 10,
      child: GestureDetector(
        onTap: widget.hasData
            ? () {
                onLoadTap(
                  widget.load!.id,
                  context,
                  widget.load!,
                  widget.isCarrier,
                  widget.onTap,
                  () {},
                  widget.isFinalOffer,
                );
                if (widget.onTap != null) {
                  print('ONTAP');
                  widget.onTap();
                }
              }
            : null,
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: 150,
                  child: widget.hasData
                      ? (widget.load!.attachments.isNotEmpty
                          ? Image.network(
                              Constants.loadImgUrl +
                                  widget.load!.attachments[0]['filename'],
                              loadingBuilder: (context, child,
                                  ImageChunkEvent? loadingProgress) {
                                print(loadingProgress);
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Image.asset(
                                  'assets/img/noimage.png',
                                ),
                              ),
                              fit: BoxFit.fitWidth,
                            )
                          : Image.asset(
                              'assets/img/noimage.png',
                              fit: BoxFit.fitWidth,
                            ))
                      : const SizedBox.shrink()),
              // ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.hasData
                          ? Text(
                              widget.load!.product != ''
                                  ? widget.load!.product
                                  : 'Producto',
                              style: Theme.of(context).textTheme.headline6,
                            )
                          : CustomPaint(
                              painter: OpenPainter(100, 10, 10, -10),
                            ),
                      widget.hasData
                          ? SizedBox(
                              width: 200,
                              child: Text(widget.load!.addressFrom +
                                  ' - ' +
                                  widget.load!.destinAddress))
                          : CustomPaint(
                              painter: OpenPainter(50, 10, 10, 20),
                            ),
                      widget.hasData
                          ? Text(Constants.currencyFormat(widget.isFinalOffer
                              ? widget.load!.finalOffer
                              : widget.load!.initialOffer))
                          : CustomPaint(
                              painter: OpenPainter(50, 10, 10, 20),
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
