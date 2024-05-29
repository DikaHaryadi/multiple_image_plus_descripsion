import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:multipleimage/final/upload_process.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path/path.dart' as path;

class ImageController extends GetxController {
  static ImageController get instance => Get.find();

  final pageController = PageController();
  final description = TextEditingController();
  RxList<MediaData> mediaData = <MediaData>[].obs;
  final Rx<MediaData?> selectedMediaData = Rx<MediaData?>(null);

  final Trimmer trimmer = Trimmer();
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var isPlaying = false.obs;
  var progressVisibility = false.obs;

  Future<void> selectMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.media, allowMultiple: true, allowCompression: false);

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
              print('aknanf');
              trimmer.loadVideo(videoFile: File(file.path!));
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

          await Get.to(() => UploadProcess());

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

    await Get.to(() => const UploadProcess());

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
    if (mediaData.isEmpty) {
      selectedMediaData.value = null;
    } else {
      selectedMediaData.value = mediaData.first;
    }
    update(); // Update the UI after removing an image
  }

  void clearImages() {
    mediaData.clear();
    selectedMediaData.value = null;
    update(); // Update the UI after clearing images
  }

  void editMedia(int index) async {
    final media = mediaData[index];
    if (media.type == MediaType.image) {
      print('Original image path: ${media.path}');
      try {
        final editedImage =
            await Get.to(() => ImageEditor(image: File(media.path)));
        if (editedImage != null) {
          print('Edited image path: ${editedImage.path}');
          if (File(editedImage.path).existsSync()) {
            print('Edited image file exists.');
            mediaData[index] =
                MediaData(editedImage.path, media.description, MediaType.image);
            selectedMediaData.value = mediaData[index];
            update(); // Update the UI with the edited image
          } else {
            print('Edited image file does not exist.');
          }
        } else {
          print('Edited image is null');
        }
      } catch (e) {
        print('Error editing image: $e');
      }
    }

    update();
  }

  saveVideo() async {
    progressVisibility.value = true;
    String? result;
    print('ini result edit video: $result');
    await trimmer.saveTrimmedVideo(
        startValue: startValue.value,
        endValue: endValue.value,
        onSave: (value) {
          progressVisibility.value = false;
          result = value;
          Get.snackbar("Video", result!);
        });
  }

  void uploadImages() {
    // Implement the functionality to handle uploading the images
    print('Images would be uploaded here');
  }

  Future<String> saveEditedImage(
      Uint8List imageBytes, String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(originalPath);
    final editedImagePath = '${directory.path}/edited_$fileName';
    final file = File(editedImagePath);
    await file.writeAsBytes(imageBytes);
    return editedImagePath;
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
