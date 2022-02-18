import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool passwordVisibility = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3))
        .then((value) => Navigator.of(context).pushNamed('/register'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFed8d23),
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
            tag: 'splash-screen-loading',
            child: Lottie.asset('assets/lottie/camion.json')),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       backgroundColor: const Color(0xFFed8d23),
  //       elevation: 0,
  //     ),
  //     body: Column(
  //       children: [Lottie.asset('assets/lottie/camion.json'), SRegisterPage()],
  //     ),
  //   );
  // }
}
/* class _SplashScreenState extends State<SplashScreen> {
  TextEditingController textController1 = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  bool passwordVisibility = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFed8d23),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Lottie.asset('assets/lottie/camion.json'),
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
                        controller: textController1,
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
                        controller: textController2,
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
                      const SizedBox(
                        width: 100,
                        height: 20,
                      ),
                      const Text('He olvidado mi contraseña',
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const Spacer(),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      const WidgetSpan(
                          child: Text('Aún no tienes una cuenta? ')),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            'Crea una aquí!',
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
          ),
        ],
      ),
    );
  }
} */

class SRegisterPage extends StatefulWidget {
  SRegisterPage({Key? key}) : super(key: key);

  @override
  State<SRegisterPage> createState() => S_RegisterPageState();
}

class S_RegisterPageState extends State<SRegisterPage> {
  bool passwordVisibility = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: PageView(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40, 40, 40, 40),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Email',
                  hint: 'Ejemplo@gmail.com',
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Nombre',
                  hint: 'José',
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
                RegisterFormField(
                  'Cédula',
                  hint: '9888777',
                ),
                const SizedBox(
                  width: 100,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
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
                  const SizedBox(
                    width: 100,
                    height: 20,
                  ),
                  const Text('He olvidado mi contraseña',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const Spacer(),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  const WidgetSpan(child: Text('Aún no tienes una cuenta? ')),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        'Crea una aquí!',
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

class RegisterFormField extends StatelessWidget {
  RegisterFormField(this.label, {this.hint = '', Key? key}) : super(key: key);

  String label = '';
  String hint = '';
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
          return 'Ingresa un valor';
        }

        return null;
      },
    );
  }
}

class RegisterButton extends StatefulWidget {
  RegisterButton(this.callBack, {this.text = 'Iniciar Sesión', Key? key})
      : super(key: key);
  String text;
  Future<bool> callBack;

  @override
  State<RegisterButton> createState() => RegisterButtonState();
}

class RegisterButtonState extends State<RegisterButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: !isLoading
          ? TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFFED8232)),
                padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(100),
                    ),
                  ),
                ),
              ),
              onPressed: () => {
                    setState(() => {
                          isLoading = !isLoading,
                        }),
                    Future.delayed(const Duration(seconds: 3))
                        .then((value) => setState(() => {
                              isLoading = !isLoading,
                            }))
                  },
              child: Text(
                widget.text,
                style: const TextStyle(color: Colors.white),
              ))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
