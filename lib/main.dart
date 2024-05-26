import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multipleimage/account.dart';
import 'package:multipleimage/theme_controller.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Profile(),
    );
  }
}

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  List<MediaData> mediaFileList = [];

  Future<void> selectMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true,
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.path != null) {
            String? description = await _showDescriptionDialog(file.path!,
                null); //berarti ini nanti di ganti jadi classs StatusWa..

            if (description != null) {
              MediaType type =
                  file.extension == 'mp4' ? MediaType.video : MediaType.image;
              setState(() {
                mediaFileList.add(MediaData(file.path!, description, type));
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error picking media: ${e.toString()}');
    }
  }

  void removeImage(int index) {
    setState(() {
      mediaFileList.removeAt(index);
    });
  }

  void clearImages() {
    setState(() {
      mediaFileList.clear();
    });
  }

  void uploadImages() {
    // Implement the functionality to handle uploading the images
    print('Images would be uploaded here');
  }

  void editDescription(int index) async {
    String? newDescription = await _showDescriptionDialog(
        mediaFileList[index].path, mediaFileList[index].description);
    if (newDescription != null && newDescription.isEmpty) {
      newDescription = 'Enter Description'; // Default description if left empty
    }

    setState(() {
      mediaFileList[index].description = newDescription ?? 'Enter Description';
    });
  }

  void editMediaDescription(int index) async {
    TextEditingController descriptionController =
        TextEditingController(text: mediaFileList[index].description);
    String? newDescription = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Enter new description"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () =>
                  Navigator.of(context).pop(descriptionController.text.trim()),
            ),
          ],
        );
      },
    );

    if (newDescription != null &&
        newDescription.isNotEmpty &&
        newDescription != mediaFileList[index].description) {
      setState(() {
        mediaFileList[index].description = newDescription;
      });
    }
  }

  Future<String?> _showDescriptionDialog(
      String filePath, String? initialDescription) async {
    TextEditingController descriptionController =
        TextEditingController(text: initialDescription);

    bool isVideo = filePath.toLowerCase().endsWith('.mp4') ||
        filePath.toLowerCase().endsWith('.mov') ||
        filePath.toLowerCase().endsWith('.avi');

    VideoPlayerController? videoController;
    Future<void>? initializeVideoPlayerFuture;
    ChewieController? chewieController;

    if (isVideo) {
      videoController = VideoPlayerController.file(File(filePath));
      initializeVideoPlayerFuture = videoController.initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: false, // Set to false to prevent auto-playing the video
          looping: true, // Loop the video
          // Optionally customize the controls
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.lightGreen,
          ),
        );
        if (mounted)
          setState(
              () {}); // This is crucial to rebuild the widget with the video player
      }).catchError((error) {
        print("Error initializing video: $error");
      });
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Description'),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite, // Make the dialog take full width
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isVideo)
                        FutureBuilder(
                          future: initializeVideoPlayerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                videoController!.value.isInitialized) {
                              return AspectRatio(
                                aspectRatio: videoController.value.aspectRatio,
                                child: Chewie(
                                  controller: chewieController!,
                                ),
                              );
                            } else {
                              return Container(
                                height: 200,
                                width: double.infinity,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        )
                      else
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height *
                                0.3, // Use 30% of the screen height
                          ),
                          child: Image.file(
                            File(filePath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      SizedBox(height: 10),
                      TextField(
                        controller: descriptionController,
                        decoration:
                            InputDecoration(hintText: "Enter description"),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                videoController?.pause();
                videoController?.dispose();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                videoController?.pause();
                videoController?.dispose();
                Navigator.of(context).pop(
                    descriptionController.text.trim().isEmpty
                        ? ''
                        : descriptionController.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: selectMedia,
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
                      onPressed: clearImages,
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
                  onPressed: uploadImages,
                  child: Text(
                    "Upload",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(185, 255, 213, 0),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: mediaFileList.length,
              itemBuilder: (context, index) {
                MediaData media = mediaFileList[index];
                return Stack(children: [
                  Column(
                    children: [
                      media.type == MediaType.image
                          ? Image.file(
                              File(mediaFileList[index].path),
                              fit: BoxFit.cover,
                            )
                          : FutureBuilder<ChewieController>(
                              future: _initializeChewieController(media.path),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return AspectRatio(
                                    aspectRatio: snapshot
                                        .data!
                                        .videoPlayerController
                                        .value
                                        .aspectRatio,
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
                            Expanded(
                                child: Text(mediaFileList[index].description)),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editMediaDescription(index),
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
                      onPressed: () => removeImage(index),
                    ),
                  ),
                ]);
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
            ),
          ),
        ],
      ),
    );
  }
}

Future<ChewieController> _initializeChewieController(String videoPath) async {
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

class MediaData {
  final String path;
  String description;
  final MediaType type;

  MediaData(this.path, this.description, this.type);
}

enum MediaType { image, video }
