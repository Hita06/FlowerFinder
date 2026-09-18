// FlowerFinder G1 - Flower Scanner Page
// Created by Iris
// Connected to the Flower Information page by Hita.
// This page allows users to photograph, upload and identify flowers.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'flower_api.dart';
import 'flower_information_page.dart';
import 'theme.dart';

class ScannerPage extends StatefulWidget {
  // Callback used to open the Create Sticker page.
  final ValueChanged<String> onAddSticker;

  const ScannerPage({
    super.key,
    required this.onAddSticker,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? controller;

  bool cameraReady = false;
  bool isIdentifying = false;
  bool isSavingSticker = false;

  // Prevents another photo from being taken while the
  // previous camera capture is still processing.
  bool isTakingPicture = false;

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
      // Prevent multiple camera controllers from being created.
      if (controller != null) {
        return;
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        print('No cameras found');
        return;
      }

      // Prefer the rear-facing camera.
      final camera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final newController = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      controller = newController;

      await newController.initialize();

      // The page may have been removed while the camera
      // was initializing.
      if (!mounted) {
        await newController.dispose();
        controller = null;
        return;
      }

      // Enable automatic focus.
      try {
        await newController.setFocusMode(
          FocusMode.auto,
        );
      } catch (_) {
        // Some devices may not support changing focus mode.
      }

      if (!mounted) return;

      setState(() {
        cameraReady = true;
      });

      print('Camera ready');
    } catch (e) {
      print('Camera initialisation error: $e');

      if (mounted) {
        setState(() {
          cameraReady = false;
        });
      }
    }
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> takePicture() async {
    // Prevent taking another picture if the camera is not ready
    // or a previous capture is still being processed.
    if (!cameraReady ||
        controller == null ||
        isTakingPicture ||
        controller!.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        isTakingPicture = true;
      });

      final XFile image = await controller!.takePicture();

      if (!mounted) return;

      setState(() {
        imagePath = image.path;
        isTakingPicture = false;
      });

      print('Photo captured: ${image.path}');
    } catch (e) {
      print('Error taking photo: $e');

      if (!mounted) return;

      setState(() {
        isTakingPicture = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to take photo: $e',
          ),
        ),
      );
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

      if (image == null || !mounted) {
        return;
      }

      setState(() {
        imagePath = image.path;
      });

      print('Gallery image selected: ${image.path}');
    } catch (e) {
      print('Error selecting image: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select image: $e',
          ),
        ),
      );
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

      final result =
          await FlowerApi.identifyFlower(imagePath!);

      final String? bestMatch =
          result['bestMatch']?.toString();

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
  // SAVE IMAGE AS STICKER
  // ============================================================

  Future<void> saveAsSticker() async {
    if (imagePath == null) {
      return;
    }

    try {
      setState(() {
        isSavingSticker = true;
      });

      // Gets the app's private documents directory.
      final directory =
          await getApplicationDocumentsDirectory();

      // Creates the stickers folder.
      final stickersDirectory = Directory(
        '${directory.path}/stickers',
      );

      if (!await stickersDirectory.exists()) {
        await stickersDirectory.create(
          recursive: true,
        );
      }

      // Gives the sticker a unique filename.
      final fileName =
          'sticker_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final newPath =
          '${stickersDirectory.path}/$fileName';

      // Copies the selected image into the sticker folder.
      final savedSticker =
          await File(imagePath!).copy(newPath);

      print('Sticker saved: ${savedSticker.path}');

      if (!mounted) return;

      setState(() {
        isSavingSticker = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Image saved as a sticker!',
          ),
        ),
      );
    } catch (e) {
      print('Error saving sticker: $e');

      if (!mounted) return;

      setState(() {
        isSavingSticker = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save sticker: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SHOW FLOWER RESULT
  // ============================================================

  void showFlowerResult(String? flowerName) {
    // Uses the identified flower name or a fallback value.
    final String identifiedName =
        flowerName?.trim().isNotEmpty == true
            ? flowerName!.trim()
            : 'Unknown flower';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        return Container(
          width: double.infinity,

          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(sheetContext).size.height *
                    0.55,
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
                // ==================================================

                Text(
                  'Flower Identified!',
                  textAlign: TextAlign.center,

                  style: Theme.of(sheetContext)
                      .textTheme
                      .headlineMedium,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FLOWER NAME
                // ==================================================

                Text(
                  identifiedName,
                  textAlign: TextAlign.center,

                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  'Your flower has been identified successfully.',
                  textAlign: TextAlign.center,

                  style: Theme.of(sheetContext)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SAVE AS STICKER
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: OutlinedButton.icon(
                    onPressed: isSavingSticker
                        ? null
                        : () {
                            // Close the result popup first.
                            Navigator.pop(sheetContext);

                            // Open Create Sticker using
                            // the current scanned/selected photo.
                            if (imagePath != null) {
                              widget.onAddSticker(
                                imagePath!,
                              );
                            }
                          },

                    icon: const Icon(
                      Icons.sticky_note_2_outlined,
                    ),

                    label: Text(
                      'Save as Sticker',

                      style: Theme.of(sheetContext)
                          .textTheme
                          .labelLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // VIEW FLOWER DETAILS
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      // Close the result popup.
                      Navigator.pop(sheetContext);

                      // Open the Flower Information page.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FlowerInformationPage(
                            flowerName:
                                identifiedName,

                            scientificName:
                                identifiedName,

                            description:
                                'This flower was identified '
                                'using the FlowerFinder '
                                'scanner.',

                            flowerType:
                                'Flowering plant',

                            flowerColour:
                                'Not available',

                            season:
                                'Not available',

                            careTips:
                                'Detailed care information '
                                'is not currently available.',
                          ),
                        ),
                      );
                    },

                    child: Text(
                      'View Flower Details',

                      style: Theme.of(sheetContext)
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
                      Navigator.pop(sheetContext);
                    },

                    child: Text(
                      'Close',

                      style: Theme.of(sheetContext)
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
    controller = null;

    super.dispose();
  }

  // ============================================================
  // BUILD USER INTERFACE
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
              // CAMERA OR IMAGE PREVIEW
              // ==================================================

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  clipBehavior: Clip.antiAlias,

                  child: Center(
                    child:
                        !cameraReady ||
                                controller == null
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : imagePath == null

                                // ==================================================
                                // CAMERA PREVIEW
                                // ==================================================

                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),

                                    child: SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,

                                        child: SizedBox(
                                          width: controller!
                                              .value
                                              .previewSize!
                                              .height,

                                          height: controller!
                                              .value
                                              .previewSize!
                                              .width,

                                          child:
                                              CameraPreview(
                                            controller!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )

                                // ==================================================
                                // SELECTED PHOTO
                                // ==================================================

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
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton.icon(
                          onPressed:
                              cameraReady &&
                                      !isTakingPicture
                                  ? takePicture
                                  : null,

                          icon: const Icon(
                            Icons.camera_alt,
                          ),

                          label: Text(
                            isTakingPicture
                                ? 'Taking Photo...'
                                : 'Take Photo',

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

                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: OutlinedButton.icon(
                          onPressed:
                              isTakingPicture
                                  ? null
                                  : pickImage,

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
                    // BUTTONS SHOWN AFTER SELECTING AN IMAGE
                    // ==================================================

                    if (imagePath != null) ...[
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