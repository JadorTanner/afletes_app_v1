// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

ImagePicker _picker = ImagePicker();

class ImagesPicker extends StatefulWidget {
  ImagesPicker(
    this.imagenes, {
    Key? key,
  }) : super(key: key);

  List<XFile> imagenes;

  @override
  State<ImagesPicker> createState() => _ImagesPickerState();
}

class _ImagesPickerState extends State<ImagesPicker> {
  int currentImage = 0;
  PageController imagePageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        List<XFile>? imgs = await _picker.pickMultiImage();
        widget.imagenes = imgs ?? [];
        if (widget.imagenes.isNotEmpty) {
          if (mounted) {
            setState(() {
              // imagePageController.jumpToPage(0);
            });
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 200,
        color:
            widget.imagenes.isNotEmpty ? Colors.transparent : Colors.grey[200],
        child: widget.imagenes.isNotEmpty
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView(
                    controller: imagePageController,
                    onPageChanged: (value) => setState(() {
                      currentImage = value;
                    }),
                    children: List.generate(
                      widget.imagenes.length,
                      (index) => Image.file(
                        File(widget.imagenes[index].path),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imagenes.length,
                        (index) => Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: index == currentImage
                                ? const Color(0xFF686868)
                                : const Color(0xFFEEEEEE),
                            border: Border.all(
                              color: index == currentImage
                                  ? const Color(0xFF686868)
                                  : const Color(0xFFEEEEEE),
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const Center(
                child: Icon(
                  Icons.add_a_photo,
                  size: 50,
                ),
              ),
      ),
    );
  }
}

class SingleImagePicker extends StatefulWidget {
  SingleImagePicker(this.title, this.imageFile, this.width,
      {this.onChange, Key? key})
      : super(key: key);
  String title;
  String? imageFile;
  double width;
  var onChange;
  @override
  State<SingleImagePicker> createState() => _SingleImagePickerState();
}

class _SingleImagePickerState extends State<SingleImagePicker> {
  XFile? img;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: const Text('Desde dónde quieres cargar la imágen?'),
                  actions: [
                    TextButton.icon(
                      onPressed: () async {
                        img =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (img != null) {
                          setState(() {
                            widget.imageFile = img!.path;
                          });
                          widget.onChange(img!.path);
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.camera_alt,
                          color: Color(0xFFF58633)),
                      label: const Text('Cámara',
                          style: TextStyle(color: Color(0xFFF58633))),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        img = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) {
                          setState(() {
                            widget.imageFile = img!.path;
                          });
                          widget.onChange(img!.path);
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.image_search_sharp,
                          color: Color(0xFFF58633)),
                      label: const Text('Galería',
                          style: TextStyle(color: Color(0xFFF58633))),
                    ),
                  ],
                ));
      },
      child: Column(
        children: [
          Text(widget.title),
          Container(
            width: widget.width,
            margin: const EdgeInsets.only(bottom: 20),
            height: 150,
            color: img != null ? Colors.transparent : Colors.grey[200],
            child: img != null
                ? Image.file(
                    File(img!.path),
                  )
                : (widget.imageFile != null && widget.imageFile != ''
                    ? Image.network(widget.imageFile!)
                    // Image.file(
                    //     File(widget.imageFile!),
                    //   )
                    : const Center(
                        child: Icon(Icons.photo_camera),
                      )),
          ),
        ],
      ),
    );
  }
}
