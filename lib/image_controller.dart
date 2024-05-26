import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:multipleimage/status_wa.dart';
import 'package:video_player/video_player.dart';

class ImageController extends GetxController {
  static ImageController get instance => Get.find();

  final pageController = PageController();
  final description = TextEditingController();
  RxList<MediaData> mediaData = <MediaData>[].obs;
  final Rx<MediaData?> selectedMediaData = Rx<MediaData?>(null);
  // late VideoPlayerController _videoPlayerController;

  Future<void> selectMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            MediaType type =
                file.extension == 'mp4' ? MediaType.video : MediaType.image;
            print(type.toString());
            String? description = await Get.to(
              () => StatusWaScreen(
                finalPath: file.path!,
                type: type,
              ),
            );

            if (description != null && description.isNotEmpty) {
              mediaData.add(MediaData(file.path!, description, type));
              update(); // Update the UI
            }
          }
        }
      }
    } catch (e) {
      print('Error picking media: ${e.toString()}');
    }
  }

  Future<void> editDescription(BuildContext context, int index) async {
    description.text = mediaData[index].description;
    String? newDescription = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatusWaScreen(
          finalPath: mediaData[index].path,
          deskripsi: mediaData[index].description,
          type: mediaData[index].type,
        ),
      ),
    );

    if (newDescription != null && newDescription.isEmpty) {
      newDescription = 'Enter Description'; // Default description if left empty
    }

    mediaData[index].description = newDescription ?? 'Enter Description';
    update(); // Update the UI
  }

  void removeImage(int index) {
    mediaData.removeAt(index);
    update(); // Update the UI after removing an image
  }

  void clearImages() {
    mediaData.clear();
    update(); // Update the UI after clearing images
  }

  void uploadImages() {
    // Implement the functionality to handle uploading the images
    print('Images would be uploaded here');
  }

  Future<ChewieController> initializeChewieController(String videoPath) async {
    VideoPlayerController videoController =
        VideoPlayerController.file(File(videoPath));
    await videoController.initialize();
    ChewieController chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false, // Auto-play should be off for previews
      looping: false, // Turn off looping for previews
      showControls: true, // Show controls
    );
    return chewieController;
  }
}

class MediaData {
  final String path;
  String description;
  final MediaType type;

  MediaData(this.path, this.description, this.type);
}

enum MediaType { image, video }
