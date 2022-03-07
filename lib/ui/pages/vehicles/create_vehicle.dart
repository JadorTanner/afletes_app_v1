// ignore_for_file: avoid_init_to_null, must_be_immutable

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/google_map.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
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

late XFile? greenCard = null;
late XFile? greenCardBack = null;
late XFile? municipal = null;
late XFile? municipalBack = null;
late XFile? dinatran = null;
late XFile? dinatranBack = null;
late XFile? senacsa = null;
late XFile? senacsaBack = null;
late XFile? seguro = null;

late GlobalKey<_ImagesPickerState> imagePickerKey;

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
  try {
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
  } catch (e) {
    return false;
  }
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

  setValues(args) async {
    if (args != null) {
      hasVehicleData = true;
      vehicleId = args['id'];
      chapaController.text = args['chapa'];
      pesoController.text = args['peso'].toString();
      modeloController.text = args['model'] ?? '';
      marcaController.text = args['marca'].toString();
      fabricacionController.text = args['fabricacion'].toString();
      unidadMedidaController.text = args['unidadMedida'].toString();
      vtoMunicipalController.text = args['vtoMunicipal'];
      vtoDinatranController.text = args['vtoDinatran'];
      vtoSenacsaController.text = args['vtoSenacsa'];
      vtoSeguroController.text = args['vtoSeguro'];
      imagenes.clear();
      if (args['imgs'].isNotEmpty) {
        List.generate(args['imgs'].length, (index) async {
          Response image =
              await get(Uri.parse(vehicleImgUrl + args['imgs'][index]['path']));
          imagenes.add(XFile.fromData(image.bodyBytes,
              mimeType: args['imgs'][index]['path'].split('.')[1]));
          imagePickerKey.currentState != null
              ? imagePickerKey.currentState!.setState(() {})
              : null;
        });
      }
    } else {
      hasVehicleData = false;
      vehicleId = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    arguments = ModalRoute.of(context)!.settings.arguments;
    setValues(arguments);
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
              const Documentos2(),
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
        padding: const EdgeInsets.only(
          top: 60,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        children: [
          const ImagesPicker(),
          const Text('Imágenes del vehículo'),
          const SizedBox(
            height: 20,
          ),
          //chapa
          VehicleFormField(chapaController, 'Dominio o chapa *'),
          const SizedBox(
            height: 20,
          ),

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
                child: VehicleFormField(
                  modeloController,
                  'Modelo *',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              MeasurementUnit(),
              const SizedBox(
                width: 40,
              ),
              //Peso
              Flexible(
                child: VehicleFormField(
                  pesoController,
                  'Peso *',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),

          VehicleFormField(
            fabricacionController,
            'Año de producción *',
            type: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(
            height: 40,
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
    return ListView(
        padding: const EdgeInsets.only(
          top: 60,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        children: [
          Row(
            children: [
              ImageInput('Cédula verde (Frente)\n', greenCard, 170),
              const SizedBox(
                width: 20,
              ),
              ImageInput('Cédula verde (Atras)\n', greenCardBack, 170),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ImageInput('Habilitación Munic.\n', municipal, 170),
              const SizedBox(
                width: 20,
              ),
              ImageInput('Habilitación Munic.\n(Atras)', municipalBack, 170),
            ],
          ),
          DatePicker(
              vtoMunicipalController, 'Fecha de vto. Habilitación Municipal'),
          const SizedBox(
            height: 40,
          ),
          const ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              PrevPageButton(),
              NextPageButton(),
            ],
          )
        ]);
  }
}

class Documentos2 extends StatelessWidget {
  const Documentos2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.only(
          bottom: 20,
          top: 60,
          left: 20,
          right: 20,
        ),
        children: [
          Row(
            children: [
              ImageInput('Habilitación DINATRAN\n', dinatran, 170),
              const SizedBox(
                width: 20,
              ),
              ImageInput('Habilitación DINATRAN\n(Atras)', dinatranBack, 170),
            ],
          ),
          DatePicker(
              vtoDinatranController, 'Fecha de vto. Habilitación DINATRAN'),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ImageInput('Habilitación SENACSA\n', senacsa, 170),
              const SizedBox(
                width: 20,
              ),
              ImageInput('Habilitación SENACSA\n(Atras)', senacsaBack, 170),
            ],
          ),
          DatePicker(
              vtoSenacsaController, 'Fecha de vto. Habilitación SENACSA'),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ImageInput('Seguro\n', seguro, 170),
            ],
          ),
          DatePicker(vtoSeguroController, 'Fecha de vto. Seguro'),
          ButtonBar(
            alignment: MainAxisAlignment.center,
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
                        'expiration_date_insurance':
                            vtoSeguroController.text != ''
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
  XFile? fileVariable;
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
            widget.fileVariable = img;
          });
        }
      },
      child: Column(
        children: [
          Text(widget.title),
          Container(
            width: widget.width,
            margin: const EdgeInsets.only(bottom: 20),
            height: 200,
            color: img != null ? Colors.transparent : Colors.grey[200],
            child: img != null
                ? Image.file(
                    File(img!.path),
                  )
                : (widget.fileVariable != null
                    ? Image.file(
                        File(widget.fileVariable!.path),
                      )
                    : null),
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
  void initState() {
    super.initState();
    imagePickerKey = GlobalKey<_ImagesPickerState>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: imagePickerKey,
      onTap: () async {
        List<XFile>? imgs = await _picker.pickMultiImage();
        imagenes = imgs ?? [];
        if (imagenes.isNotEmpty) {
          if (mounted) {
            setState(() {
              // imagePageController.jumpToPage(0);
            });
          }
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
              ),
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
    return VehicleFormField(
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
    return VehicleFormField(
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

class VehicleFormField extends StatelessWidget {
  VehicleFormField(this.controller, this.label,
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
      textInputAction: action,
      decoration: InputDecoration(
        prefixIcon: icon,
        label: Text(label),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
      ),
    );
  }
}
