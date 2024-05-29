import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multipleimage/image_controller.dart';
import 'package:video_trimmer/video_trimmer.dart';

class UploadMedia extends StatelessWidget {
  const UploadMedia({super.key});

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
                              : Stack(
                                  children: [
                                    Positioned.fill(
                                      child: VideoViewer(
                                          trimmer: controller.trimmer),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: IconButton(
                                              onPressed: () {
                                                controller.clearImages();
                                                Get.back();
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: TextButton(
                                        child: Obx(() {
                                          return controller.isPlaying.value
                                              ? Icon(Icons.pause,
                                                  size: 80.0,
                                                  color: Colors.black)
                                              : Icon(Icons.play_arrow,
                                                  size: 80.0,
                                                  color: Colors.black);
                                        }),
                                        onPressed: () async {
                                          final playbackState = await controller
                                              .trimmer
                                              .videoPlaybackControl(
                                            startValue:
                                                controller.startValue.value,
                                            endValue: controller.endValue.value,
                                          );
                                          controller.isPlaying.value =
                                              playbackState;
                                        },
                                      ),
                                    ),
                                  ],
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
