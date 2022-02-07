import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  TextEditingController textController10 = TextEditingController();
  TextEditingController textController11 = TextEditingController();
  TextEditingController textController9 = TextEditingController();
  TextEditingController textController12 = TextEditingController();
  TextEditingController textController13 = TextEditingController();
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController textController3 = TextEditingController();
  TextEditingController textController4 = TextEditingController();
  TextEditingController textController5 = TextEditingController();
  TextEditingController textController6 = TextEditingController();
  TextEditingController textController7 = TextEditingController();
  TextEditingController textController8 = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late final TabController tabController =
      TabController(length: 3, vsync: this);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  validateFirstPage() {
    //TODO: Condicional de validación de datos en primera página
    if (textController1.text != null &&
        textController2 != null &&
        textController3 != null &&
        textController4.text != null) {
      tabController.animateTo(tabController.index + 1);
      ;
    }
  }

  Future<bool> register() {
    return Future.delayed(const Duration(seconds: 10)).then((value) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFED8232),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
                alignment: const AlignmentDirectional(-1, -1),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.35,
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
                )),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            40, 40, 40, 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: textController1,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Cédula',
                                hintText: 'Ej: 1222333',
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
                                  return 'Ingresa tu número de cédula';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              width: 100,
                              height: 20,
                            ),
                            TextFormField(
                              controller: textController2,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Razón Social',
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
                            ),
                            const SizedBox(
                              width: 100,
                              height: 20,
                            ),
                            TextFormField(
                              controller: textController3,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                hintText: 'Ej: Ramiro',
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
                                  return 'Ingresa un nombre';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              width: 100,
                              height: 20,
                            ),
                            TextFormField(
                              controller: textController4,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'Apellido',
                                hintText: 'Ej: López',
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
                                  return 'Ingresa un apellido';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(
                              width: 100,
                              height: 20,
                            ),
                            TextButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFFED8232))),
                              icon: const Icon(
                                Icons.navigate_next,
                                color: Colors.white,
                                size: 30,
                              ),
                              label: const Text(''),
                              onPressed: () {
                                validateFirstPage();
                              },
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: textController5,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Cédula',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        TextFormField(
                          controller: textController6,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Razón Social',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        TextFormField(
                          controller: textController7,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        TextFormField(
                          controller: textController8,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            print('IconButton pressed ...');
                          },
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xFFED8232))),
                          icon: const Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: 30,
                          ),
                          label: const Text(''),
                          onPressed: () {
                            validateFirstPage();
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: textController9,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: '[Some hint text...]',
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
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Ingresa un email';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                          width: 100,
                          height: 20,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: textController10,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Celular',
                                  hintText: '[Some hint text...]',
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
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Ingresa un email';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: textController11,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelText: 'Teléfono',
                                  hintText: '[Some hint text...]',
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
                                keyboardType: TextInputType.phone,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return 'Ingresa un email';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 100,
                          height: 20,
                        ),
                        TextFormField(
                          controller: textController12,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        TextFormField(
                          controller: textController13,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Apellido',
                            hintText: '[Some hint text...]',
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
                          height: 20,
                        ),
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.navigate_next,
                        //     color: Colors.white,
                        //     size: 30,
                        //   ),
                        //   onPressed: () {
                        //     print('IconButton pressed ...');
                        //   },
                        // ),

                        RegisterButton(register())
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  const WidgetSpan(child: Text('Ya tienes una cuenta? ')),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Inicia sesión!',
                        style: TextStyle(
                            color: Color(0xFFED8232),
                            fontSize: 16,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ])),
            const SizedBox(
              height: 18,
            )
          ],
        ),
      ),
    );
  }
}

class RegisterButton extends StatefulWidget {
  RegisterButton(this.register, {Key? key}) : super(key: key);

  Future<bool> register;
  @override
  State<RegisterButton> createState() => RegisterButtonState();
}

class RegisterButtonState extends State<RegisterButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: ButtonStyle(
          backgroundColor: isLoading
              ? MaterialStateProperty.all(const Color(0xFFA0A0A0))
              : MaterialStateProperty.all(const Color(0xFFED8232))),
      icon: isLoading
          ? const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : const Icon(
              Icons.app_registration,
              color: Colors.white,
              size: 30,
            ),
      label: const Text(''),
      onPressed: isLoading
          ? null
          : () async {
              print('Registrando');
              print('Estado: ' + isLoading.toString());
              setState(() {
                isLoading = !isLoading;
              });
              print('Estado: ' + isLoading.toString());
              bool resp = await widget.register;
              print(resp);
              if (resp) {
                print('Registrado');
                setState(() {
                  isLoading = !isLoading;
                });
              }
            },
    );
  }
}
