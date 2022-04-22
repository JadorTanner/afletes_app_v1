// ignore_for_file: must_be_immutable

import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  DatePicker(this.controller, this.title, {Key? key}) : super(key: key);
  TextEditingController controller;
  String title;
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.controller.text != '') {
      List strings = widget.controller.text.split('-');
      if (strings[1].length < 2) {
        strings[1] = '0' + strings[1];
      }
      if (strings[2].length < 2) {
        strings[2] = '0' + strings[2];
      }
      widget.controller.text = strings.join('-');
      selectedDate = DateTime.parse(widget.controller.text);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Constants.primaryOrange.withAlpha(100),
            colorScheme: ColorScheme.light(primary: Constants.primaryOrange),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = selectedDate.year.toString() +
            '-' +
            selectedDate.month.toString() +
            '-' +
            selectedDate.day.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      widget.controller,
      widget.title,
      onFocus: () => _selectDate(context),
      showCursor: true,
      readOnly: true,
    );
  }
}

class LoadTimePicker extends StatefulWidget {
  LoadTimePicker(this.controller, this.title, {Key? key}) : super(key: key);
  TextEditingController controller;
  String title;
  @override
  State<LoadTimePicker> createState() => LoadTimePickerState();
}

class LoadTimePickerState extends State<LoadTimePicker> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: Constants.primaryOrange.withAlpha(100),
              colorScheme: ColorScheme.light(primary: Constants.primaryOrange),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.controller.text =
            selectedTime.hour.toString() + ':' + selectedTime.minute.toString();
      });
    }
  }

  @override
  void initState() {
    if (widget.controller.text != '') {
      List time = widget.controller.text.split(':');
      if (time[0].length < 2) {
        time[0] = '0' + time[0];
      }
      if (time[1].length < 2) {
        time[1] = '0' + time[1];
      }
      selectedTime =
          TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      widget.controller,
      widget.title,
      onFocus: () => _selectTime(context),
      showCursor: true,
      readOnly: true,
    );
  }
}
