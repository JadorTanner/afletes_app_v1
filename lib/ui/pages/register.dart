import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/splash_screen.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

const double separacion = 15;
List states = [];
List cities = [];

Future<List> getStates() async {
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
}

Future<List> getCities([String stateId = '']) async {
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
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
    getStates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: const BoxDecoration(
              color: Color(0xFFED8232),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              shape: BoxShape.rectangle,
            ),
            child: Hero(
              tag: 'splash-screen-loading',
              child: Lottie.asset('assets/lottie/camion.json'),
            ),
          ),
          // Hero(
          //   tag: 'splash-screen-loading',
          //   child: Lottie.asset('assets/lottie/camion.json'),
          // ),
          RegisterPagePage()
        ],
      ),
    );
    ;
  }
}

class RegisterPagePage extends StatefulWidget {
  RegisterPagePage({Key? key}) : super(key: key);

  @override
  State<RegisterPagePage> createState() => S_RegisterPageState();
}

class S_RegisterPageState extends State<RegisterPagePage> {
  bool passwordVisibility = false;
  PageController pageController = PageController();
  // static const double separacion = 15;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      controller: pageController,
      children: [
        PrimeraParte(pageController: pageController),
        SegundaParte(pageController: pageController),
        ListView(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    width: 100,
                    height: 40,
                  ),
                  TextFormField(
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Ejemplo@gmail.com',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFED8232),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFED8232),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      prefixIcon: const Icon(
                        Icons.alternate_email,
                        color: Color(0xFFED8232),
                      ),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Ingresa un email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    width: 100,
                    height: 40,
                  ),
                  TextFormField(
                    obscureText: !passwordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFED8232),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFFED8232),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFFED8232),
                      ),
                      suffixIcon: InkWell(
                        onTap: () => setState(
                          () => passwordVisibility = !passwordVisibility,
                        ),
                        child: Icon(
                          passwordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFFED8232),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 100,
                    height: 40,
                  ),
                  RegisterButton(
                    Future<bool>.delayed(
                        const Duration(seconds: 3), () => true),
                    text: 'Registrarse',
                  ),
                  const SizedBox(width: 100, height: separacion),
                  const Text('He olvidado mi contraseña',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const Spacer(),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
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
                ])),
            const Spacer(),
          ],
        ),
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 100,
              height: 10,
            ),
            RegisterFormField(
              'Cédula o RUC *',
              hint: '9888777',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Razón social',
              hint: 'José',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Nombre',
              hint: 'José',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Apellido',
              hint: 'Gonzalez',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Celular',
              hint: '0981222333',
            ),
            const SizedBox(width: 100, height: separacion),
            ButtonBar(
              children: [
                IconButton(
                    onPressed: () => pageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.ease),
                    icon: const Icon(Icons.navigate_next))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SegundaParte extends StatelessWidget {
  const SegundaParte({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  final PageController pageController;
  // static const double separacion = 15;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 100,
              height: 10,
            ),
            RegisterFormField(
              'Teléfono fijo:',
              hint: '021444666',
            ),
            const SizedBox(width: 100, height: separacion),
            //TODO: UBICACION
            UbicacionPicker(),
            // RegisterFormField(
            //   'Ubicación',
            //   hint: 'José',
            // ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Nombre',
              hint: 'José',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Calle Principal *',
              hint: 'Avda Mcal López',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Calle Secundaria',
              hint: 'esq. #',
            ),
            const SizedBox(width: 100, height: separacion),
            ButtonBar(
              children: [
                IconButton(
                    onPressed: () => pageController.nextPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.ease),
                    icon: const Icon(Icons.navigate_next))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class UbicacionPicker extends StatefulWidget {
  UbicacionPicker({Key? key}) : super(key: key);

  @override
  State<UbicacionPicker> createState() => _UbicacionPickerState();
}

class _UbicacionPickerState extends State<UbicacionPicker> {
  String stateId = '';
  changeState(newVal) {
    setState(() {
      stateId = newVal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatePicker(changeState),
        FutureBuilder(
          future: getCities(stateId),
          builder: (context, snapshot) {
            return CitiesPicker(stateId);
          },
        )
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
    return FutureBuilder(
      future: getStates(),
      builder: (context, snapshot) {
        return DropdownButton(
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
              });
              widget.callBack(newValue!);
            },
            items: snapshot.connectionState == ConnectionState.done
                ? List.generate(
                    states.length,
                    (index) => DropdownMenuItem(
                          value: states[index]['id'].toString(),
                          child: Text(states[index]['name']),
                        ))
                : [
                    DropdownMenuItem(
                      value: value,
                      child: Text('Dpto'),
                    )
                  ]);
      },
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
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
          });
        },
        items: List.generate(
          cities.length,
          (index) => DropdownMenuItem(
            value: cities[index]['id'].toString(),
            child: Text(cities[index]['name']),
          ),
        ));
  }
}

class TransportistForm extends StatefulWidget {
  TransportistForm({Key? key}) : super(key: key);

  @override
  State<TransportistForm> createState() => _TransportistFormState();
}

class _TransportistFormState extends State<TransportistForm> {
  @override
  Widget build(BuildContext context) {
    return Text('formulario transportista');
  }
}
