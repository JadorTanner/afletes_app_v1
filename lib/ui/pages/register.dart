// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/transportists_location.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/ui/components/images_picker.dart';
import 'package:afletes_app_v1/ui/components/nextprev_buttons.dart';
import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:afletes_app_v1/utils/pusher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

const double separacion = 20;
List states = [];
List cities = [];

String cedulaFrente = '';
String cedulaAtras = '';
PageController pageController = PageController();

TextEditingController userType = TextEditingController();
TextEditingController firstName = TextEditingController();
TextEditingController lastName = TextEditingController();
TextEditingController legalName = TextEditingController();
TextEditingController documentNumber = TextEditingController();
TextEditingController cellphone = TextEditingController();
TextEditingController phone = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController street1 = TextEditingController();
TextEditingController street2 = TextEditingController();
TextEditingController houseNumber = TextEditingController();
TextEditingController cityId = TextEditingController();
TextEditingController lastLoginType = TextEditingController();
TextEditingController password = TextEditingController();
TextEditingController passwordConfirmation = TextEditingController();

Future getData(context) async {
  await getStates();
  await getCities();
  if (userType.text == '') {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cómo quieres registrarte?'),
        actions: [
          TextButton(
            onPressed: () =>
                {userType.text = 'load_generator', Navigator.pop(context)},
            child: Text('Generador de carga',
                style: TextStyle(color: Constants.primaryOrange)),
          ),
          TextButton(
            onPressed: () =>
                {userType.text = 'carrier', Navigator.pop(context)},
            child: Text('Transportista',
                style: TextStyle(color: Constants.primaryOrange)),
          ),
        ],
      ),
    );
  }

  return true;
}

Future<List> getStates() async {
  try {
    Api api = Api();

    Response response = await api.getData('get-states');
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      states = jsonResponse['data'];
      return states;
    } else {
      states = [];
    }
    return states;
  } catch (e) {
    return [];
  }
}

Future<List> getCities([String stateId = '']) async {
  try {
    Api api = Api();

    Response response = await api
        .getData('get-cities' + (stateId != '' ? '?state_id=' + stateId : ''));
    if (response.statusCode == 200) {
      Map jsonResponse = jsonDecode(response.body);
      cities = jsonResponse['data'];
      return cities;
    } else {
      cities = [];
    }
    return cities;
  } catch (e) {
    return [];
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        userType.text = '';
        firstName.text = '';
        lastName.text = '';
        legalName.text = '';
        documentNumber.text = '';
        cellphone.text = '';
        phone.text = '';
        email.text = '';
        street1.text = '';
        street2.text = '';
        houseNumber.text = '';
        cityId.text = '';
        lastLoginType.text = '';
        password.text = '';
        passwordConfirmation.text = '';

        return true;
      },
      child: Scaffold(
        body: FutureBuilder(
          future: getData(context),
          builder: (context, AsyncSnapshot snapshot) =>
              (snapshot.connectionState == ConnectionState.done
                  ? PageView(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        PrimeraParte(pageController: pageController),
                        SegundaParte(pageController: pageController),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    )),
        ),
      ),
    );
  }
}

class RegisterPagePage extends StatefulWidget {
  const RegisterPagePage({Key? key}) : super(key: key);

  @override
  State<RegisterPagePage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPagePage> {
  // static const double separacion = 15;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      controller: pageController,
      children: [
        PrimeraParte(pageController: pageController),
        SegundaParte(pageController: pageController),
        SegundaParte(pageController: pageController),
      ],
    ));
  }
}

class PrimeraParte extends StatefulWidget {
  PrimeraParte({required this.pageController, Key? key}) : super(key: key);
  PageController pageController;

  @override
  State<PrimeraParte> createState() => _PrimeraParteState();
}

class _PrimeraParteState extends State<PrimeraParte>
    with AutomaticKeepAliveClientMixin {
  // static const double separacion = 15;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('Registro', style: Theme.of(context).textTheme.headline5),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                CustomFormField(
                  documentNumber,
                  'Cédula o RUC *',
                  icon: Icons.article,
                  hint: '9888777',
                ),
                const SizedBox(width: 100, height: separacion),
                CustomFormField(
                  legalName,
                  'Razón social',
                  icon: Icons.person,
                  hint: 'Empresa s.a.',
                ),
                const SizedBox(width: 100, height: separacion),
                CustomFormField(
                  firstName,
                  'Nombre *',
                  icon: Icons.person,
                  hint: 'José',
                ),
                const SizedBox(width: 100, height: separacion),
                CustomFormField(
                  lastName,
                  'Apellido *',
                  icon: Icons.person,
                  hint: 'Gonzalez',
                ),
                const SizedBox(width: 100, height: separacion),
                Row(
                  children: [
                    Flexible(
                        child: CustomFormField(
                      cellphone,
                      'Celular *',
                      icon: Icons.phone_android,
                      hint: '0981222333',
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: CustomFormField(
                        phone,
                        'Teléfono fijo:',
                        icon: Icons.phone,
                        hint: '021444666',
                        action: TextInputAction.done,
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 100, height: separacion),
                const UbicacionPicker(),
                const SizedBox(width: 100, height: separacion),
                CustomFormField(
                  street1,
                  'Calle Principal *',
                  icon: Icons.home,
                  hint: 'Avda Mcal López',
                ),
                const SizedBox(width: 100, height: separacion),
                Row(
                  children: [
                    Flexible(
                      child: CustomFormField(
                        street2,
                        'Calle Secundaria',
                        icon: Icons.home,
                        hint: 'esq. #',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: CustomFormField(
                        houseNumber,
                        'Nro.',
                        icon: Icons.home,
                        hint: '1234',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 100, height: separacion),
                CustomFormField(
                  email,
                  'Email *',
                  icon: Icons.alternate_email,
                  hint: 'ejemplo@gmail.com',
                ),
                const SizedBox(width: 100, height: separacion),
                PassField('Contraseña', TextInputAction.next, password),
                const SizedBox(width: 100, height: separacion),
                PassField('Confirmar contraseña', TextInputAction.done,
                    passwordConfirmation),
              ]),
        ),
        const SizedBox(width: 100, height: separacion),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Flexible(
              flex: 1,
              child: SizedBox.shrink(),
            ),
            Flexible(
              flex: 1,
              child: NextPageButton(
                pageController,
                validator: () {
                  return (documentNumber.text != '' &&
                      firstName.text != '' &&
                      lastName.text != '' &&
                      cellphone.text != '' &&
                      cityId.text != '' &&
                      street1.text != '' &&
                      email.text != '');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SegundaParte extends StatefulWidget {
  SegundaParte({required this.pageController, Key? key}) : super(key: key);
  PageController pageController;

  @override
  State<SegundaParte> createState() => _SegundaParteState();
}

class _SegundaParteState extends State<SegundaParte>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Documentos', style: Theme.of(context).textTheme.headline5),
              const SizedBox(
                width: 100,
                height: 20,
              ),
              Row(
                children: [
                  Flexible(
                    child: SingleImagePicker(
                      'Cédula (frente)',
                      cedulaFrente,
                      double.infinity,
                      onChange: (path) => setState(() {
                        cedulaFrente = path;
                      }),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: SingleImagePicker(
                      'Cédula (atrás)',
                      cedulaAtras,
                      double.infinity,
                      onChange: (path) => setState(() {
                        cedulaAtras = path;
                      }),
                    ),
                  ),
                ],
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const WidgetSpan(child: Text('Ya tienes una cuenta? ')),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Ingresa aquí!',
                          style: TextStyle(
                              color: Color(0xFFED8232),
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFFF58633),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 1,
                    child: PrevPageButton(pageController),
                  ),
                  const Flexible(
                    flex: 1,
                    child: RegisterButton(),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UbicacionPicker extends StatefulWidget {
  const UbicacionPicker({Key? key}) : super(key: key);

  @override
  State<UbicacionPicker> createState() => _UbicacionPickerState();
}

class _UbicacionPickerState extends State<UbicacionPicker> {
  String stateId = '';

  @override
  void initState() {
    super.initState();
    stateId = states[0]['id'].toString();
    List firstCity = cities
        .where((element) => element['state_id'].toString() == stateId)
        .toList();
    cityId.text = firstCity[0]['id'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: StatePicker(
            (newVal) => setState(
              () {
                stateId = newVal;
                List firstCity = cities
                    .where(
                        (element) => element['state_id'].toString() == stateId)
                    .toList();
                cityId.text = firstCity[0]['id'].toString();
              },
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(child: CitiesPicker(stateId)),
      ],
    );
  }
}

//Selector de estado y ciudad
class StatePicker extends StatefulWidget {
  const StatePicker(this.callBack, {Key? key}) : super(key: key);
  final callBack;
  @override
  State<StatePicker> createState() => _StatePickerState();
}

class _StatePickerState extends State<StatePicker> {
  String value = '1';

  @override
  void initState() {
    super.initState();
    if (states.isNotEmpty) {
      value = states[0]['id'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      icon: const Icon(Icons.arrow_circle_down_outlined),
      elevation: 16,
      style: Theme.of(context).textTheme.bodyText2,
      isExpanded: true,
      underline: Container(
        height: 2,
        color: Theme.of(context).inputDecorationTheme.border!.borderSide.color,
      ),
      onChanged: (String? newValue) {
        setState(() {
          value = newValue!;
        });
        widget.callBack(newValue!);
      },
      items: List.generate(
        states.length,
        (index) => DropdownMenuItem(
          value: states[index]['id'].toString(),
          child: Text(states[index]['name']),
        ),
      ),
    );
  }
}

//Selector de estado y ciudad
class CitiesPicker extends StatefulWidget {
  CitiesPicker(this.stateId, {Key? key}) : super(key: key);
  String stateId;
  @override
  State<CitiesPicker> createState() => _CitiesPickerState();
}

class _CitiesPickerState extends State<CitiesPicker> {
  String value = '0';

  List newCities = cities;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      newCities = cities.where((city) {
        return city['state_id'].toString() == widget.stateId;
      }).toList();
      // value = newCities[0]['id'].toString();
    });
    return DropdownButton(
        value: cityId.text,
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
          });
          cityId.text = newValue!;
        },
        items: List.generate(
          newCities.length,
          (index) => DropdownMenuItem(
            value: newCities[index]['id'].toString(),
            child: Text(newCities[index]['name']),
          ),
        ));
  }
}

class PassField extends StatefulWidget {
  PassField(this.title, this.action, this.controller, {Key? key})
      : super(key: key);
  String title;
  TextInputAction action;
  TextEditingController controller;
  @override
  State<PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<PassField> {
  bool locked = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: locked,
      textInputAction: widget.action,
      decoration: InputDecoration(
        labelText: widget.title,
        floatingLabelStyle: TextStyle(color: Constants.kBlack),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Constants.kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Constants.kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: GestureDetector(
          onTap: () => setState(() {
            locked = !locked;
          }),
          child: Icon(
            locked ? Icons.lock : Icons.lock_open,
            color: Constants.kInputBorder,
          ),
        ),
      ),
      validator: (val) {
        if (val!.isEmpty) {
          return 'Ingresa un valor';
        }

        return null;
      },
    );
  }
}

class RegisterButton extends StatefulWidget {
  const RegisterButton({Key? key}) : super(key: key);
  @override
  State<RegisterButton> createState() => RegisterButtonState();
}

class RegisterButtonState extends State<RegisterButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 20)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFFF58633)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      onPressed: isLoading
          ? null
          : () async {
              setState(() => {
                    isLoading = !isLoading,
                  });
              // try {
              Api api = Api();

              var fullUrl = Constants.apiUrl + 'register';

              MultipartRequest request =
                  MultipartRequest('POST', Uri.parse(fullUrl));
              Map headers = api.setHeaders();
              headers.forEach((key, value) {
                request.headers[key] = value;
              });

              request.fields['user_type'] = userType.text;
              request.fields['first_name'] = firstName.text;
              request.fields['last_name'] = lastName.text;
              request.fields['legal_name'] = legalName.text;
              request.fields['document_number'] = documentNumber.text;
              request.fields['cellphone'] = cellphone.text;
              request.fields['phone'] = phone.text;
              request.fields['email'] = email.text;
              request.fields['street1'] = street1.text;
              request.fields['street2'] = street2.text;
              request.fields['house_number'] = houseNumber.text;
              request.fields['city_id'] = cityId.text;
              request.fields['password'] = password.text;
              request.fields['password_confirmation'] =
                  passwordConfirmation.text;
              if (cedulaFrente != '') {
                request.files.add(await MultipartFile.fromPath(
                    'identity_card_attachment', cedulaFrente));
              }
              if (cedulaAtras != '') {
                request.files.add(await MultipartFile.fromPath(
                    'identity_card_back_attachment', cedulaAtras));
              }
              StreamedResponse response = await request.send();
              String stringResponse = await response.stream.bytesToString();

              Map responseBody = jsonDecode(stringResponse);
              if (response.statusCode == 200) {
                setState(() => {
                      isLoading = !isLoading,
                    });
                ScaffoldMessenger.of(context).clearSnackBars();
                if (responseBody['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(responseBody['message']),
                    ),
                  );

                  context.read<User>().setUser(
                      User.userFromArray(responseBody['data']['user']));
                  //TOKEN PARA MENSAJES PUSH
                  try {
                    String? token = await FirebaseMessaging.instance.getToken();
                    if (token != null) {
                      Api().postData('user/set-device-token', {
                        'id': responseBody['data']['user']['id'],
                        'device_token': token
                      });
                    }
                  } catch (e) {}

                  await User().login(context, email.text, password.text);
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  if (pref.getString('user') != null) {
                    context.read<User>().setOnline(true);
                    Map user = jsonDecode(pref.getString('user')!);
                    user['online'] = true;
                    pref.setString('user', jsonEncode(user));
                    Api().postData(
                      'set-online',
                      {
                        'online': true.toString(),
                      },
                    );
                  }

                  if (responseBody['data']['user']['is_carrier']) {
                    PusherApi().init(
                      context,
                      context.read<NotificationsApi>(),
                      context.read<TransportistsLocProvider>(),
                      context.read<ChatProvider>(),
                    );
                    await FirebaseMessaging.instance
                        .subscribeToTopic("new-loads");

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const CreateVehicleAfterReg()));
                  } else {
                    PusherApi().init(
                      context,
                      context.read<NotificationsApi>(),
                      context.read<TransportistsLocProvider>(),
                      context.read<ChatProvider>(),
                      true,
                    );
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const ValidateCode()));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 5),
                      content: Text(responseBody['message']),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  content:
                      Text('Ha ocurrido un error. ' + responseBody['message']),
                ));

                setState(() => {
                      isLoading = !isLoading,
                    });
              }
              // } catch (e) {
              //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //       duration: Duration(seconds: 1),
              //       content: Text('Compruebe su conexión a internet')));

              //   setState(() => {
              //         isLoading = !isLoading,
              //       });
              // }
            },
      child: !isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.upload, color: Colors.white),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}
