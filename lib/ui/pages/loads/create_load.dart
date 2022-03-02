// ignore_for_file: avoid_init_to_null, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/google_map.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker _picker = ImagePicker();
List<XFile> imagenes = [];

bool hasLoadData = false;
int loadId = 0;

List<Category> categories = [];
List<StateModel> states = [];
List<City> cities = [];
PageController pageController = PageController();
late AfletesGoogleMap originMap;
late AfletesGoogleMap deliveryMap;

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
  Api api = Api();
  Response response = await api.getData('create-load-data');
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      Map data = jsonResponse['data'];
      if (data['categories'].isNotEmpty) {
        categories.clear();
        data['categories'].asMap().forEach((key, category) {
          categories.add(Category(id: category['id'], name: category['name']));
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
          cities.add(City(
              id: city['id'], name: city['name'], state_id: city['state_id']));
        });
        return cities;
      }
      return true;
    }
  }
  return true;
}

class CreateLoadPage extends StatefulWidget {
  CreateLoadPage({Key? key}) : super(key: key);

  @override
  State<CreateLoadPage> createState() => _CreateLoadPageState();
}

class _CreateLoadPageState extends State<CreateLoadPage> {
  late Position position;
  late final arguments;
  @override
  void initState() {
    super.initState();
    //MAPA DE CARGA
    originMap = AfletesGoogleMap(onTap: (LatLng argument) {
      originCoordsController.text =
          argument.latitude.toString() + ',' + argument.longitude.toString();
    });

    //MAPA DE ENTREGA
    deliveryMap = AfletesGoogleMap(onTap: (LatLng argument) {
      destinCoordsController.text =
          argument.latitude.toString() + ',' + argument.longitude.toString();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      arguments = ModalRoute.of(context)!.settings.arguments;
      if (arguments != null) {
        hasLoadData = true;
        loadId = arguments['id'];
        print(loadId);
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(FutureBuilder(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DatosGenerales(),
              DatosUbicacion(),
              DatosUbicacionDelivery(),
              const PaginaFinal(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    ));
  }
}

class DatosGenerales extends StatelessWidget {
  DatosGenerales({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ImagesPicker(),
          //producto
          LoadFormField(productController, 'Producto *', maxLength: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Categoría
              CategoriaSelect(),
              //Unidad de medida
              MeasurementUnit()
            ],
          ),
          Row(
            children: [
              //Peso
              Flexible(
                child: LoadFormField(
                  pesoController,
                  'Peso *',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              //Volumen
              Flexible(
                child: LoadFormField(
                  volumenController,
                  'Volumen',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              )
            ],
          ),
          Row(
            children: [
              //Vehiculos requeridos
              Flexible(
                child: LoadFormField(
                  vehiculosController,
                  'Vehículos requeridos',
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              //Ayudante requeridos
              Flexible(
                child: LoadFormField(
                  ayudantesController,
                  'Ayudantes requeridos',
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          //Precio
          LoadFormField(
            ofertaInicialController,
            'Oferta inicial',
            type: TextInputType.number,
          ),
          //Descripción
          LoadFormField(
            descriptionController,
            'Descripción',
            type: TextInputType.multiline,
            action: TextInputAction.next,
          ),
          const SizedBox(
            height: 20,
          ),
          NextPageButton(
            validator: (callback) {
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
              callback();
              return true;
            },
          )
        ],
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
  PageController imagePageController = PageController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        List<XFile>? imgs = await _picker.pickMultiImage();
        imagenes = imgs ?? [];
        if (imagenes.isNotEmpty) {
          setState(() {
            // imagePageController.jumpToPage(0);
          });
        }
      },
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.4,
        color: imagenes.isNotEmpty ? Colors.transparent : Colors.grey[200],
        child: imagenes.isNotEmpty
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView(
                    controller: imagePageController,
                    onPageChanged: (value) => setState(() {
                      currentImage = value;
                    }),
                    children: List.generate(
                      imagenes.length,
                      (index) => InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4,
                          clipBehavior: Clip.none,
                          child: Image.file(
                            File(imagenes[index].path),
                          )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        imagenes.length,
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
            : const Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 50,
                ),
              ),
      ),
    );
  }
}

class MeasurementUnit extends StatefulWidget {
  MeasurementUnit({Key? key}) : super(key: key);

  @override
  State<MeasurementUnit> createState() => _MeasurementUnitState();
}

class _MeasurementUnitState extends State<MeasurementUnit> {
  String value = '1';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unidad de medida'),
        DropdownButton(
            value: value,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
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
  CategoriaSelect({Key? key}) : super(key: key);

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
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {
            setState(() {
              value = newValue!;
              categoriaController.text = newValue;
            });
            // print(newValue);
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
  DatosUbicacion({Key? key}) : super(key: key);

  @override
  State<DatosUbicacion> createState() => _DatosUbicacionState();
}

class _DatosUbicacionState extends State<DatosUbicacion>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Dónde está tu carga?',
            style: titleStyles,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DepartamentoPicker(originStateController),
              CityPicker(originCityController)
            ],
          ),
          LoadFormField(
            originAddressController,
            'Dirección *',
            action: TextInputAction.done,
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: AfletesGoogleMap(onTap: (LatLng argument) {
              originCoordsController.text = argument.latitude.toString() +
                  ',' +
                  argument.longitude.toString();
            }),
          ),
          Visibility(
            child: LoadFormField(originCoordsController, 'Coordenadas'),
            visible: false,
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              PrevPageButton(),
              NextPageButton(
                validator: (callback) {
                  if (originStateController.text == '') {
                    return false;
                  }
                  if (originCityController.text == '') {
                    return false;
                  }
                  if (originAddressController.text == '') {
                    return false;
                  }
                  if (originCoordsController.text == '') {
                    return false;
                  }
                  callback();
                  return true;
                },
              ),
            ],
          )
        ]);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

//PAGINA DE UBICACION ENTREGA

class DatosUbicacionDelivery extends StatefulWidget {
  DatosUbicacionDelivery({Key? key}) : super(key: key);

  @override
  State<DatosUbicacionDelivery> createState() => _DatosUbicacionDeliveryState();
}

class _DatosUbicacionDeliveryState extends State<DatosUbicacionDelivery>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Dónde quieres llevarla?',
            style: titleStyles,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DepartamentoPicker(destinStateController),
              CityPicker(destinCityController)
            ],
          ),
          LoadFormField(
            destinAddressController,
            'Dirección *',
            action: TextInputAction.next,
          ),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            child: deliveryMap,
          ),
          SizedBox(
            height: 0,
            child: LoadFormField(destinCoordsController, 'Coordenadas'),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              PrevPageButton(),
              NextPageButton(
                validator: (callback) {
                  if (destinStateController.text == '') {
                    return false;
                  }
                  if (destinCityController.text == '') {
                    return false;
                  }
                  if (destinAddressController.text == '') {
                    return false;
                  }
                  if (destinCoordsController.text == '') {
                    return false;
                  }
                  callback();
                  return true;
                },
              ),
            ],
          )
        ]);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class DepartamentoPicker extends StatefulWidget {
  DepartamentoPicker(this.controller, {Key? key}) : super(key: key);
  TextEditingController controller;
  @override
  State<DepartamentoPicker> createState() => _DepartamentoPickerState();
}

class _DepartamentoPickerState extends State<DepartamentoPicker> {
  late String value = states[0].id.toString();
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
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {
            setState(() {
              value = newValue!;
              widget.controller.text = newValue;
            });
            // print(newValue);
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
  CityPicker(this.controller, {Key? key}) : super(key: key);
  TextEditingController controller;
  @override
  State<CityPicker> createState() => CityPickerState();
}

class CityPickerState extends State<CityPicker> {
  late String value = cities[0].id.toString();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ciudad'),
        DropdownButton(
          value: widget.controller.text != ''
              ? widget.controller.text
              : (cities.isNotEmpty ? value : cities[0].id.toString()),
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? newValue) {
            setState(() {
              value = newValue!;
              widget.controller.text = newValue;
            });
            // print(newValue);
          },
          items: List.generate(
            cities.length,
            (index) {
              return DropdownMenuItem(
                child: Text(cities[index].name),
                value: cities[index].id.toString(),
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
    print(imagenes);
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(
        children: [
          Flexible(
            child: DatePicker(loadDateController, 'Fecha de carga'),
          ),
          Flexible(
            child: LoadTimePicker(loadHourController, 'Hora de carga'),
          ),
        ],
      ),
      Row(
        children: [
          Flexible(
            child: LoadFormField(
              esperaCargaController,
              'Espera en carga',
              type: TextInputType.number,
            ),
          ),
          Flexible(
            child: LoadFormField(esperaDescargaController, 'Espera en descarga',
                type: TextInputType.number),
          ),
        ],
      ),
      Row(
        children: [
          Flexible(
            child: IsUrgent(),
          ),
          // Flexible(
          //     child: LoadFormField(
          //   loadDateController,
          //   'Cargar Imágenes',
          //   onFocus: () => _picker,
          //   showCursor: true,
          //   readOnly: true,
          // ))
        ],
      ),

      //Descripción
      LoadFormField(
        observacionesController,
        'Observaciones',
        type: TextInputType.multiline,
        action: TextInputAction.next,
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          const PrevPageButton(),
          IconButton(
              onPressed: () async {
                Load load = Load();
                load.createLoad({
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
                  'loadId': loadId
                }, imagenes,
                    context: context, update: hasLoadData, loadId: loadId);
              },
              icon: const Icon(Icons.upload))
        ],
      )
    ]);
  }
}

class IsUrgent extends StatefulWidget {
  IsUrgent({Key? key}) : super(key: key);

  @override
  State<IsUrgent> createState() => _IsUrgentState();
}

class _IsUrgentState extends State<IsUrgent> {
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Es urgente?'),
        Checkbox(
          value: checked,
          onChanged: (newVal) => setState(
            () {
              checked = newVal!;
              isUrgentController.text = checked ? '1' : '0';
            },
          ),
        )
      ],
    );
  }
}

class DatePicker extends StatefulWidget {
  DatePicker(this.controller, this.title, {Key? key}) : super(key: key);
  TextEditingController controller;
  String title;
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = selectedDate.year.toString() +
            '-' +
            selectedDate.month.toString() +
            '-' +
            selectedDate.day.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadFormField(
      widget.controller,
      widget.title,
      onFocus: () => _selectDate(context),
      showCursor: true,
      readOnly: true,
    );
  }
}

class LoadTimePicker extends StatefulWidget {
  LoadTimePicker(this.controller, this.title, {Key? key}) : super(key: key);
  TextEditingController controller;
  String title;
  @override
  State<LoadTimePicker> createState() => Load_TimePickerState();
}

class Load_TimePickerState extends State<LoadTimePicker> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.controller.text =
            selectedTime.hour.toString() + ':' + selectedTime.minute.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadFormField(
      widget.controller,
      widget.title,
      onFocus: () => _selectTime(context),
      showCursor: true,
      readOnly: true,
    );
  }
}

//COMPONENTES

class NextPageButton extends StatelessWidget {
  NextPageButton({validator, Key? key}) : super(key: key);
  var validator;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => (validator != null
            ? validator(() => pageController.nextPage(
                duration: const Duration(milliseconds: 100),
                curve: Curves.ease))
            : pageController.nextPage(
                duration: const Duration(milliseconds: 100),
                curve: Curves.ease)),
        icon: const Icon(Icons.navigate_next));
  }
}

class PrevPageButton extends StatelessWidget {
  const PrevPageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => pageController.previousPage(
            duration: const Duration(milliseconds: 100), curve: Curves.ease),
        icon: const Icon(Icons.navigate_before));
  }
}

class LoadFormField extends StatelessWidget {
  LoadFormField(this.controller, this.label,
      {this.maxLength = 255,
      this.type = TextInputType.text,
      this.autofocus = false,
      this.showCursor = null,
      this.readOnly = false,
      this.onFocus = null,
      this.icon = null,
      this.action = TextInputAction.next,
      Key? key})
      : super(key: key);
  bool autofocus;
  bool? showCursor;
  bool readOnly;
  var onFocus;
  TextEditingController controller;
  TextInputType type;
  int maxLength;
  Icon? icon;
  String label;
  TextInputAction action;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onFocus,
      showCursor: showCursor,
      readOnly: readOnly,
      autofocus: autofocus,
      controller: controller,
      keyboardType: type,
      maxLength: maxLength != 255 ? maxLength : null,
      decoration: InputDecoration(prefixIcon: icon, label: Text(label)),
    );
  }
}
