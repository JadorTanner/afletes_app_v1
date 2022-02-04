import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/password_input.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<User> user = Future.value(User());
  //FORMULARIO DE LOGIN
  Widget _buildForm(BuildContext context, AsyncSnapshot<User> snapshot) {
    final _formKey = GlobalKey<FormState>();
    final _formPassKey = GlobalKey();

    //REQUEST DE LOGIN
    login() async {
      User userLogged = User();
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('token');
      localStorage.remove('user');
      print('login');
      if (localStorage.getString('token') != null ||
          localStorage.getString('user') != null) {
        Navigator.pushNamed(context, '/home');
      } else {
        Api api = Api();
        Response response = await api.auth(
            {'email': 'transportista@gmail.com', 'password': '123456789'},
            'login');

        if (response.statusCode == 200) {
          Map responseJson = jsonDecode(response.body);
          localStorage.setString('token', responseJson['token']['token']);
          localStorage.setString('user', jsonEncode(responseJson['user']));
          responseJson = responseJson['user'];
          userLogged = User(userData: responseJson).userFromArray();
          print(userLogged);
          print(userLogged.fullName);
        }
      }
      return userLogged;
    }

    validateForm() {
      print('validando');
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Data')),
      );
      login();
    }

    var submitBtn = Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: snapshot.connectionState == ConnectionState.none
                ? validateForm
                : null,
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
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
          ),
        )
      ],
    );

    // var submitBtn = TextButton(
    //   onPressed:
    //       snapshot.connectionState == ConnectionState.none ? login : null,
    //   child: const Icon(Icons.save),
    // );
    var action =
        snapshot.connectionState != ConnectionState.none && !snapshot.hasData
            ? Stack(
                alignment: FractionalOffset.center,
                children: <Widget>[
                  submitBtn,
                  const CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ],
              )
            : submitBtn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //email
          // Container(
          //   decoration: const BoxDecoration(
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //           blurRadius: 5,
          //           color: Color(0xAACCCCCC),
          //           offset: Offset(0, 5)),
          //     ],
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(100),
          //     ),
          //   ),
          // child:
          // Form(
          //   key: _formKey,
          //   child:
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(color: Color(0xFFAAAAAA)),
              ),
              label: Text('Email'),
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo es obligatorio';
              } else {
                bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (emailValid) {
                  return 'Ingrese un email válido';
                }
              }
              return null;
            },
          ),
          // ),
          // ),
          const SizedBox(
            height: 40,
          ),
          //contraseña
          PasswordInput(),
          const SizedBox(
            height: 40,
          ),
          //botón de login
          Center(
            child: action,
          ),

          const SizedBox(
            height: 20,
          ),
          const Text(
            'He olvidado mi contraseña',
            style: TextStyle(
                color: Colors.lightBlue, decoration: TextDecoration.underline),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFED8232),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: ListView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .3,
                child: const Image(
                  image: AssetImage('assets/img/logo.jpg.png'),
                  height: 10,
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
              FutureBuilder(
                  future: user,
                  builder: (context, AsyncSnapshot<User> snapshot) {
                    print(snapshot);
                    if (snapshot.hasData) {
                      Text('Hola ' + snapshot.data!.fullName);
                    }
                    return _buildForm(context, snapshot);
                  })
              // Text('Formulario de login')
            ],
          ),
        ));
  }
}
