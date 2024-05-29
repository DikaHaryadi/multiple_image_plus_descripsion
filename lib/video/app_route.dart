import 'package:get/get.dart';
import 'package:multipleimage/final/upload.dart';
import 'package:multipleimage/final/upload_process.dart';
import 'package:multipleimage/image_controller.dart';
import 'package:multipleimage/upload_media.dart';
import 'package:multipleimage/video/video_trim_controller.dart';

class AppPages {
  static List<GetPage> routes() => [
        GetPage(name: '/', page: () => FileUploadScreen()),
        // GetPage(
        //     name: '/upload-media',
        //     page: () => UploadMedia(),
        //     binding: BindingsBuilder(
        //       () {
        //         Get.put(ImageController());
        //       },
        //     ))
      ];
}
