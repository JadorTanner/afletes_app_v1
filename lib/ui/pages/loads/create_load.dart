// ignore_for_file: avoid_init_to_null

import 'dart:convert';

import 'package:afletes_app_v1/models/categories.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/custom_paint.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

Future<List<Category>> getCategories() async {
  Api api = Api();
  Response response = await api.getData('get-categories');
  if (response.statusCode == 200) {
    Map jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      List data = jsonResponse['data'];
      if (data.isNotEmpty) {
        categories.clear();
        data.asMap().forEach((key, category) {
          categories.add(Category(id: category['id'], name: category['name']));
        });
        return categories;
      }
    }
  }
  return categories;
}

class CreateLoadPage extends StatefulWidget {
  CreateLoadPage({Key? key}) : super(key: key);

  @override
  State<CreateLoadPage> createState() => _CreateLoadPageState();
}

List<Category> categories = [];

class _CreateLoadPageState extends State<CreateLoadPage> {
  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BaseApp(PageView(
      children: [
        DatosGenerales(),
        Text('ubicacion de salida'),
        Text('ubicacion de entrega'),
        Text('Tiempos'),
      ],
    ));
  }
}

class DatosGenerales extends StatelessWidget {
  DatosGenerales({Key? key}) : super(key: key);

  TextEditingController productController = TextEditingController(),
      descriptionController = TextEditingController();
  GlobalKey productKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[200],
        ),
        //producto
        LoadFormField(
          productController,
          'Producto *',
          key: productKey,
          maxLength: 10,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //Categoría
            CategoriaSelect(),
            //Unidad de medida
            MeasurementUnit()
          ],
        ),
        Row(
          children: [
            //Peso
            Flexible(
              child: LoadFormField(
                descriptionController,
                'Peso *',
                type: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            //Volumen
            Flexible(
              child: LoadFormField(
                descriptionController,
                'Volumen',
                type: const TextInputType.numberWithOptions(decimal: true),
              ),
            )
          ],
        ),
        Row(
          children: [
            //Vehiculos requeridos
            Flexible(
              child: LoadFormField(
                descriptionController,
                'Vehículos requeridos',
                type: TextInputType.number,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            //Ayudante requeridos
            Flexible(
              child: LoadFormField(
                descriptionController,
                'Ayudantes requeridos',
                type: TextInputType.number,
              ),
            ),
          ],
        ),
        //Descripción
        LoadFormField(descriptionController, 'Descripción'),
      ],
    );
  }
}

class LoadFormField extends StatelessWidget {
  LoadFormField(this.controller, this.label,
      {this.maxLength = 255,
      this.type = TextInputType.text,
      this.autofocus = false,
      this.icon = null,
      Key? key})
      : super(key: key);
  bool autofocus;
  TextEditingController controller;
  TextInputType type;
  int maxLength;
  Icon? icon;
  String label;
  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      controller: controller,
      keyboardType: type,
      maxLength: maxLength != 255 ? maxLength : null,
      decoration: InputDecoration(prefixIcon: icon, label: Text(label)),
    );
  }
}

class MeasurementUnit extends StatefulWidget {
  MeasurementUnit({Key? key}) : super(key: key);

  @override
  State<MeasurementUnit> createState() => _MeasurementUnitState();
}

class _MeasurementUnitState extends State<MeasurementUnit> {
  String value = '1';
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
        },
        items: const [
          DropdownMenuItem(
            child: Text('Kilo'),
            value: '1',
          )
        ]);
  }
}

class CategoriaSelect extends StatefulWidget {
  CategoriaSelect({Key? key}) : super(key: key);

  @override
  State<CategoriaSelect> createState() => _CategoriaSelectState();
}

class _CategoriaSelectState extends State<CategoriaSelect> {
  String value = '0';

  @override
  void initState() {
    super.initState();
    if (categories.isNotEmpty) {
      setState(() {
        value = categories[0].id.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCategories(),
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
            // setState(() {
            //   value = newValue!;
            // });
            print(newValue);
          },
          items: snapshot.connectionState == ConnectionState.done
              ? List.generate(categories.length, (index) {
                  print(categories[index].id);
                  return DropdownMenuItem(
                    child: Text(categories[index].name),
                    value: categories[index].id.toString(),
                  );
                })
              : const [
                  DropdownMenuItem(
                    child: Text('Categorías'),
                    value: '0',
                  )
                ],
        );
      },
    );
  }
}
