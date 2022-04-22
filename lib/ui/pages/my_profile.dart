// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController emailController = TextEditingController();
TextEditingController nombreController = TextEditingController();
TextEditingController apellidoController = TextEditingController();
TextEditingController legalNameController = TextEditingController();
TextEditingController documentNumberController = TextEditingController();
TextEditingController cellphoneController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController street1Controller = TextEditingController();
TextEditingController street2Controller = TextEditingController();
TextEditingController houseNumberController = TextEditingController();
TextEditingController cityIdController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController passwordConfirmationController = TextEditingController();

class MyProfilePage extends StatefulWidget {
  MyProfilePage(this.user, {Key? key}) : super(key: key);
  User user;

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String emailinitialValue = '',
      nombreinitialValue = '',
      apellidoinitialValue = '',
      documentinitialValue = '',
      legalnameinitialValue = '',
      cellphoneinitialValue = '',
      phoneinitialValue = '',
      street1initialValue = '',
      street2initialValue = '',
      housenumberinitialValue = '';
  bool canUpdate = false;
  @override
  void initState() {
    super.initState();

    emailController.text = emailinitialValue = widget.user.email;
    nombreController.text = nombreinitialValue = widget.user.firstName;
    apellidoController.text = apellidoinitialValue = widget.user.lastName;
    documentNumberController.text =
        documentinitialValue = widget.user.documentNumber;
    legalNameController.text = legalnameinitialValue = widget.user.legalName;
    cellphoneController.text = cellphoneinitialValue = widget.user.cellphone;
    phoneController.text = phoneinitialValue = widget.user.phone;
    street1Controller.text = street1initialValue = widget.user.street1;
    street2Controller.text = street2initialValue = widget.user.street2;
    houseNumberController.text =
        housenumberinitialValue = widget.user.houseNumber;
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(
      Container(
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20).copyWith(bottom: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: Constants.kGrey,
                      minRadius: 60,
                      child: Text(
                        Provider.of<User>(context)
                            .user
                            .fullName
                            .split(' ')
                            .map((e) => e.length > 2 ? e.substring(0, 1) : '')
                            .join(''),
                        style:
                            const TextStyle(fontSize: 40, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      child: Text(Provider.of<User>(context).user.fullName),
                      alignment: Alignment.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: CustomFormField(
                            documentNumberController,
                            'Documento',
                            onChange: (value) {
                              if (value != documentinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: CustomFormField(
                            legalNameController,
                            'Razón social',
                            onChange: (value) {
                              if (value != legalnameinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
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
                        Flexible(
                          child: CustomFormField(
                            nombreController,
                            'Nombre',
                            onChange: (value) {
                              if (value != nombreinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: CustomFormField(
                            apellidoController,
                            'Apellido',
                            onChange: (value) {
                              if (value != apellidoinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
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
                        Flexible(
                          child: CustomFormField(
                            cellphoneController,
                            'Celular',
                            onChange: (value) {
                              if (value != cellphoneinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: CustomFormField(
                            phoneController,
                            'Teléfono',
                            onChange: (value) {
                              if (value != phoneinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomFormField(
                      street1Controller,
                      'Calle principal',
                      onChange: (value) {
                        if (value != street1initialValue) {
                          if (!canUpdate) {
                            setState(() {
                              canUpdate = !canUpdate;
                            });
                          }
                        } else {
                          setState(() {
                            canUpdate = !canUpdate;
                          });
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: CustomFormField(
                            street2Controller,
                            'Secundaria',
                            onChange: (value) {
                              if (value != street2initialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: CustomFormField(
                            houseNumberController,
                            'Nro',
                            onChange: (value) {
                              if (value != housenumberinitialValue) {
                                if (!canUpdate) {
                                  setState(() {
                                    canUpdate = !canUpdate;
                                  });
                                }
                              } else {
                                setState(() {
                                  canUpdate = !canUpdate;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomFormField(
                      emailController,
                      'Email',
                      type: TextInputType.emailAddress,
                      enabled: false,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                        'Confirma tu contraseña para guardar los cambios'),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child:
                              PasswordField('Contraseña', passwordController),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: PasswordField('Confirmar contraseña',
                              passwordConfirmationController),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Flexible(
                      child: UpdateButton(
                        () {
                          setState(() {
                            canUpdate = false;
                          });
                        },
                      ),
                    )
                  ],
                ))
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}

class UpdateButton extends StatefulWidget {
  UpdateButton(this.afterUpdate, {Key? key}) : super(key: key);
  var afterUpdate;
  @override
  State<UpdateButton> createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: loading
          ? () => {}
          : () async {
              setState(() {
                loading = !loading;
              });
              try {
                Api api = Api();

                Response response = await api.postData('user/update-profile', {
                  'password': passwordController.text,
                  'password_confirmation': passwordConfirmationController.text,
                  'first_name': nombreController.text,
                  'last_name': apellidoController.text,
                  'full_name':
                      apellidoController.text + ' ' + nombreController.text,
                  'legal_name': legalNameController.text,
                  'document_number': documentNumberController.text,
                  'cellphone': cellphoneController.text,
                  'phone': phoneController.text,
                  'street1': street1Controller.text,
                  'street2': street2Controller.text,
                  'house_number': houseNumberController.text,
                });
                print(response.body);
                Map resp = jsonDecode(response.body);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(resp['message'])));
                if (resp['success']) {
                  SharedPreferences shared =
                      await SharedPreferences.getInstance();
                  shared.setString('user', jsonEncode(resp['data']));
                  context
                      .read<User>()
                      .setUser(User.userFromArray(resp['data']));
                  widget.afterUpdate();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ha ocurrido un error')));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ha ocurrido un error')));
              }
              setState(() {
                loading = !loading;
              });
            },
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
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.update,
                  color: Colors.white,
                ),
                Text(
                  'Actualizar datos',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
    );
  }
}
