// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/ui/components/images_picker.dart';
import 'package:afletes_app_v1/ui/pages/register_vehicle.dart';
import 'package:afletes_app_v1/ui/pages/validate_code.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            child: const Text('Generador de carga'),
          ),
          TextButton(
            onPressed: () =>
                {userType.text = 'carrier', Navigator.pop(context)},
            child: const Text('Transportista'),
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
    return Scaffold(
      body: FutureBuilder(
        future: getData(context),
        builder: (context, AsyncSnapshot snapshot) =>
            (snapshot.connectionState == ConnectionState.done
                ? PageView(
                    controller: pageController,
                    children: [
                      PrimeraParte(pageController: pageController),
                      SegundaParte(pageController: pageController),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )),
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

class PrimeraParte extends StatelessWidget {
  const PrimeraParte({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;

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
                RegisterFormField(
                  'Cédula o RUC *',
                  Icons.article,
                  documentNumber,
                  hint: '9888777',
                ),
                const SizedBox(width: 100, height: separacion),
                RegisterFormField(
                  'Razón social',
                  Icons.person,
                  legalName,
                  hint: 'Empresa s.a.',
                ),
                const SizedBox(width: 100, height: separacion),
                RegisterFormField(
                  'Nombre',
                  Icons.person,
                  firstName,
                  hint: 'José',
                ),
                const SizedBox(width: 100, height: separacion),
                RegisterFormField(
                  'Apellido',
                  Icons.person,
                  lastName,
                  hint: 'Gonzalez',
                ),
                const SizedBox(width: 100, height: separacion),
                Row(
                  children: [
                    Flexible(
                        child: RegisterFormField(
                      'Celular',
                      Icons.phone_android,
                      cellphone,
                      hint: '0981222333',
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: RegisterFormField(
                        'Teléfono fijo:',
                        Icons.phone,
                        phone,
                        hint: '021444666',
                        action: TextInputAction.done,
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 100, height: separacion),
                const UbicacionPicker(),
                const SizedBox(width: 100, height: separacion),
                RegisterFormField(
                  'Calle Principal *',
                  Icons.home,
                  street1,
                  hint: 'Avda Mcal López',
                ),
                const SizedBox(width: 100, height: separacion),
                Row(
                  children: [
                    Flexible(
                      child: RegisterFormField(
                        'Calle Secundaria',
                        Icons.home,
                        street2,
                        hint: 'esq. #',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: RegisterFormField(
                        'Nro.',
                        Icons.home,
                        houseNumber,
                        hint: '1234',
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 100, height: separacion),
                RegisterFormField(
                  'Email',
                  Icons.alternate_email,
                  email,
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
          children: const [
            Flexible(
              flex: 1,
              child: SizedBox.shrink(),
            ),
            Flexible(
              flex: 1,
              child: NextPageButton(),
            ),
          ],
        ),
      ],
    );
  }
}

class SegundaParte extends StatefulWidget {
  SegundaParte({required this.pageController, Key? key}) : super(key: key);
  PageController pageController;

  @override
  State<SegundaParte> createState() => _SegundaParteState();
}

class _SegundaParteState extends State<SegundaParte> {
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
              const Spacer(),
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
              const Spacer()
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Flexible(
                flex: 1,
                child: PrevPageButton(),
              ),
              Flexible(
                flex: 1,
                child: RegisterButton(),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
      value = newCities[0]['id'].toString();
    });
    return DropdownButton(
        value: value,
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

class TransportistForm extends StatefulWidget {
  const TransportistForm({Key? key}) : super(key: key);

  @override
  State<TransportistForm> createState() => _TransportistFormState();
}

class _TransportistFormState extends State<TransportistForm> {
  @override
  Widget build(BuildContext context) {
    return const Text('formulario transportista');
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
        floatingLabelStyle: TextStyle(color: kBlack),
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        prefixIcon: GestureDetector(
          onTap: () => setState(() {
            locked = !locked;
          }),
          child: Icon(
            locked ? Icons.lock : Icons.lock_open,
            color: kInputBorder,
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

class RegisterFormField extends StatelessWidget {
  RegisterFormField(this.label, this.icon, this.controller,
      {this.hint = '', this.action = TextInputAction.next, Key? key})
      : super(key: key);

  String label = '';
  String hint = '';
  IconData icon;
  TextInputAction action;
  TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: action,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        labelText: label,
        floatingLabelStyle: TextStyle(color: kBlack),
        hintText: hint,
        hintStyle: TextStyle(color: kInputBorder),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kInputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        prefixIcon: Icon(
          icon,
          color: kInputBorder,
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
    return !isLoading
        ? TextButton(
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
                    try {
                      Api api = Api();

                      var fullUrl = apiUrl + 'register';

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

                      request.files.add(await MultipartFile.fromPath(
                          'identity_card_attachment', cedulaFrente));
                      request.files.add(await MultipartFile.fromPath(
                          'identity_card_back_attachment', cedulaAtras));
                      StreamedResponse response = await request.send();
                      String stringResponse =
                          await response.stream.bytesToString();

                      if (response.statusCode == 200) {
                        setState(() => {
                              isLoading = !isLoading,
                            });
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Map responseBody = jsonDecode(stringResponse);
                        if (responseBody['success']) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(responseBody['message']),
                            ),
                          );
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();

                          //TOKEN PARA MENSAJES PUSH
                          String? token =
                              await FirebaseMessaging.instance.getToken();
                          if (token != null) {
                            await Api().postData('user/set-device-token', {
                              'id': responseBody['data']['user']['id'],
                              'device_token': token
                            });
                          }

                          sharedPreferences.setString(
                              'user', jsonEncode(responseBody['data']['user']));
                          sharedPreferences.setString(
                              'token', responseBody['data']['token']);

                          if (responseBody['data']['user']['is_carrier']) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateVehicleAfterReg()));
                          } else {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ValidateCode()));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(responseBody['message']),
                            ),
                          );
                        }
                      } else {
                        setState(() => {
                              isLoading = !isLoading,
                            });
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 1),
                          content: Text('Compruebe su conexión a internet')));

                      setState(() => {
                            isLoading = !isLoading,
                          });
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.upload, color: Colors.white),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

class NextPageButton extends StatelessWidget {
  const NextPageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => pageController.nextPage(
          duration: const Duration(milliseconds: 100), curve: Curves.ease),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Siguiente',
            style: TextStyle(color: Colors.white),
          ),
          Icon(
            Icons.navigate_next,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class PrevPageButton extends StatelessWidget {
  const PrevPageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => pageController.previousPage(
          duration: const Duration(milliseconds: 100), curve: Curves.ease),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 20)),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF101010)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.navigate_before, color: Colors.white),
          Text(
            'Atrás',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
