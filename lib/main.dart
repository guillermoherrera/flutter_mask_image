import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_mask_image/result_screen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
//import 'package:mask_for_camera_view/inside_line/mask_for_camera_view_inside_line.dart';
import 'package:mask_for_camera_view/mask_for_camera_view.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_border_type.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_inside_line.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_inside_line_direction.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_inside_line_position.dart';
import 'package:mask_for_camera_view/mask_for_camera_view_result.dart';
import 'package:path_provider/path_provider.dart';

//late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //cameras = await MaskForCameraView.initialize();
  await MaskForCameraView.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final _textRecognizaer = TextRecognizer();

  Future<void> _scannImage(Uint8List imageBytes) async{
    final navigator = Navigator.of(context);
    try {
      //final File file = File.fromRawPath(imageBytes);

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/image.png').create();
      file.writeAsBytesSync(imageBytes);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizaer.processImage(inputImage);

      await navigator.push(MaterialPageRoute(builder: (context) => ResultScreen(text: recognizedText.text) ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ocurrio un error ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        MaskForCameraView(
          visiblePopButton: false,
          appBarColor: Colors.blue,
          title: 'Alinea la INE a la imagen y captura',
          //bottomBarColor: Colors.red,
          takeButtonActionColor: Colors.blue,
          iconsColor: Colors.white,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
          borderType: MaskForCameraViewBorderType.dotted,
          boxBorderWidth: 0,
          boxBorderRadius: 0,
          boxWidth: size.height * .3,
          boxHeight: size.width * 1,
          insideLine: MaskForCameraViewInsideLine(
            position: MaskForCameraViewInsideLinePosition.partFour,
            direction: MaskForCameraViewInsideLineDirection.vertical,
          ),
          // insideLine: MaskForCameraViewInsideLine(
          //   position: MaskForCameraViewInsideLinePosition.endPartThree,
          //   direction: MaskForCameraViewInsideLineDirection.horizontal,
          // ),
          // [cameras.first] is rear camera.
          //cameraDescription: cameras.first,
          onTake: (MaskForCameraViewResult? res) {
            if (res != null) {
              _scannImage(res.croppedImage!);
              
              
              // showModalBottomSheet(
              //   context: context,
              //   isScrollControlled: true,
              //   backgroundColor: Colors.transparent,
              //   builder: (context) => Container(
              //     padding: const EdgeInsets.symmetric(
              //         vertical: 12.0, horizontal: 14.0),
              //     decoration: const BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(26.0),
              //         topRight: Radius.circular(26.0),
              //       ),
              //     ),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         const Text(
              //           "Cropped Images",
              //           style: TextStyle(
              //             fontSize: 24.0,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //         const SizedBox(height: 12.0),
              //         res.croppedImage != null
              //             ? MyImageView(imageBytes: res.croppedImage!)
              //             : Container(),
              //         const SizedBox(height: 8.0),
              //         Row(
              //           children: [
              //             res.firstPartImage != null
              //                 ? Expanded(
              //                     child: MyImageView(
              //                         imageBytes: res.firstPartImage!))
              //                 : Container(),
              //             res.firstPartImage != null &&
              //                     res.secondPartImage != null
              //                 ? const SizedBox(width: 8.0)
              //                 : Container(),
              //             res.secondPartImage != null
              //                 ? Expanded(
              //                     child: MyImageView(
              //                         imageBytes: res.secondPartImage!))
              //                 : Container(),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
              // );
            }
          },
        ),
        //Padding(padding: const EdgeInsets.only(top: 100, right: 10), child: Image(image: const AssetImage('assets/landscape.png'), color: Colors.white, width: size.width * 0.20,)),
        SafeArea(
          child: Align(alignment: Alignment.topRight,
           child: Visibility(
            visible: true,
            child: Padding(
                padding: const EdgeInsets.only(top: 70,right: 10),
                child: ImageIcon(
                  const AssetImage("assets/landscape.png"),
                  size: size.width * .2,
                  color: Colors.white,
                )),
          ),),
        ),
        Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: Image(image: const AssetImage('assets/id_card_ine.png'), color: Colors.white.withOpacity(0.3), width: size.width * 1, height: size.height * 0.3, fit: BoxFit.fill)),
        )
      ],
    );
  }
}

class MyImageView extends StatelessWidget {
  const MyImageView({Key? key, required this.imageBytes}) : super(key: key);
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Image.memory(imageBytes),
      ),
    );
  }
}