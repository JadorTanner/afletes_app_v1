import 'dart:convert';

import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/ui/pages/loads/create_load.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class DepartamentoPicker extends StatefulWidget {
  DepartamentoPicker(this.states, this.controller, this.onChange, {Key? key})
      : super(key: key);
  List<StateModel> states;
  TextEditingController controller;
  var onChange;
  @override
  State<DepartamentoPicker> createState() => _DepartamentoPickerState();
}

class _DepartamentoPickerState extends State<DepartamentoPicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Departamento'),
        DropdownButton(
          // value: widget.states[0].id.toString(),
          value: widget.controller.text,
          icon: const Icon(Icons.arrow_circle_down_outlined),
          elevation: 16,
          isExpanded: true,
          style: Theme.of(context).textTheme.bodyText2,
          underline: Container(
            height: 2,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          onChanged: (String? newValue) {
            widget.onChange(newValue);
            setState(() {
              widget.controller.text = newValue!;
            });
          },
          items: List.generate(
            widget.states.length,
            (index) {
              return DropdownMenuItem(
                child: Text(widget.states[index].name),
                value: widget.states[index].id.toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CityPicker extends StatefulWidget {
  CityPicker(this.controller, this.cities, this.stateId, {Key? key})
      : super(key: key);
  List<City> cities;
  String stateId;
  TextEditingController controller;
  @override
  State<CityPicker> createState() => CityPickerState();
}

class CityPickerState extends State<CityPicker> {
  List<City> cities = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      cities = widget.cities.where((element) {
        return element.state_id.toString() == widget.stateId;
      }).toList();
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ciudad'),
        DropdownButton(
          value: widget.controller.text,
          icon: const Icon(Icons.arrow_circle_down_outlined),
          isExpanded: true,
          elevation: 16,
          style: Theme.of(context).textTheme.bodyText2,
          underline: Container(
            height: 2,
            color:
                Theme.of(context).inputDecorationTheme.border!.borderSide.color,
          ),
          onChanged: (String? newValue) {
            setState(() {
              widget.controller.text = newValue!;
            });
          },
          items: List.generate(
            cities.length,
            (index) {
              return DropdownMenuItem(
                child: Visibility(
                  child: Text(cities[index].name),
                  visible:
                      cities[index].id.toString() == widget.controller.text,
                ),
                value: cities[index].id.toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* class CitiesPicker extends StatefulWidget {
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
 */
class StateAndCityPicker extends StatefulWidget {
  StateAndCityPicker(this.stateController, this.cityController, {Key? key})
      : super(key: key);
  TextEditingController stateController;
  TextEditingController cityController;
  @override
  State<StateAndCityPicker> createState() => _StateAndCityPickerState();
}

class _StateAndCityPickerState extends State<StateAndCityPicker> {
  String departamentoId = '';

  List<StateModel> states = [];
  List<City> cities = [];

  getData() async {
    await getStates();
    await getCities();

    departamentoId = states[0].id.toString();
    widget.stateController.text = departamentoId;
    widget.cityController.text = cities[0].id.toString();
  }

  Future<List> getStates() async {
    try {
      Api api = Api();

      Response response = await api.getData('get-states');
      print(response.body);
      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        // states = jsonResponse['data'];
        for (var state in jsonResponse['data']) {
          states.add(
            StateModel(id: state['id'], name: state['name']),
          );
        }
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

      Response response = await api.getData(
          'get-cities' + (stateId != '' ? '?state_id=' + stateId : ''));
      if (response.statusCode == 200) {
        Map jsonResponse = jsonDecode(response.body);
        for (var city in jsonResponse['data']) {
          cities.add(
            City(
                id: city['id'], name: city['name'], state_id: city['state_id']),
          );
        }
        return cities;
      } else {
        cities = [];
      }
      return cities;
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.stateController.text = '';
        widget.cityController.text = '';
        departamentoId = '';
        return true;
      },
      child: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: DepartamentoPicker(
                            states, widget.stateController, (newVal) {
                          setState(() {
                            departamentoId = newVal;
                          });
                        }),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: CityPicker(
                            widget.cityController, cities, departamentoId),
                      ),
                    ],
                  )
                : const SizedBox.shrink();
          }),
    );
  }
}
