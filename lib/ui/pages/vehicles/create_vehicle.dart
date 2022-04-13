// ignore_for_file: avoid_init_to_null, must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/components/images_picker.dart';
import 'package:afletes_app_v1/ui/components/nextprev_buttons.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker _picker = ImagePicker();
List<XFile> imagenes = [];
List imagenesNetwork = [];

bool hasVehicleData = false;
int vehicleId = 0;

List brands = [];
List<DropdownMenuItem<String>> brandsSelectList = [];
PageController pageController = PageController();

late String greenCard = '';
late String greenCardBack = '';
late String municipal = '';
late String municipalBack = '';
late String dinatran = '';
late String dinatranBack = '';
late String senacsa = '';
late String senacsaBack = '';
late String seguro = '';

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
  const CreateVehicle({Key? key}) : super(key: key);

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
      imagenes.clear();
      imagenesNetwork.clear();
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
      if (args['imgs'].isNotEmpty) {
        print(args['imgs']);
        imagenesNetwork = args['imgs'];
      }

      dinatran = args['dinatranFront'] != ''
          ? Constants.baseUrl +
              'images/vehicle_dinatran_authorization/' +
              args['dinatranFront']
          : '';
      dinatranBack = args['dinatranBack'] != ''
          ? Constants.baseUrl +
              'images/vehicle_dinatran_authorization/' +
              args['dinatranBack']
          : '';
      greenCard = args['greencardFront'] != ''
          ? Constants.baseUrl +
              'images/vehicle_green_card/' +
              args['greencardFront']
          : '';
      greenCardBack = args['greencardBack'] != ''
          ? Constants.baseUrl +
              'images/vehicle_green_card/' +
              args['greencardBack']
          : '';
      senacsa = args['senacsaFront'] != ''
          ? Constants.baseUrl +
              'images/vehicle_senacsa_authorization/' +
              args['senacsaFront']
          : '';
      senacsaBack = args['senacsaBack'] != ''
          ? Constants.baseUrl +
              'images/vehicle_senacsa_authorization/' +
              args['senacsaBack']
          : '';
      municipal = args['municipalFront'] != ''
          ? Constants.baseUrl +
              'images/vehicle_authorization/' +
              args['municipalFront']
          : '';
      municipalBack = args['municipalBack'] != ''
          ? Constants.baseUrl +
              'images/vehicle_authorization/' +
              args['municipalBack']
          : '';
      seguro = args['insuranceImg'] != ''
          ? Constants.baseUrl +
              'images/vehicle_insurance/' +
              args['insuranceImg']
          : '';
    } else {
      imagenes.clear();
      imagenesNetwork.clear();
      chapaController.text = '';
      pesoController.text = '';
      modeloController.text = '';
      marcaController.text = '';
      fabricacionController.text = '';
      unidadMedidaController.text = '';
      vtoMunicipalController.text = '';
      vtoDinatranController.text = '';
      vtoSenacsaController.text = '';
      vtoSeguroController.text = '';
      hasVehicleData = false;
      vehicleId = 0;

      greenCard = '';
      greenCardBack = '';
      municipal = '';
      municipalBack = '';
      dinatran = '';
      dinatranBack = '';
      senacsa = '';
      senacsaBack = '';
      seguro = '';
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
    return BaseApp(
      const RegisterVehicleForm(),
      resizeToAvoidBottomInset: true,
    );
  }
}

class RegisterVehicleForm extends StatelessWidget {
  const RegisterVehicleForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getBrands(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              DatosGenerales(),
              Documentos(),
              Documentos2(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
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
                right: 20,
                bottom: 70,
              ),
              children: [
                const ImagesPicker(),
                const Text('Imágenes del vehículo'),
                const SizedBox(
                  height: 20,
                ),
                //chapa
                CustomFormField(chapaController, 'Dominio o chapa *'),
                const SizedBox(
                  height: 20,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Marca
                    const Flexible(
                      child: MarcaSelect(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    //Modelo
                    Flexible(
                      child: CustomFormField(
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
                    const Flexible(
                      child: MeasurementUnit(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    //Peso
                    Flexible(
                      child: CustomFormField(
                        pesoController,
                        'Peso *',
                        type: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                CustomFormField(
                  fabricacionController,
                  'Año de producción *',
                  type: const TextInputType.numberWithOptions(decimal: true),
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
                    child: NextPageButton(pageController),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Documentos extends StatelessWidget {
  const Documentos({Key? key}) : super(key: key);

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
              top: 20,
              left: 20,
              right: 20,
              bottom: 70,
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SingleImagePicker(
                      'Cédula verde (Frente)\n',
                      greenCard,
                      double.infinity,
                      onChange: (newVal) => greenCard = newVal,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: SingleImagePicker(
                      'Cédula verde (Atras)\n',
                      greenCardBack,
                      double.infinity,
                      onChange: (newVal) => greenCardBack = newVal,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SingleImagePicker(
                      'Habilitación Munic.\n',
                      municipal,
                      double.infinity,
                      onChange: (newVal) => municipal = newVal,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: SingleImagePicker(
                      'Habilitación Munic.\n(Atras)',
                      municipalBack,
                      double.infinity,
                      onChange: (newVal) => municipalBack = newVal,
                    ),
                  ),
                ],
              ),
              DatePicker(vtoMunicipalController,
                  'Fecha de vto. Habilitación Municipal'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SingleImagePicker(
                      'Seguro\n',
                      seguro,
                      double.infinity,
                      onChange: (newVal) => seguro = newVal,
                    ),
                  ),
                  const Flexible(
                      child: SizedBox(
                    width: double.infinity,
                  )),
                ],
              ),
              DatePicker(vtoSeguroController, 'Fecha de vto. Seguro'),
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
                Flexible(
                  child: NextPageButton(pageController),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Documentos2 extends StatelessWidget {
  const Documentos2({Key? key}) : super(key: key);

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
                top: 20,
                left: 20,
                right: 20,
                bottom: 70,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SingleImagePicker(
                        'Habilitación DINATRAN\n',
                        dinatran,
                        double.infinity,
                        onChange: (newVal) => dinatran = newVal,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: SingleImagePicker(
                        'Habilitación DINATRAN\n(Atras)',
                        dinatranBack,
                        double.infinity,
                        onChange: (newVal) => dinatranBack = newVal,
                      ),
                    ),
                  ],
                ),
                DatePicker(vtoDinatranController,
                    'Fecha de vto. Habilitación DINATRAN'),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SingleImagePicker(
                        'Habilitación SENACSA\n',
                        senacsa,
                        double.infinity,
                        onChange: (newVal) => senacsa = newVal,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: SingleImagePicker(
                        'Habilitación SENACSA\n(Atras)',
                        senacsaBack,
                        double.infinity,
                        onChange: (newVal) => senacsaBack = newVal,
                      ),
                    ),
                  ],
                ),
                DatePicker(
                    vtoSenacsaController, 'Fecha de vto. Habilitación SENACSA'),
              ]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Flexible(
                  child: PrevPageButton(pageController),
                ),
                const Flexible(
                  child: SendButton(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SendButton extends StatefulWidget {
  const SendButton({Key? key}) : super(key: key);

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
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
          ? null
          : () async {
              setState(() {
                isLoading = !isLoading;
              });
              Vehicle vehicle = Vehicle();
              await vehicle.createVehicle(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isLoading
            ? [const CircularProgressIndicator()]
            : const [
                Text(
                  'Enviar',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.upload, color: Colors.white)
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
                      ...List.generate(imagenesNetwork.length, (index) {
                        print(imagenesNetwork[index]['path']);
                        return SizedBox(
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
                                        child: Image.network(
                                            Constants.vehicleImgUrl +
                                                imagenesNetwork[index]['path']),
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
                                    Constants.vehicleImgUrl +
                                        imagenesNetwork[index]['path'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                child: TextButton(
                                  onPressed: () async {
                                    Api api = Api();

                                    Response response = await api.postData(
                                      'vehicles/vehicle-image-delete',
                                      {
                                        'id': imagenesNetwork[index]['id'],
                                      },
                                    );

                                    print(response.body);
                                    if (response.statusCode == 200) {
                                      imagenesNetwork.removeAt(index);
                                      setState(() {});
                                    }
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.close,
                                      color: Constants.kBlack,
                                    ),
                                  ),
                                ),
                                top: 20,
                                right: 20,
                              )
                            ],
                          ),
                        );
                      }),
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
                                    color: Constants.kBlack,
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

/* class _ImagesPickerState extends State<ImagesPicker> {
  int currentImage = 0;
  PageController imagePageController = PageController();

  @override
  void initState() {
    super.initState();
    imagePickerKey = GlobalKey<_ImagesPickerState>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      color: (imagenes.isNotEmpty || imagenesNetwork.isNotEmpty)
          ? Colors.transparent
          : Colors.grey[200],
      child: (imagenesNetwork.isNotEmpty || imagenes.isNotEmpty)
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
                      (index) => GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 4,
                                clipBehavior: Clip.none,
                                child: Image.network(
                                  vehicleImgUrl + imagenesNetwork[index],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          vehicleImgUrl + imagenesNetwork[index],
                        ),
                      ),
                    ),
                    ...List.generate(
                      imagenes.length,
                      (index) => GestureDetector(
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
                        child: Image.file(
                          File(imagenes[index].path),
                        ),
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
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
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
              key: imagePickerKey,
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
 */
class MeasurementUnit extends StatefulWidget {
  const MeasurementUnit({Key? key}) : super(key: key);

  @override
  State<MeasurementUnit> createState() => _MeasurementUnitState();
}

class _MeasurementUnitState extends State<MeasurementUnit> {
  String value = '1';
  @override
  void initState() {
    super.initState();

    unidadMedidaController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unidad de medida *'),
        DropdownButton(
            value: value,
            icon: const Icon(Icons.arrow_circle_down_outlined),
            elevation: 16,
            isExpanded: true,
            style: Theme.of(context).textTheme.bodyText2,
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
              ),
            ])
      ],
    );
  }
}

class MarcaSelect extends StatefulWidget {
  const MarcaSelect({Key? key}) : super(key: key);

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
    marcaController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Marca *'),
        DropdownButton(
          value: value,
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
            setState(() {
              value = newValue!;
              marcaController.text = newValue;
            });
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
    return CustomFormField(
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
  State<LoadTimePicker> createState() => LoadTimePickerState();
}

class LoadTimePickerState extends State<LoadTimePicker> {
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
    return CustomFormField(
      widget.controller,
      widget.title,
      onFocus: () => _selectTime(context),
      showCursor: true,
      readOnly: true,
    );
  }
}
