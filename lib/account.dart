import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multipleimage/image_controller.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Center(
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: Ink.image(
                  image: const NetworkImage(
                      'https://sematskill.com/wp-content/uploads/2023/05/Perbedaan-People-dan-Person-dalam-Kalimat-Bahasa-Inggris.jpg'),
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160,
                  child: const InkWell(
                      // onTap: onTap, //ini action buat fotonya
                      ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => controller.selectMedia(),
                child: Text(
                  "Select Images",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(185, 255, 213, 0),
                  elevation: 0,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  controller.clearImages();
                  print('clear image berhasil');
                },
                child: Text(
                  "Clear",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(185, 255, 213, 0),
                  elevation: 0,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: controller.uploadImages,
            child: Text(
              "Upload",
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(185, 255, 213, 0),
              elevation: 0,
            ),
          ),
          const Text('Ini Text'),
          Expanded(
            child: Obx(() => ListView.separated(
                  itemCount: controller.mediaData.length,
                  itemBuilder: (context, index) {
                    MediaData media = controller.mediaData[index];
                    return Stack(children: [
                      Column(
                        children: [
                          media.type == MediaType.image
                              ? Image.file(
                                  File(media.path),
                                  fit: BoxFit.cover,
                                )
                              : FutureBuilder<ChewieController>(
                                  future: controller
                                      .initializeChewieController(media.path),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return AspectRatio(
                                        aspectRatio: 18 / 9,
                                        child: Chewie(
                                          controller: snapshot.data!,
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        height:
                                            200, // Ensure the container has the same height to keep the UI consistent
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                  },
                                ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(media.description)),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                            onPressed: () {}),
                      ),
                    ]);
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                )),
          )
        ],
      ),
    );
  }
}
