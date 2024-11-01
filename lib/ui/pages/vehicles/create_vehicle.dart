// ignore_for_file: avoid_init_to_null, must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/date_picker.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/components/images_picker.dart';
import 'package:afletes_app_v1/ui/components/nextprev_buttons.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
      Api api = Api();
      Response response =
          await api.getData('vehicles/vehicle-images/' + args['id'].toString());

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
      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'].isNotEmpty) {
        imagenesNetwork = jsonResponse['data'];
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
      setState(() {});
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
      setState(() {});
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

resetData() {
  chapaController.text = '';
  marcaController.text = '';
  fabricacionController.text = '';
  pesoController.text = '';
  unidadMedidaController.text = '';
  modeloController.text = '';

  vtoMunicipalController.text = '';
  vtoDinatranController.text = '';
  vtoSenacsaController.text = '';

  vtoSeguroController.text = '';
  vehicleId = 0;
  imagenes.clear();
}

class RegisterVehicleForm extends StatefulWidget {
  const RegisterVehicleForm({Key? key}) : super(key: key);

  @override
  State<RegisterVehicleForm> createState() => _RegisterVehicleFormState();
}

class _RegisterVehicleFormState extends State<RegisterVehicleForm> {
  late Future getB;

  @override
  void initState() {
    super.initState();
    getB = getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        resetData();
        return true;
      },
      child: FutureBuilder(
        future: getB,
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
      ),
    );
  }
}

class DatosGenerales extends StatefulWidget {
  const DatosGenerales({Key? key}) : super(key: key);

  @override
  State<DatosGenerales> createState() => _DatosGeneralesState();
}

class _DatosGeneralesState extends State<DatosGenerales>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<FormState> datosGeneralesKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: datosGeneralesKey,
      child: FocusScope(
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
                  const Text('Imágenes del vehículo *'),
                  const SizedBox(
                    height: 20,
                  ),
                  //chapa
                  CustomFormField(
                    chapaController,
                    'Dominio o chapa *',
                    validator: (String? txt) {
                      if (chapaController.text == '') {
                        return 'Ingrese la chapa de su vehiculo';
                      }
                      return null;
                    },
                  ),
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
                          validator: (String? txt) {
                            if (modeloController.text == '') {
                              return 'Ingrese el modelo de su vehiculo';
                            }
                            return null;
                          },
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
                          'Peso máx. *',
                          type: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (String? txt) {
                            if (pesoController.text == '') {
                              return 'Ingrese el peso máximo.';
                            }
                            return null;
                          },
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
                    validator: (String? txt) {
                      if (fabricacionController.text == '') {
                        return 'Ingrese el año de fabricación';
                      }
                      return null;
                    },
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
                      child: NextPageButton(
                        pageController,
                        validator: () {
                          if (datosGeneralesKey.currentState != null) {
                            if (datosGeneralesKey.currentState!.validate()) {
                              return true;
                            }
                          }
                          return (chapaController.text != '' &&
                              modeloController.text != '' &&
                              chapaController.text != '' &&
                              pesoController.text != '' &&
                              fabricacionController.text != '' &&
                              unidadMedidaController.text != '' &&
                              (imagenes.isNotEmpty ||
                                  imagenesNetwork.isNotEmpty));
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class Documentos extends StatefulWidget {
  const Documentos({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DocumentosState();
}

class _DocumentosState extends State<Documentos>
    with AutomaticKeepAliveClientMixin {
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

  @override
  bool get wantKeepAlive => true;
}

class Documentos2 extends StatefulWidget {
  const Documentos2({Key? key}) : super(key: key);

  @override
  State<Documentos2> createState() => _Documentos2State();
}

class _Documentos2State extends State<Documentos2>
    with AutomaticKeepAliveClientMixin {
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
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LoadingBackButtons(),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LoadingBackButtons extends StatefulWidget {
  const LoadingBackButtons({Key? key}) : super(key: key);

  @override
  State<LoadingBackButtons> createState() => _LoadingBackButtonsState();
}

class _LoadingBackButtonsState extends State<LoadingBackButtons> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: PrevPageButton(pageController, active: !isLoading),
        ),
        Flexible(
          child: SendButton(
              isLoading, () => setState(() => isLoading = !isLoading)),
        ),
      ],
    );
  }
}

class SendButton extends StatefulWidget {
  SendButton(this.isLoading, this.changeState, {Key? key}) : super(key: key);
  bool isLoading;
  var changeState;
  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
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
      onPressed: widget.isLoading
          ? null
          : () async {
              // setState(() {
              //   widget.isLoading = !widget.isLoading;
              // });
              widget.changeState();
              Vehicle vehicle = Vehicle();
              if (await vehicle.createVehicle(
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
              )) {
                resetData();

                try {
                  if (PusherApi().pusher.connectionState != '') {
                    if (PusherApi().pusher.connectionState == 'CONNECTED') {
                      PusherApi().disconnect();
                    } else if (PusherApi().pusher.connectionState ==
                        'DISCONNECTED') {
                      PusherApi().init(
                          context,
                          context.read<NotificationsApi>(),
                          context.read<TransportistsLocProvider>(),
                          context.read<ChatProvider>());
                    }
                  }
                } catch (e) {}
              }
              widget.changeState();
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.isLoading
            ? [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              ]
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
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView(
              controller: imagePageController,
              onPageChanged: (value) => setState(() {
                currentImage = value;
              }),
              children: [
                ...List.generate(imagenesNetwork.length, (index) {
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
                                  child: Image.network(Constants.vehicleImgUrl +
                                      imagenesNetwork[index]['path']),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.4,
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
                          height: MediaQuery.of(context).size.height * 0.4,
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
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text(
                              'Desde dónde quieres cargar la imágen?'),
                          actions: [
                            TextButton.icon(
                              onPressed: () async {
                                try {
                                  XFile? img = await _picker.pickImage(
                                      source: ImageSource.camera);
                                  if (img != null) {
                                    imagenes.add(img);
                                    if (imagenes.isNotEmpty) {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        // imagePageController.jumpToPage(0);
                                      });
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Ha ocurrido un error, intentelo de nuevo mas tarde.'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.camera_alt,
                                  color: Color(0xFFF58633)),
                              label: const Text('Cámara',
                                  style: TextStyle(color: Color(0xFFF58633))),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                try {
                                  List<XFile>? imgs =
                                      await _picker.pickMultiImage();
                                  if (imgs != null) {
                                    imagenes.addAll((imgs));
                                    if (imagenes.isNotEmpty) {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        // imagePageController.jumpToPage(0);
                                      });
                                    }
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Ha ocurrido un error, intentelo de nuevo mas tarde.'),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.image_search_sharp,
                                  color: Color(0xFFF58633)),
                              label: const Text('Galería',
                                  style: TextStyle(color: Color(0xFFF58633))),
                            ),
                          ],
                        );
                      },
                    );
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
        ));
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
  void initState() {
    super.initState();

    unidadMedidaController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unidad de medida'),
        FutureBuilder<List>(future: Future<List>(() async {
          try {
            Response response = await Api().getData('get-measurement-units');
            if (response.statusCode == 200) {
              Map jsonResponse = jsonDecode(response.body);
              if (jsonResponse['success']) {
                return jsonResponse['data'];
              }
            } else {
              return [
                {'id': value, 'name': 'No hay resultados'}
              ];
            }
          } catch (e) {
            return [
              {'id': value, 'name': 'No hay resultados'}
            ];
          }
          return [
            {'id': value, 'name': 'No hay resultados'}
          ];
        }), builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DropdownButton(
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
              items: snapshot.data!
                  .map((e) => DropdownMenuItem(
                        child: Text(e['name']),
                        value: e['id'].toString(),
                      ))
                  .toList(),
            );
          } else {
            return const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            );
          }
        })
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
