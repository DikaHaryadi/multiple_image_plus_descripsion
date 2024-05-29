import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multipleimage/video/video_trim_controller.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimView extends GetView<VideoTrimController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Video Trimmer'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: controller.progressVisibility.value
                  ? controller.saveVideo()
                  : null,
            )
          ],
        ),
        body: Column(
          children: [
            Visibility(
              visible: controller.progressVisibility.value,
              child: LinearProgressIndicator(),
            ),
            TrimViewer(
              trimmer: controller.trimmer,
              viewerHeight: 50.0,
              maxVideoLength: Duration(seconds: 60),
              viewerWidth: MediaQuery.of(context).size.width,
              durationStyle: DurationStyle.FORMAT_MM_SS,
              onChangeStart: (value) {
                controller.startValue.value = value;
              },
              onChangeEnd: (value) {
                controller.endValue.value = value;
              },
              onChangePlaybackState: (value) {
                controller.isPlaying.value = value;
              },
            ),
            Expanded(
              child: VideoViewer(trimmer: controller.trimmer),
            ),
            TextButton(
              child: Obx(() {
                return controller.isPlaying.value
                    ? Icon(Icons.pause, size: 80.0, color: Colors.black)
                    : Icon(Icons.play_arrow, size: 80.0, color: Colors.black);
              }),
              onPressed: () async {
                final playbackState =
                    await controller.trimmer.videoPlaybackControl(
                  startValue: controller.startValue.value,
                  endValue: controller.endValue.value,
                );
                controller.isPlaying.value = playbackState;
              },
            ),
          ],
        ));
  }
}
