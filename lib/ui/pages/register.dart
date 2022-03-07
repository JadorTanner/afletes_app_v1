// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/ui/pages/splash_screen.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';

const double separacion = 15;
List states = [];
List cities = [];

Future getData() async {
  await getStates();
  await getCities();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, AsyncSnapshot snapshot) =>
            (snapshot.connectionState == ConnectionState.done
                ? Column(
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
                      const RegisterPagePage()
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
              Icons.article,
              hint: '9888777',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Razón social',
              Icons.person,
              hint: 'José',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Nombre',
              Icons.person,
              hint: 'José',
            ),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Apellido',
              Icons.person,
              hint: 'Gonzalez',
            ),
            const SizedBox(width: 100, height: separacion),
            Row(
              children: [
                Flexible(
                    child: RegisterFormField(
                  'Celular',
                  Icons.phone_android,
                  hint: '0981222333',
                )),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: RegisterFormField(
                    'Teléfono fijo:',
                    Icons.phone,
                    hint: '021444666',
                    action: TextInputAction.done,
                  ),
                )
              ],
            ),
            const SizedBox(width: 100, height: separacion),
            ButtonBar(
              alignment: MainAxisAlignment.center,
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
            const SizedBox(width: 100, height: separacion),
            const UbicacionPicker(),
            const SizedBox(width: 100, height: separacion),
            RegisterFormField(
              'Calle Principal *',
              Icons.home,
              hint: 'Avda Mcal López',
            ),
            const SizedBox(width: 100, height: separacion),
            Row(
              children: [
                Flexible(
                  child: RegisterFormField(
                    'Calle Secundaria',
                    Icons.home,
                    hint: 'esq. #',
                    action: TextInputAction.done,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: RegisterFormField(
                    'Nro.',
                    Icons.home,
                    hint: '1234',
                    action: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 100, height: separacion),
            PassField('Contraseña', TextInputAction.next),
            const SizedBox(width: 100, height: separacion),
            PassField('Confirmar contraseña', TextInputAction.done),
            const SizedBox(width: 100, height: separacion),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () => pageController.previousPage(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.ease),
                    icon: const Icon(Icons.navigate_before)),
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
        StatePicker(
          (newVal) => setState(
            () {
              stateId = newVal;
            },
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
  PassField(this.title, this.action, {Key? key}) : super(key: key);
  String title;
  TextInputAction action;
  @override
  State<PassField> createState() => _PassFieldState();
}

class _PassFieldState extends State<PassField> {
  bool locked = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: locked,
      textInputAction: widget.action,
      decoration: InputDecoration(
        labelText: widget.title,
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
        prefixIcon: GestureDetector(
          onTap: () => setState(() {
            locked = !locked;
          }),
          child: Icon(
            locked ? Icons.lock : Icons.lock_open,
            color: const Color(0xFFED8232),
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
