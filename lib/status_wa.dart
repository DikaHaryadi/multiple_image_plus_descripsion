import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:multipleimage/account.dart';
import 'package:multipleimage/image_controller.dart';
import 'package:video_player/video_player.dart';

class StatusWaScreen extends GetView<ImageController> {
  const StatusWaScreen({
    super.key,
    required this.finalPath,
    this.deskripsi,
    required this.type,
  });

  final String finalPath;
  final String? deskripsi;
  final MediaType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Description'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              controller.description.clear();
              // Navigator.of(context).pop(
              //     controller.description.text.trim().isEmpty
              //         ? null
              //         : controller.description.text.trim());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: type == MediaType.video
                ? FutureBuilder<ChewieController>(
                    future: controller.initializeChewieController(finalPath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return AspectRatio(
                          aspectRatio: snapshot
                              .data!.videoPlayerController.value.aspectRatio,
                          child: Chewie(controller: snapshot.data!),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: Image.file(
                        File(finalPath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: Column(
              children: [
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        children:
                            List.generate(controller.mediaData.length, (index) {
                          final media = controller.mediaData[index];
                          final isSelected =
                              controller.selectedMediaData.value == media;
                          return GestureDetector(
                            onTap: () {
                              controller.selectedMediaData.value = media;
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: isSelected ? Colors.red : Colors.green,
                                width: isSelected ? 3.0 : 1.0,
                              )),
                              child: media.type == MediaType.image
                                  ? Image.file(File(media.path),
                                      fit: BoxFit.cover)
                                  : FutureBuilder<ChewieController>(
                                      future:
                                          controller.initializeChewieController(
                                              media.path),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return Chewie(
                                              controller: snapshot.data!);
                                        } else {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.off(() => const Profile()),
                        icon: const Icon(Icons.abc),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller.description,
                          decoration: const InputDecoration(
                            hintText: 'Tambahkan keterangan...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        'Status (16 dikecualikan)',
                        style: Theme.of(context).textTheme.labelLarge!,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.green.shade200,
                      radius: 25,
                      child: const Icon(Icons.forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
