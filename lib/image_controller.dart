import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:multipleimage/status_wa.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageController extends GetxController {
  static ImageController get instance => Get.find();

  final pageController = PageController();
  final description = TextEditingController();
  RxList<MediaData> mediaData = <MediaData>[].obs;
  final Rx<MediaData?> selectedMediaData = Rx<MediaData?>(null);

  Future<void> selectMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result != null) {
        List<MediaData> selectedMedia = [];
        for (var file in result.files) {
          if (file.path != null) {
            MediaType type =
                file.extension == 'mp4' ? MediaType.video : MediaType.image;
            String? thumbnailPath;
            if (type == MediaType.video) {
              thumbnailPath = await VideoThumbnail.thumbnailFile(
                video: file.path!,
                thumbnailPath: (await getTemporaryDirectory()).path,
                imageFormat: ImageFormat.PNG,
                maxHeight: 50,
                quality: 75,
              );
            }

            selectedMedia.add(
                MediaData(file.path!, '', type, thumbnailPath: thumbnailPath));
          }
        }

        if (selectedMedia.isNotEmpty) {
          mediaData.addAll(selectedMedia);
          update();

          // Set default selected media to index 0
          selectedMediaData.value = mediaData[0];

          await Get.to(() => const StatusWaScreen());

          // After returning from StatusWaScreen, handle description updates
          for (var media in selectedMedia) {
            if (media.description.isNotEmpty) {
              mediaData.add(media);
            }
          }
          update();
        }
      }
    } catch (e) {
      print('Error picking media: ${e.toString()}');
    }
  }

  Future<void> editDescription(BuildContext context, int index) async {
    selectedMediaData.value = mediaData[index];
    description.text = mediaData[index].description;

    await Get.to(() => const StatusWaScreen());

    // After returning from StatusWaScreen, handle description updates
    final updatedMedia = selectedMediaData.value;
    if (updatedMedia != null && updatedMedia.description.isEmpty) {
      updatedMedia.description =
          'Enter Description'; // Default description if left empty
    }

    mediaData[index] = updatedMedia ?? mediaData[index];
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
  final String? thumbnailPath;

  MediaData(this.path, this.description, this.type, {this.thumbnailPath});
}

enum MediaType { image, video }
