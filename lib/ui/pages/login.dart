import 'package:afletes_app_v1/ui/components/password_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFED8232),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .3,
            child: const Image(
              image: AssetImage('assets/img/logo.jpg'),
              fit: BoxFit.fitHeight,
            ),
            padding: const EdgeInsets.only(
              bottom: 40,
            ),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                color: Color(0xFFED8232),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(80))),
          ),
          Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //email
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            color: Color(0xAACCCCCC),
                            offset: Offset(0, 5)),
                      ],
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          borderSide: BorderSide(color: Color(0xFFAAAAAA)),
                        ),
                        label: Text('Email'),
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  //contraseña
                  PasswordInput(),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => {},
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFED8232)),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(15)),
                            shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'He olvidado mi contraseña',
                    style: TextStyle(
                        color: Colors.lightBlue,
                        decoration: TextDecoration.underline),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  RichText(
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
                  ]))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
