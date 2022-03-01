// ignore_for_file: avoid_init_to_null, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/google_map.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker _picker = ImagePicker();
List<XFile> imagenes = [];

bool hasVehicleData = false;
int vehicleId = 0;

List brands = [];
List<DropdownMenuItem<String>> brandsSelectList = [];
PageController pageController = PageController();
late AfletesGoogleMap originMap;
late AfletesGoogleMap deliveryMap;

late XFile? greenCard;
late XFile? greenCardBack;
late XFile? municipal;
late XFile? municipalBack;
late XFile? dinatran;
late XFile? dinatranBack;
late XFile? senacsa;
late XFile? senacsaBack;
late XFile? seguro;

//CONTROLADORES DE INPUTS
TextEditingController chapaController = TextEditingController(),
    marcaController = TextEditingController(),
    modeloController = TextEditingController(),
    fabricacionController = TextEditingController(),
    unidadMedidaController = TextEditingController(),
    pesoController = TextEditingController(),
    vtoMunicipalController = TextEditingController(),
    vtoDinatranController = TextEditingController(),
    vtoSenacsaController = TextEditingController(),
    vtoSeguroController = TextEditingController();

// Key latLngInput = Key('Ubicación');

Future getBrands() async {
  Api api = Api();
  Response response = await api.getData('get-brands');
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      List data = jsonResponse['data'];
      if (data.isNotEmpty) {
        brands.clear();
        data.asMap().forEach((key, brand) {
          brands.add({'name': brand['name'], 'id': brand['id']});
        });
        brandsSelectList = List.generate(
          brands.length,
          (index) {
            return DropdownMenuItem(
              child: Text(brands[index]['name']),
              value: brands[index]['id'].toString(),
            );
          },
        );
      }
      return true;
    }
  }
  return true;
}

class CreateVehicle extends StatefulWidget {
  CreateVehicle({Key? key}) : super(key: key);

  @override
  State<CreateVehicle> createState() => _CreateVehicleState();
}

class _CreateVehicleState extends State<CreateVehicle> {
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
        hasVehicleData = true;
        vehicleId = arguments['id'];
        chapaController.text = arguments['chapa'];
        pesoController.text = arguments['peso'].toString();
        modeloController.text = arguments['modelo'] ?? '';
        marcaController.text = arguments['marca'].toString();
        fabricacionController.text = arguments['fabricacion'].toString();
        unidadMedidaController.text = arguments['unidadMedida'].toString();
        vtoMunicipalController.text = arguments['vtoMunicipal'];
        vtoDinatranController.text = arguments['vtoDinatran'];
        vtoSenacsaController.text = arguments['vtoSenacsa'];
        vtoSeguroController.text = arguments['vtoSeguro'];
      } else {
        hasVehicleData = false;
        vehicleId = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(FutureBuilder(
      future: getBrands(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              DatosGenerales(),
              const Documentos(),
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
          //chapa
          LoadFormField(chapaController, 'Dominio o chapa *'),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Marca
              MarcaSelect(),
              const SizedBox(
                width: 20,
              ),
              //Modelo
              Flexible(
                child: LoadFormField(
                  modeloController,
                  'Modelo *',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          Row(
            children: [
              MeasurementUnit(),
              const SizedBox(
                width: 20,
              ),
              //Peso
              Flexible(
                child: LoadFormField(
                  pesoController,
                  'Peso *',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),

          LoadFormField(
            fabricacionController,
            'Año de producción *',
            type: const TextInputType.numberWithOptions(decimal: true),
          ),
          const NextPageButton()
        ],
      ),
    );
  }
}

class Documentos extends StatelessWidget {
  const Documentos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Row(
        children: [
          ImageInput(
              'Cédula verde (Frente)', (XFile img) => greenCard = img, 170),
          const SizedBox(
            width: 20,
          ),
          ImageInput(
              'Cédula verde (Atras)', (XFile img) => greenCardBack = img, 170),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          ImageInput(
              'Habilitación Munic.', (XFile img) => municipal = img, 170),
          const SizedBox(
            width: 20,
          ),
          ImageInput('Habilitación Munic. (Atras)',
              (XFile img) => municipalBack = img, 170),
        ],
      ),
      DatePicker(
          vtoMunicipalController, 'Fecha de vto. Habilitación Municipal'),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          ImageInput(
              'Habilitación DINATRAN', (XFile img) => dinatran = img, 170),
          const SizedBox(
            width: 20,
          ),
          ImageInput('Habilitación DINATRAN (Atras)',
              (XFile img) => dinatranBack = img, 170),
        ],
      ),
      DatePicker(vtoDinatranController, 'Fecha de vto. Habilitación DINATRAN'),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          ImageInput('Habilitación SENACSA', (XFile img) => senacsa = img, 170),
          const SizedBox(
            width: 20,
          ),
          ImageInput('Habilitación SENACSA (Atras)',
              (XFile img) => senacsaBack = img, 170),
        ],
      ),
      DatePicker(vtoSenacsaController, 'Fecha de vto. Habilitación SENACSA'),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          ImageInput('Seguro', (XFile img) => seguro = img, 170),
        ],
      ),
      DatePicker(vtoSeguroController, 'Fecha de vto. Seguro'),
      ButtonBar(
        children: [
          const PrevPageButton(),
          IconButton(
              onPressed: () async {
                Vehicle vehicle = Vehicle();
                vehicle.createVehicle(
                  {
                    'license_plate': chapaController.text,
                    'vehicle_brand_id': marcaController.text,
                    'year_of_production': fabricacionController.text,
                    'max_capacity': pesoController.text,
                    'measurement_unit_id': unidadMedidaController.text,
                    'model': modeloController.text,
                    'expiration_date_vehicle_authorization':
                        vtoMunicipalController.text != ''
                            ? vtoMunicipalController.text
                            : null,
                    'expiration_date_dinatran_authorization':
                        vtoDinatranController.text != ''
                            ? vtoDinatranController.text
                            : null,
                    'expiration_date_senacsa_authorization':
                        vtoSenacsaController.text != ''
                            ? vtoSenacsaController.text
                            : null,
                    'expiration_date_insurance': vtoSeguroController.text != ''
                        ? vtoSeguroController.text
                        : null,
                    'vehicleId': vehicleId,
                  },
                  imagenes,
                  context: context,
                  update: hasVehicleData,
                  vehicleId: vehicleId,
                  greenCard: greenCard,
                  greenCardBack: greenCardBack,
                  municipal: municipal,
                  municipalBack: municipalBack,
                  senacsa: senacsa,
                  senacsaBack: senacsaBack,
                  dinatran: dinatran,
                  dinatranBack: dinatranBack,
                  insurance: seguro,
                );
              },
              icon: const Icon(Icons.upload))
        ],
      )
    ]);
  }
}

class ImageInput extends StatefulWidget {
  ImageInput(this.title, this.fileVariable, this.width, {Key? key})
      : super(key: key);
  String title;
  var fileVariable;
  double width;
  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile? img;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        img = await _picker.pickImage(source: ImageSource.gallery);
        if (img != null) {
          setState(() {
            widget.fileVariable(img!);
          });
        }
      },
      child: Column(
        children: [
          Text(widget.title),
          Container(
            width: widget.width,
            height: 200,
            color: img != null ? Colors.transparent : Colors.grey[200],
            child: img != null
                ? Image.file(
                    File(img!.path),
                  )
                : null,
          ),
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
        height: 200,
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
                      (index) => Image.file(
                        File(imagenes[index].path),
                      ),
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
            : null,
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

class MarcaSelect extends StatefulWidget {
  MarcaSelect({Key? key}) : super(key: key);

  @override
  State<MarcaSelect> createState() => _MarcaSelectState();
}

class _MarcaSelectState extends State<MarcaSelect> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = marcaController.text != ''
        ? marcaController.text
        : brands[0]['id'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Marca *'),
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
              marcaController.text = newValue;
            });
            // print(newValue);
          },
          items: brandsSelectList,
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
  const NextPageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => pageController.nextPage(
            duration: const Duration(milliseconds: 100), curve: Curves.ease),
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
