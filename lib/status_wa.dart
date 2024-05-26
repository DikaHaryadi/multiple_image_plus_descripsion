import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:multipleimage/account.dart';
import 'image_controller.dart';

class StatusWaScreen extends GetView<ImageController> {
  const StatusWaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Obx(() {
                  final selectedMedia =
                      Get.find<ImageController>().selectedMediaData.value;
                  if (selectedMedia != null) {
                    if (selectedMedia.type == MediaType.video) {
                      return FutureBuilder<ChewieController>(
                        future: Get.find<ImageController>()
                            .initializeChewieController(selectedMedia.path),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Chewie(controller: snapshot.data!);
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            return const Center(
                                child: Text('Failed to load video'));
                          }
                        },
                      );
                    } else if (selectedMedia.type == MediaType.image) {
                      return Image.file(
                        File(selectedMedia.path),
                        fit: BoxFit.cover, // Adjust fit based on your design
                      );
                    } else {
                      return const Center(
                          child: Text('Unsupported media type'));
                    }
                  } else {
                    return const Center(child: Text('No media selected'));
                  }
                }),
              ),
              Positioned(
                  top: 0,
                  child: IconButton(
                    onPressed: () {
                      controller.clearImages();
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                  )),
              Positioned(
                bottom: 20,
                right: 20,
                left: 20,
                child: Obx(
                  () => Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: List.generate(controller.mediaData.length,
                                (index) {
                              final media = controller.mediaData[index];
                              final isSelected =
                                  controller.selectedMediaData.value == media;
                              return GestureDetector(
                                onTap: () {
                                  controller.selectedMediaData.value = media;
                                  controller.description.text =
                                      media.description;
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 10.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.red
                                          : Colors.green,
                                      width: isSelected ? 3.0 : 1.0,
                                    ),
                                  ),
                                  child: media.type == MediaType.image
                                      ? Image.file(File(media.path),
                                          fit: BoxFit.cover)
                                      : media.thumbnailPath != null
                                          ? Image.file(
                                              File(media.thumbnailPath!),
                                              fit: BoxFit.cover)
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator()), // Placeholder for thumbnail loading
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green.shade200,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.abc),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.description,
                                  decoration: const InputDecoration(
                                    hintText: 'Tambahkan keterangan...',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    final selectedMedia =
                                        controller.selectedMediaData.value;
                                    if (selectedMedia != null) {
                                      selectedMedia.description = value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Colors.grey.shade300,
                            ),
                            child: Text('Status (16 dikecualikan)'),
                          ),
                          InkWell(
                            onTap: () => Get.to(() => const Profile()),
                            child: CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.forward),
                            ),
                          )
                        ],
                      )
                      // Container(
                      //   padding: const EdgeInsets.all(12.0),
                      //   child: TextFormField(
                      //     controller: controller.description,
                      //     decoration: const InputDecoration(
                      //       hintText: 'Tambahkan keterangan...',
                      //       border: OutlineInputBorder(),
                      //     ),
                      //     onChanged: (value) {
                      //       final selectedMedia =
                      //           controller.selectedMediaData.value;
                      //       if (selectedMedia != null) {
                      //         selectedMedia.description = value;
                      //       }
                      //     },
                      //   ),
                      // ),
                      // const SizedBox(height: 12.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
