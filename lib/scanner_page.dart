import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? controller;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initialiseCamera();
  }

  Future<void> initialiseCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      return;
    }

    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    if (mounted) {
      setState(() {
        isCameraReady = true;
      });
    }
  }

  Future<void> takePicture() async {
    if (!isCameraReady || controller == null) {
      return;
    }

    final XFile image = await controller!.takePicture();

    print("Photo captured: ${image.path}");

    // TODO: Send image to flower identification API
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Flower"),
      ),

      body: Stack(
        children: [

          // Camera preview
          Positioned.fill(
            child: CameraPreview(controller!),
          ),

          // Instructions
          const Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Text(
              "Point your camera at a flower",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Camera button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: takePicture,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}