import 'package:camera/camera.dart';
import 'package:fast_market/main.dart';
import 'package:flutter/material.dart';

class CameraExamplePage extends StatefulWidget {
  const CameraExamplePage({super.key});

  @override
  State<CameraExamplePage> createState() => _CameraExamplePageState();
}

//main에 카메라를 먼저 넣어줘야 해
class _CameraExamplePageState extends State<CameraExamplePage> {
  CameraController? controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller?.initialize().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller?.value.isInitialized ?? false
          ? CameraPreview(controller!)
          : Container(
              child: Text('초기화 중'),
            ),
    );
  }
}
