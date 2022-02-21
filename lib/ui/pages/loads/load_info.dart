import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';

class LoadInfo extends StatelessWidget {
  LoadInfo(this.load, {Key? key}) : super(key: key);
  Load load;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text(load.addressFrom),
    );
  }
}
