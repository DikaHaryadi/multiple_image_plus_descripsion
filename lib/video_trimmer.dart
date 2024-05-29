import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multipleimage/video/video_trim_controller.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends GetView<VideoTrimController> {
  const TrimmerView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Building TrimmerView widget');
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Video Trimmer'),
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
