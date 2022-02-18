import 'dart:io';

import 'package:image_picker/image_picker.dart';

chooseImage() async {
  final getImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if (getImage != null) {
    return File(getImage.path);
  }
  return null;
}
