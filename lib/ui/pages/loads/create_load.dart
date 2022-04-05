// ignore_for_file: avoid_init_to_null, must_be_immutable, prefer_typing_uninitialized_variables, must_call_super

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/date_picker.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/components/nextprev_buttons.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker _picker = ImagePicker();
List<XFile> imagenes = [];
List imagenesNetwork = [];

bool hasLoadData = false;
int loadId = 0;

List<Category> categories = [];
List<StateModel> states = [];
List<City> cities = [];
PageController pageController = PageController();

TextStyle titleStyles =
    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

//CONTROLADORES DE INPUTS
TextEditingController ubicacionController = TextEditingController(),
    productController = TextEditingController(),
    descriptionController = TextEditingController(),
    categoriaController = TextEditingController(),
    unidadMedidaController = TextEditingController(),
    pesoController = TextEditingController(),
    ofertaInicialController = TextEditingController(),
    vehiculosController = TextEditingController(),
    ayudantesController = TextEditingController(),
    volumenController = TextEditingController(),
    originAddressController = TextEditingController(),
    originCityController = TextEditingController(),
    originStateController = TextEditingController(),
    originCoordsController = TextEditingController(),
    destinAddressController = TextEditingController(),
    destinCityController = TextEditingController(),
    destinStateController = TextEditingController(),
    destinCoordsController = TextEditingController(),
    loadDateController = TextEditingController(),
    loadHourController = TextEditingController(),
    esperaCargaController = TextEditingController(),
    esperaDescargaController = TextEditingController(),
    observacionesController = TextEditingController(),
    isUrgentController = TextEditingController();

// Key latLngInput = Key('Ubicación');

Future getCategories() async {
  try {
    Api api = Api();
    Response response = await api.getData('create-load-data');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        Map data = jsonResponse['data'];
        if (data['categories'].isNotEmpty) {
          categories.clear();
          data['categories'].asMap().forEach((key, category) {
            categories
                .add(Category(id: category['id'], name: category['name']));
          });
        }
        if (data['states'].isNotEmpty) {
          states.clear();
          data['states'].asMap().forEach((key, category) {
            states.add(StateModel(id: category['id'], name: category['name']));
          });
        }
        if (data['cities'].isNotEmpty) {
          cities.clear();
          data['cities'].asMap().forEach((key, city) {
            cities.add(
              City(
                id: city['id'],
                name: city['name'],
                state_id: city['state_id'],
              ),
            );
          });
          return cities;
        }
        return true;
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

class CreateLoadPage extends StatefulWidget {
  const CreateLoadPage({Key? key}) : super(key: key);

  @override
  State<CreateLoadPage> createState() => _CreateLoadPageState();
}

class _CreateLoadPageState extends State<CreateLoadPage> {
  late Position position;
  late final arguments;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        hasLoadData = true;
        loadId = arguments['id'];
        productController.text = arguments['product'];
        pesoController.text = arguments['peso'].toString();
        volumenController.text = arguments['volumen'].toString();
        descriptionController.text = arguments['description'];
        categoriaController.text = arguments['categoria'].toString();
        unidadMedidaController.text = arguments['unidadMedida'];
        ofertaInicialController.text = arguments['ofertaInicial'].toString();
        vehiculosController.text = arguments['vehiculos'].toString();
        ayudantesController.text = arguments['ayudantes'].toString();
        originAddressController.text = arguments['originAddress'];
        originCityController.text = arguments['originCity'].toString();
        originStateController.text = arguments['originState'].toString();
        originCoordsController.text = arguments['originCoords'];
        destinAddressController.text = arguments['destinAddress'];
        destinCityController.text = arguments['destinCity'].toString();
        destinStateController.text = arguments['destinState'].toString();
        destinCoordsController.text = arguments['destinCoords'];
        loadDateController.text = arguments['loadDate'];
        loadHourController.text = arguments['loadHour'];
        esperaCargaController.text = arguments['esperaCarga'].toString();
        esperaDescargaController.text = arguments['esperaDescarga'].toString();
        observacionesController.text = arguments['observaciones'];
        isUrgentController.text = arguments['isUrgent'].toString();
        imagenes.clear();
        imagenesNetwork.clear();
        imagenesNetwork = arguments['imgs'];
      } else {
        loadId = 0;
        imagenes.clear();
        hasLoadData = false;
        ubicacionController.text = '';
        productController.text = '';
        descriptionController.text = '';
        categoriaController.text = '';
        unidadMedidaController.text = '';
        pesoController.text = '';
        ofertaInicialController.text = '';
        vehiculosController.text = '';
        ayudantesController.text = '';
        volumenController.text = '';
        originAddressController.text = '';
        originCityController.text = '';
        originStateController.text = '';
        originCoordsController.text = '';
        destinAddressController.text = '';
        destinCityController.text = '';
        destinStateController.text = '';
        destinCoordsController.text = '';
        loadDateController.text = '';
        loadHourController.text = '';
        esperaCargaController.text = '';
        esperaDescargaController.text = '';
        observacionesController.text = '';
        isUrgentController.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(
        future: getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DatosGenerales(),
                DatosUbicacion(),
                DatosUbicacionDelivery(),
                PaginaFinal(),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class DatosGenerales extends StatelessWidget {
  const DatosGenerales({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        margin: const EdgeInsets.only(
          top: 70,
          left: 20,
          right: 20,
        ),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                bottom: 60,
                right: 20,
              ),
              children: [
                const ImagesPicker(),
                const SizedBox(
                  height: 20,
                ),
                //producto
                CustomFormField(productController, 'Producto *', maxLength: 10),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    //Categoría
                    Flexible(
                      child: CategoriaSelect(),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(child: MeasurementUnit()),
                    //Unidad de medida
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    //Peso
                    Flexible(
                      child: CustomFormField(
                        pesoController,
                        'Peso *',
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        defaultValue: '0',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    //Volumen
                    Flexible(
                      child: CustomFormField(
                        volumenController,
                        'Volumen',
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                        defaultValue: '0',
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    //Vehiculos requeridos
                    Flexible(
                      child: CustomFormField(
                        vehiculosController,
                        'Cant. vehículos *',
                        type: TextInputType.number,
                        defaultValue: '1',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    //Ayudante requeridos
                    Flexible(
                      child: CustomFormField(
                        ayudantesController,
                        'Ayudantes *',
                        type: TextInputType.number,
                        defaultValue: '0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                //Precio
                CustomFormField(
                  ofertaInicialController,
                  'Oferta inicial *',
                  type: TextInputType.number,
                  defaultValue: '0',
                ),
                const SizedBox(
                  height: 20,
                ),
                //Descripción
                CustomFormField(descriptionController, 'Descripción *',
                    type: TextInputType.multiline,
                    action: TextInputAction.newline,
                    maxLines: 5,
                    radius: 10),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Flexible(
                    child: NextPageButton(
                      pageController,
                      validator: () {
                        if (productController.text == '') {
                          return false;
                        }
                        if (pesoController.text == '') {
                          return false;
                        }
                        if (volumenController.text == '') {
                          return false;
                        }
                        if (vehiculosController.text == '') {
                          return false;
                        }
                        if (ayudantesController.text == '') {
                          return false;
                        }
                        if (ofertaInicialController.text == '') {
                          return false;
                        }
                        if (descriptionController.text == '') {
                          return false;
                        }
                        return true;
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ImagesPicker extends StatefulWidget {
  const ImagesPicker({
    Key? key,
  }) : super(key: key);

  @override
  State<ImagesPicker> createState() => _ImagesPickerState();
}

class _ImagesPickerState extends State<ImagesPicker> {
  int currentImage = 0;
  int totalIndex = 0;
  PageController imagePageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: (imagenes.isNotEmpty || imagenesNetwork.isNotEmpty)
            ? Colors.transparent
            : Colors.grey[200],
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: (imagenes.isNotEmpty || imagenesNetwork.isNotEmpty)
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView(
                    controller: imagePageController,
                    onPageChanged: (value) => setState(() {
                          currentImage = value;
                        }),
                    children: [
                      ...List.generate(
                        imagenesNetwork.length,
                        (index) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        minScale: 0.5,
                                        maxScale: 4,
                                        clipBehavior: Clip.none,
                                        child: Image.network(loadImgUrl +
                                            imagenesNetwork[index]['filename']),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.white,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Image.network(
                                    loadImgUrl +
                                        imagenesNetwork[index]['filename'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: TextButton(
                                  onPressed: () async {
                                    Api api = Api();

                                    Response response = await api.postData(
                                      'load/load-image-delete',
                                      {
                                        'id': imagenesNetwork[index]['id'],
                                      },
                                    );

                                    imagenesNetwork.removeAt(index);
                                    setState(() {});
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.close,
                                      color: kBlack,
                                    ),
                                  ),
                                ),
                                top: 20,
                                right: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                      ...List.generate(
                        imagenes.length,
                        (index) => Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: InteractiveViewer(
                                      panEnabled: true,
                                      minScale: 0.5,
                                      maxScale: 4,
                                      clipBehavior: Clip.none,
                                      child: Image.file(
                                        File(imagenes[index].path),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: Image.file(
                                  File(imagenes[index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: TextButton(
                                onPressed: () async {
                                  imagenes.removeAt(index);
                                  setState(() {});
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.close,
                                    color: kBlack,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          List<XFile>? imgs = await _picker.pickMultiImage();
                          imagenes.addAll((imgs ?? []));
                          if (imagenes.isNotEmpty) {
                            setState(() {
                              // imagePageController.jumpToPage(0);
                            });
                          }
                        },
                        child: Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.add,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]),
                Positioned(
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      (imagenes.length + imagenesNetwork.length + 1),
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
            )
          : GestureDetector(
              onTap: () async {
                List<XFile>? imgs = await _picker.pickMultiImage();
                imagenes.addAll((imgs ?? []));
                if (imagenes.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      // imagePageController.jumpToPage(0);
                    });
                  }
                }
              },
              child: Container(
                color: Colors.grey,
                child: const Icon(
                  Icons.add,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

class MeasurementUnit extends StatefulWidget {
  const MeasurementUnit({Key? key}) : super(key: key);

  @override
  State<MeasurementUnit> createState() => _MeasurementUnitState();
}

class _MeasurementUnitState extends State<MeasurementUnit> {
  String value = '1';
  @override
  Widget build(BuildContext context) {
    unidadMedidaController.text = unidadMedidaController.text == ''
        ? unidadMedidaController.text = value
        : unidadMedidaController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unidad de medida'),
        DropdownButton(
            value: value,
            icon: const Icon(Icons.arrow_circle_down_outlined),
            elevation: 16,
            style: Theme.of(context).textTheme.bodyText2,
            isExpanded: true,
            underline: Container(
              height: 2,
              color: Theme.of(context)
                  .inputDecorationTheme
                  .border!
                  .borderSide
                  .color,
            ),
            onChanged: (String? newValue) {
              setState(() {
                value = newValue!;
                unidadMedidaController.text = newValue;
              });
            },
            items: const [
              DropdownMenuItem(
                child: Text('Kilo'),
                value: '1',
              )
            ])
      ],
    );
  }
}

class CategoriaSelect extends StatefulWidget {
  const CategoriaSelect({Key? key}) : super(key: key);

  @override
  State<CategoriaSelect> createState() => _CategoriaSelectState();
}

class _CategoriaSelectState extends State<CategoriaSelect> {
  late String value = categoriaController.text != ''
      ? categoriaController.text
      : categories[0].id.toString();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría'),
        DropdownButton(
          value: (categories.isNotEmpty ? value : categories[0].id.toString()),
          icon: const Icon(Icons.arrow_circle_down_outlined),
          elevation: 16,
          style: Theme.of(context).textTheme.bodyText2,
          isExpanded: true,
          underline: Container(
            height: 2,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          onChanged: (String? newValue) {
            setState(() {
              value = newValue!;
              categoriaController.text = newValue;
            });
          },
          items: List.generate(
            categories.length,
            (index) {
              return DropdownMenuItem(
                child: Text(categories[index].name),
                value: categories[index].id.toString(),
              );
            },
          ),
        )
      ],
    );
  }
}

//PAGINA DE UBICACION ORIGEN
class DatosUbicacion extends StatefulWidget {
  const DatosUbicacion({Key? key}) : super(key: key);

  @override
  State<DatosUbicacion> createState() => _DatosUbicacionState();
}

class _DatosUbicacionState extends State<DatosUbicacion> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(
        top: 70,
        left: 20,
        right: 20,
      ),
      child: Stack(children: [
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            bottom: 60,
            right: 20,
          ),
          children: [
            Text(
              'Dónde está tu carga?',
              style: titleStyles,
            ),
            const SizedBox(
              height: 20,
            ),
            const StateAndCityPicker(),
            const SizedBox(
              height: 20,
            ),
            SearchPlace(originAddressController, originCoordsController),
            Visibility(
              child: CustomFormField(originCoordsController, 'Coordenadas'),
              visible: false,
            ),
            const SizedBox(
              height: 40,
            ),
            // ButtonBar(
            //   alignment: MainAxisAlignment.center,
            //   children: [
            //     const Flexible(
            //       child: PrevPageButton(pageController),
            //     ),
            //     Flexible(
            //       child: NextPageButton(
            //         validator: (callback) {
            //           if (originStateController.text == '') {
            //             return false;
            //           }
            //           if (originCityController.text == '') {
            //             return false;
            //           }
            //           if (originAddressController.text == '') {
            //             return false;
            //           }
            //           if (originCoordsController.text == '') {
            //             return false;
            //           }
            //           callback();
            //           return true;
            //         },
            //       ),
            //     ),
            //   ],
            // )
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Flexible(
                child: PrevPageButton(pageController),
              ),
              Flexible(
                child: NextPageButton(pageController),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class SearchPlace extends StatefulWidget {
  SearchPlace(this.addressController, this.coordsController, {Key? key})
      : super(key: key);
  TextEditingController addressController;
  TextEditingController coordsController;
  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace>
    with AutomaticKeepAliveClientMixin {
  late GoogleMapController mapController;
  //ESTILOS DEL MAPA
  String _darkMapStyle = '';

  setMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/google_map_styles.json');
    mapController.setMapStyle(_darkMapStyle);
  }

  //coordenada inicial
  late Position position;
  //LISTA DE MARCADORES
  List<Marker> markers = [];

//OBTIENE LA POSICIÓN DEL USUARIO
  getPosition() async {
    position = await Geolocator.getCurrentPosition();
    setState(() {
      mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude)));
    });
  }

  goToPlace(Map<String, dynamic> place) async {
    double lat = place['geometry']['location']['lat'];
    double lng = place['geometry']['location']['lng'];
    setState(() {
      setMarker(LatLng(lat, lng));
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16),
      );
    });
  }

  setMarker(LatLng argument) {
    widget.coordsController.text =
        argument.latitude.toString() + ',' + argument.longitude.toString();
    setState(() {
      markers = [
        Marker(
            markerId: MarkerId(argument.latitude.toString() + '_location'),
            position: LatLng(
              argument.latitude,
              argument.longitude,
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) => widget.coordsController.text =
                newPosition.latitude.toString() +
                    ',' +
                    newPosition.longitude.toString()),
      ];
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setMapStyles();
    // mapController.setMapStyle('');
    getPosition();
    if (widget.coordsController.text != '') {
      setMarker(LatLng(double.parse(widget.coordsController.text.split(',')[0]),
          double.parse(widget.coordsController.text.split(',')[1])));
    }
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: CustomFormField(
                widget.addressController,
                'Dirección *',
                action: TextInputAction.done,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              onPressed: loading
                  ? () {}
                  : () async {
                      setState(() => loading = !loading);
                      Map<String, dynamic> place = await LocationService()
                          .getPlace(widget.addressController.text);
                      goToPlace(place);
                      setState(() => loading = !loading);
                    },
              style: ButtonStyle(
                side: MaterialStateProperty.all<BorderSide>(const BorderSide(
                    style: BorderStyle.solid, width: 1, color: Colors.grey)),
              ),
              child: const Icon(Icons.search),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Stack(
            children: [
              GoogleMap(
                key: widget.key,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                onTap: (argument) => setMarker(argument),
                initialCameraPosition: CameraPosition(
                  // target: LatLng(-25.27705190025039, -57.63737049639007),
                  target: LatLng(
                      (widget.coordsController.text != ''
                          ? double.parse(
                              widget.coordsController.text.split(',')[0])
                          : -25.27705190025039),
                      (widget.coordsController.text != ''
                          ? double.parse(
                              widget.coordsController.text.split(',')[1])
                          : -57.63737049639007)),
                  zoom: 11.0,
                ),
                markers: markers.map((e) => e).toSet(),
              ),
              loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class StateAndCityPicker extends StatefulWidget {
  const StateAndCityPicker({Key? key}) : super(key: key);

  @override
  State<StateAndCityPicker> createState() => _StateAndCityPickerState();
}

class _StateAndCityPickerState extends State<StateAndCityPicker> {
  String departamentoId = originStateController.text != ''
      ? originStateController.text
      : states[0].id.toString();
  List<City> newCities = cities;
  late String value;
  @override
  Widget build(BuildContext context) {
    value = newCities[0].id.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: DepartamentoPicker(originStateController, (newVal) {
            setState(() {
              departamentoId = newVal;

              newCities = cities.where((element) {
                return element.state_id.toString() == departamentoId;
              }).toList();
              value = newCities[0].id.toString();
            });
          }),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: CityPicker(originCityController, value, newCities),
        )
      ],
    );
  }
}

//PAGINA DE UBICACION ENTREGA

class DatosUbicacionDelivery extends StatefulWidget {
  const DatosUbicacionDelivery({Key? key}) : super(key: key);

  @override
  State<DatosUbicacionDelivery> createState() => _DatosUbicacionDeliveryState();
}

class _DatosUbicacionDeliveryState extends State<DatosUbicacionDelivery> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(
        top: 70,
        left: 20,
        right: 20,
      ),
      child: Stack(children: [
        ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            bottom: 60,
            right: 20,
          ),
          children: [
            Text(
              'Dónde quieres llevarla?',
              style: titleStyles,
            ),
            const SizedBox(
              height: 20,
            ),
            const DestinStateAndCityPicker(),
            const SizedBox(
              height: 20,
            ),
            SearchPlace(destinAddressController, destinCoordsController),
            const SizedBox(
              height: 20,
            ),
            Visibility(
              child: CustomFormField(destinCoordsController, 'Coordenadas'),
              visible: false,
            ),
            const SizedBox(
              height: 40,
            ),
            // ButtonBar(
            //   alignment: MainAxisAlignment.center,
            //   children: [
            //     const Flexible(
            //       child: PrevPageButton(pageController),
            //     ),
            //     Flexible(
            //       child: NextPageButton(pageController),
            //     ),
            //   ],
            // )
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            children: [
              Flexible(
                child: PrevPageButton(pageController),
              ),
              Flexible(
                child: NextPageButton(pageController),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class DestinStateAndCityPicker extends StatefulWidget {
  const DestinStateAndCityPicker({Key? key}) : super(key: key);

  @override
  State<DestinStateAndCityPicker> createState() =>
      _DestinStateAndCityPickerState();
}

class _DestinStateAndCityPickerState extends State<DestinStateAndCityPicker> {
  String departamentoId = destinStateController.text != ''
      ? destinStateController.text
      : states[0].id.toString();
  List<City> newCities = cities;
  late String value;
  @override
  Widget build(BuildContext context) {
    value = newCities[0].id.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: DepartamentoPicker(destinStateController, (newVal) {
            setState(() {
              departamentoId = newVal;

              newCities = cities.where((element) {
                return element.state_id.toString() == departamentoId;
              }).toList();
              value = newCities[0].id.toString();
            });
          }),
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: CityPicker(destinCityController, value, newCities),
        ),
      ],
    );
  }
}

class DepartamentoPicker extends StatefulWidget {
  DepartamentoPicker(this.controller, this.onChange, {Key? key})
      : super(key: key);
  TextEditingController controller;
  var onChange;
  @override
  State<DepartamentoPicker> createState() => _DepartamentoPickerState();
}

class _DepartamentoPickerState extends State<DepartamentoPicker> {
  late String value = widget.controller.text != ''
      ? widget.controller.text
      : states[0].id.toString();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departamento'),
        DropdownButton(
          value: widget.controller.text != ''
              ? widget.controller.text
              : (states.isNotEmpty ? value : states[0].id.toString()),
          icon: const Icon(Icons.arrow_circle_down_outlined),
          elevation: 16,
          isExpanded: true,
          style: Theme.of(context).textTheme.bodyText2,
          underline: Container(
            height: 2,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          onChanged: (String? newValue) {
            widget.onChange(newValue);
            setState(() {
              value = newValue!;
              widget.controller.text = newValue;
            });
          },
          items: List.generate(
            states.length,
            (index) {
              return DropdownMenuItem(
                child: Text(states[index].name),
                value: states[index].id.toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CityPicker extends StatefulWidget {
  CityPicker(this.controller, this.value, this.newCities, {Key? key})
      : super(key: key);
  List<City> newCities;
  TextEditingController controller;
  String value;
  @override
  State<CityPicker> createState() => CityPickerState();
}

class CityPickerState extends State<CityPicker> {
  late List<City> newCities;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    newCities = widget.newCities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ciudad'),
        DropdownButton(
          value: widget.value,
          icon: const Icon(Icons.arrow_circle_down_outlined),
          isExpanded: true,
          elevation: 16,
          style: Theme.of(context).textTheme.bodyText2,
          underline: Container(
            height: 2,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          onChanged: (String? newValue) {
            setState(() {
              widget.value = newValue!;
              widget.controller.text = newValue;
            });
          },
          items: List.generate(
            newCities.length,
            (index) {
              return DropdownMenuItem(
                child: Text(newCities[index].name),
                value: newCities[index].id.toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}

//PAGINA FINAL DEL FORMULARIO
class PaginaFinal extends StatelessWidget {
  const PaginaFinal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(
        top: 70,
        left: 20,
        right: 20,
      ),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              top: 40,
              left: 20,
              bottom: 60,
              right: 20,
            ),
            children: [
              Text(
                'Cuándo debe ser recogida?',
                style: titleStyles,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    child: DatePicker(loadDateController, 'Fecha de carga'),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: LoadTimePicker(loadHourController, 'Hora de carga'),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    child: CustomFormField(
                      esperaCargaController,
                      'Espera en carga',
                      type: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: CustomFormField(
                        esperaDescargaController, 'Espera en descarga',
                        type: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: const [
                  Flexible(
                    child: IsUrgent(),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Danos más detalles de tu carga',
                style: titleStyles,
              ),
              const SizedBox(
                height: 20,
              ),

              //Descripción
              CustomFormField(
                observacionesController,
                'Observaciones',
                type: TextInputType.multiline,
                action: TextInputAction.newline,
                maxLines: 5,
                radius: 10,
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Flexible(
                  child: PrevPageButton(pageController),
                ),
                const Flexible(child: EnviarButton())
              ],
            ),
          )
        ],
      ),
    );
  }
}

class IsUrgent extends StatefulWidget {
  const IsUrgent({Key? key}) : super(key: key);

  @override
  State<IsUrgent> createState() => _IsUrgentState();
}

class _IsUrgentState extends State<IsUrgent> {
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Es urgente?'),
        const SizedBox(
          width: 20,
        ),
        Switch(
          value: checked,
          activeColor: const Color(0xFFF58633),
          onChanged: (newVal) => setState(
            () {
              checked = newVal;
              isUrgentController.text = checked ? '1' : '0';
            },
          ),
        )
      ],
    );
  }
}

class EnviarButton extends StatefulWidget {
  const EnviarButton({Key? key}) : super(key: key);

  @override
  State<EnviarButton> createState() => _EnviarButtonState();
}

class _EnviarButtonState extends State<EnviarButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 20)),
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(0xFFF58633),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      onPressed: isLoading
          ? () {}
          : () async {
              isLoading = !isLoading;
              setState(() {});
              Load load = Load();
              print(imagenes);
              await load.createLoad({
                'description': descriptionController.text,
                'vehicle_type_id': 1,
                'product_category_id': categoriaController.text,
                'product': productController.text,
                'vehicles_quantity': vehiculosController.text,
                'helpers_quantity': ayudantesController.text,
                'weight': pesoController.text,
                'measurement_unit_id': unidadMedidaController.text,
                'initial_offer': ofertaInicialController.text,
                'state_id': originStateController.text,
                'city_id': originCityController.text,
                'address': originAddressController.text,
                'latitude':
                    originCoordsController.text.split(',')[0].toString(),
                'longitude':
                    originCoordsController.text.split(',')[1].toString(),
                'destination_state_id': destinStateController.text,
                'destination_city_id': destinCityController.text,
                'destination_address': destinAddressController.text,
                'destination_latitude':
                    destinCoordsController.text.split(',')[0].toString(),
                'destination_longitude':
                    destinCoordsController.text.split(',')[1].toString(),
                'pickup_at': loadDateController.text,
                'pickup_time': loadHourController.text,
                'payment_term_after_delivery': 1,
                'wait_in_origin': esperaCargaController.text,
                'wait_in_destination': esperaDescargaController.text,
                'observatios': observacionesController.text,
                'is_urgent': isUrgentController.text == '1',
                'loadId': loadId
              }, imagenes,
                  context: context, update: hasLoadData, loadId: loadId);
              isLoading = !isLoading;
              setState(() {});
            },
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Enviar', style: TextStyle(color: Colors.white)),
                Icon(Icons.upload, color: Colors.white)
              ],
            ),
    );
  }
}
