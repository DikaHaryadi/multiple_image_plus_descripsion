import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker imagePicker = ImagePicker();
  List<ImageData> imageFileList = [];

  Future<void> selectImages() async {
    try {
      final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        for (var image in selectedImages) {
          String? description = await _showDescriptionDialog(image.path);

          if (description != null) {
            setState(() {
              imageFileList.add(ImageData(image.path, description));
              print(imageFileList.toString());
            });
          }
        }
      }
    } catch (e) {
      print('Error picking image: ${e.toString()}');
    }
  }

  Future<String?> _showDescriptionDialog(String imagePath) async {
    TextEditingController descriptionController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambahkan Deskripsi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imagePath),
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: "Masukkan deskripsi"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                Navigator.of(context).pop(descriptionController.text);
              },
            ),
          ],
        );
      },
    );
  }

  void printDescriptions() {
    for (var imageData in imageFileList) {
      print(imageData.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: imageFileList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Image.file(
                      File(imageFileList[index].path),
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(imageFileList[index].description),
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
          ElevatedButton(
            onPressed: selectImages,
            child: Text('Pilih Gambar'),
          ),
          ElevatedButton(
            onPressed: printDescriptions,
            child: Text('Cetak Deskripsi'),
          ),
        ],
      ),
    );
  }
}

class ImageData {
  final String path;
  final String description;

  ImageData(this.path, this.description);
}
