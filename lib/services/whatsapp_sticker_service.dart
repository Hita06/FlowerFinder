import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WhatsAppStickerService {
  /// Shares one Flower Finder sticker using the phone's share menu.
  Future<void> shareSticker({
    required Uint8List stickerBytes,
    String? stickerId,
  }) async {
    if (stickerBytes.isEmpty) {
      throw Exception('Sticker could not be shared.');
    }

    final directory = await getTemporaryDirectory();

    final fileName =
        'flower_finder_sticker_${stickerId ?? DateTime.now().millisecondsSinceEpoch}.png';

    final stickerFile = File(
      '${directory.path}/$fileName',
    );

    await stickerFile.writeAsBytes(stickerBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(stickerFile.path),
        ],
        text: 'Check out my Flower Finder sticker!',
      ),
    );
  }

  /// Checks whether there are enough stickers for a sticker pack.
  bool canCreateStickerPack(int stickerCount) {
    return stickerCount >= 3;
  }
}