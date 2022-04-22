// ignore_for_file: must_be_immutable

import 'package:afletes_app_v1/ui/components/form_field.dart';
import 'package:afletes_app_v1/utils/globals.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
            data: ThemeData.light().copyWith(
              primaryColor: primaryOrange.withAlpha(100),
              colorScheme: ColorScheme.light(primary: primaryOrange),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!);
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
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.controller.text =
            selectedTime.hour.toString() + ':' + selectedTime.minute.toString();
      });
    }
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
