import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'theme.dart';
import '../flower_api.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? controller;

  bool cameraReady = false;
  bool isIdentifying = false;

  String? imagePath;

  @override
  void initState() {
    super.initState();
    initialiseCamera();
  }

  // ============================================================
  // INITIALISE CAMERA
  // ============================================================

  Future<void> initialiseCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        print('No cameras found');
        return;
      }

      final camera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      if (!mounted) return;

      setState(() {
        cameraReady = true;
      });

      print('Camera ready');
    } catch (e) {
      print('Camera initialisation error: $e');
    }
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> takePicture() async {
    if (!cameraReady || controller == null) {
      return;
    }

    try {
      final XFile image = await controller!.takePicture();

      if (!mounted) return;

      setState(() {
        imagePath = image.path;
      });

      print('Photo captured: ${image.path}');
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  // ============================================================
  // UPLOAD IMAGE FROM PHONE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        imagePath = image.path;
      });

      print('Gallery image selected: ${image.path}');
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  // ============================================================
  // TAKE ANOTHER PHOTO
  // ============================================================

  Future<void> takeAnotherPhoto() async {
    if (!mounted) return;

    setState(() {
      imagePath = null;
    });

    print('Ready to take another photo');
  }

  // ============================================================
  // IDENTIFY FLOWER
  // ============================================================

  Future<void> identifyFlower() async {
    if (imagePath == null) {
      return;
    }

    try {
      setState(() {
        isIdentifying = true;
      });

      print('Sending image for identification...');

      final result = await FlowerApi.identifyFlower(
        imagePath!,
      );

      final bestMatch = result['bestMatch'];

      print('Flower identified: $bestMatch');

      if (!mounted) return;

      setState(() {
        isIdentifying = false;
      });

      showFlowerResult(bestMatch);
    } catch (e) {
      print('Identification error: $e');

      if (!mounted) return;

      setState(() {
        isIdentifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Identification failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SHOW FLOWER RESULT
  // ============================================================

  void showFlowerResult(String? flowerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return Container(
          width: double.infinity,

          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.55,
          ),

          padding: const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            30,
          ),

          decoration: const BoxDecoration(
            color: AppColors.cream,

            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),

          child: SafeArea(
            top: false,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                // ==================================================
                // DRAG HANDLE
                // ==================================================

                Container(
                  width: 45,
                  height: 5,

                  margin: const EdgeInsets.only(
                    bottom: 20,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                // ==================================================
                // TITLE
                // Uses AppTheme headline style
                // ==================================================

                Text(
                  'Flower Identified!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FLOWER NAME
                // Uses AppTheme title style
                // ==================================================

                Text(
                  flowerName ?? 'Unknown flower',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DESCRIPTION
                // Uses AppTheme body style
                // ==================================================

                Text(
                  'Your flower has been identified successfully.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // VIEW DETAILS BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);

                      // Add navigation to your
                      // Flower Information page here.
                    },

                    child: Text(
                      'View Flower Details',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CLOSE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: Text(
                      'Close',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            color: AppColors.darkGreen,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Scanner',
        ),
        centerTitle: true,
    ),

      // ----------------------------------------------------------
      // MAIN CONTENT
      // ----------------------------------------------------------

      body: SafeArea(
        child: Container(
          color: AppColors.cream,

          child: Column(
            children: [

              // ==================================================
              // CAMERA / IMAGE PREVIEW
              // ==================================================

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.black,

                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  clipBehavior:
                      Clip.antiAlias,

                  child: Center(
                    child: !cameraReady ||
                            controller == null

                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )

                        : imagePath == null

                            ? CameraPreview(
                                controller!,
                              )

                            : Image.file(
                                File(imagePath!),

                                width:
                                    double.infinity,

                                height:
                                    double.infinity,

                                fit: BoxFit.contain,
                              ),
                  ),
                ),
              ),

              // ==================================================
              // BUTTON AREA
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  20,
                ),

                child: Column(
                  children: [

                    // ==================================================
                    // CAMERA AND UPLOAD BUTTONS
                    // ==================================================

                    if (imagePath == null) ...[

                      // ------------------------------------------------
                      // TAKE PHOTO
                      // ------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton.icon(
                          onPressed: cameraReady
                              ? takePicture
                              : null,

                          icon: const Icon(
                            Icons.camera_alt,
                          ),

                          label: Text(
                            'Take Photo',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ------------------------------------------------
                      // UPLOAD IMAGE
                      // ------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: OutlinedButton.icon(
                          onPressed: pickImage,

                          icon: const Icon(
                            Icons.photo_library,
                          ),

                          label: Text(
                            'Upload Image',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge,
                          ),
                        ),
                      ),
                    ],

                    // ==================================================
                    // AFTER IMAGE HAS BEEN SELECTED
                    // ==================================================

                    if (imagePath != null) ...[

                      // ------------------------------------------------
                      // IDENTIFY FLOWER
                      // ------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(
                          onPressed: isIdentifying
                              ? null
                              : identifyFlower,

                          child: Text(
                            isIdentifying
                                ? 'Identifying...'
                                : 'Identify Flower',

                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ------------------------------------------------
                      // CHOOSE ANOTHER PHOTO
                      // ------------------------------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: OutlinedButton(
                          onPressed: isIdentifying
                              ? null
                              : takeAnotherPhoto,

                          child: Text(
                            'Choose Another Photo',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}