// FlowerFinder G1 - Flower Scanner Page
// Created by Iris
// Flower information and saved flowers connected by Hita.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'flower_api.dart';
import 'flower_information_page.dart';
import 'saved_flowers_page.dart';
import 'theme.dart';

class ScannerPage extends StatefulWidget {
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
  bool isTakingPicture = false;

  String? imagePath;

  @override
  void initState() {
    super.initState();
    initialiseCamera();
  }

  Future<void> initialiseCamera() async {
    try {
      if (controller != null) return;

      final cameras = await availableCameras();

      if (cameras.isEmpty || !mounted) {
        return;
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final newController = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      controller = newController;
      await newController.initialize();

      if (!mounted) return;

      try {
        await newController.setFocusMode(FocusMode.auto);
      } catch (_) {
        // Some devices do not support changing focus mode.
      }

      if (!mounted) return;

      setState(() {
        cameraReady = true;
      });
    } catch (e) {
      debugPrint('Camera initialisation error: $e');

      if (!mounted) return;

      setState(() {
        cameraReady = false;
      });
    }
  }

  Future<void> takePicture() async {
    if (!cameraReady ||
        controller == null ||
        isTakingPicture ||
        controller!.value.isTakingPicture) {
      return;
    }

    setState(() {
      isTakingPicture = true;
    });

    try {
      final image = await controller!.takePicture();

      if (!mounted) return;

      setState(() {
        imagePath = image.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to take photo: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isTakingPicture = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (image == null || !mounted) return;

      setState(() {
        imagePath = image.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $e')),
      );
    }
  }

  Future<void> takeAnotherPhoto() async {
    if (!mounted || isIdentifying) return;

    setState(() {
      imagePath = null;
    });
  }

  Future<void> identifyFlower() async {
    // Keeps the result connected to the photo sent to the API.
    final selectedImagePath = imagePath;

    if (selectedImagePath == null || isIdentifying) return;

    setState(() {
      isIdentifying = true;
    });

    try {
      final result = await FlowerApi.identifyFlower(selectedImagePath);
      final bestMatch = result['bestMatch']?.toString();

      if (!mounted) return;

      showFlowerResult(bestMatch, selectedImagePath);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Identification failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isIdentifying = false;
        });
      }
    }
  }

  // Existing sticker file-saving method.
  Future<void> saveAsSticker() async {
    final selectedImagePath = imagePath;

    if (selectedImagePath == null || isSavingSticker) return;

    setState(() {
      isSavingSticker = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final stickersDirectory = Directory(
        '${directory.path}/stickers',
      );

      await stickersDirectory.create(recursive: true);

      final fileName =
          'sticker_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(selectedImagePath).copy(
        '${stickersDirectory.path}/$fileName',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved as a sticker!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save sticker: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingSticker = false;
        });
      }
    }
  }

  void showFlowerResult(
    String? flowerName,
    String selectedImagePath,
  ) {
    final identifiedName = flowerName?.trim().isNotEmpty == true
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
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.55,
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    'Flower Identified!',
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    identifiedName,
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your flower has been identified successfully.',
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: isSavingSticker
                          ? null
                          : () {
                              Navigator.pop(sheetContext);
                              widget.onAddSticker(selectedImagePath);
                            },
                      icon: const Icon(Icons.sticky_note_2_outlined),
                      label: Text(
                        'Save as Sticker',
                        style: Theme.of(sheetContext).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlowerInformationPage(
                              flowerName: identifiedName,
                              scientificName: identifiedName,
                              description:
                                  'This flower was identified using '
                                  'the FlowerFinder scanner.',
                              flowerType: 'Flowering plant',
                              flowerColour: 'Not available',
                              season: 'Not available',
                              careTips:
                                  'Detailed care information is '
                                  'not currently available.',
                              imagePath: selectedImagePath,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View Flower Details',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        'Close',
                        style: Theme.of(sheetContext)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.darkGreen),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _preview() {
    // Gallery photos can be displayed even without a working camera.
    if (imagePath != null) {
      return Image.file(
        File(imagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
      );
    }

    final cameraController = controller;

    if (!cameraReady ||
        cameraController == null ||
        cameraController.value.previewSize == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final previewSize = cameraController.value.previewSize!;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(cameraController),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final whiteLabelStyle = labelStyle?.copyWith(color: Colors.white);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Saved Flowers',
            icon: const Icon(Icons.collections_bookmark_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedFlowersPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.cream,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(child: _preview()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                child: Column(
                  children: [
                    if (imagePath == null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: cameraReady && !isTakingPicture
                              ? takePicture
                              : null,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            isTakingPicture
                                ? 'Taking Photo...'
                                : 'Take Photo',
                            style: whiteLabelStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: isTakingPicture ? null : pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            'Upload Image',
                            style: labelStyle,
                          ),
                        ),
                      ),
                    ],
                    if (imagePath != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isIdentifying ? null : identifyFlower,
                          child: Text(
                            isIdentifying
                                ? 'Identifying...'
                                : 'Identify Flower',
                            style: whiteLabelStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed:
                              isIdentifying ? null : takeAnotherPhoto,
                          child: Text(
                            'Choose Another Photo',
                            style: labelStyle,
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