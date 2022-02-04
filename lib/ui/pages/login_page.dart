import 'package:afletes_app_v1/ui/components/password_input.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TabController tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              //Botones de registro e inicio de sesión
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TabBar(controller: tabController, tabs: const [
                      Tab(
                        child: Text(
                          'Iniciar sesión',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Registrarse',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ]),
                  ),
                  const Spacer(
                    flex: 1,
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              Expanded(
                  child: TabBarView(controller: tabController, children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const LoginFormView(),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: const RegisterFormView(),
                ),
              ]))
            ],
          ),
        ));
  }
}

//### LOGIN ###//
class LoginFormView extends StatelessWidget {
  const LoginFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: 400,
          margin: const EdgeInsets.only(bottom: 20),
          color: Colors.grey,
        ),
        LoginForm()
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        PasswordInput(),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Olvidé mi contraseña',
          textAlign: TextAlign.right,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => {},
                icon: const Icon(
                  Icons.login,
                  color: Colors.white,
                ),
                label: const Text(
                  'Iniciar sesión',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            )
          ],
        )
      ],
    ));
  }
}
//### LOGIN ###//

//### REGISTRO ###//
class RegisterFormView extends StatelessWidget {
  const RegisterFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RegisterForm();
  }
}

class RegisterForm extends StatefulWidget {
  RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
//### REGISTRO ###//
