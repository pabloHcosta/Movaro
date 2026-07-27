import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

/// Renders a widget off-screen, captures it as a PNG and opens the OS share
/// sheet with the image attached. Web-safe: uses [XFile.fromData] (no dart:io).
class ShareCardService {
  const ShareCardService._();

  static Future<void> shareWidget({
    required BuildContext context,
    required Widget card,
    required Size logicalSize,
    required String caption,
    String fileName = 'movaro_card.png',
    double pixelRatio = 3.0,
  }) async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final boundaryKey = GlobalKey();

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        // Off-screen but still laid out and painted, so it can be captured.
        left: -10000,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: boundaryKey,
            child: SizedBox(
              width: logicalSize.width,
              height: logicalSize.height,
              child: card,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    try {
      // Give the off-screen subtree a chance to lay out and paint.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await WidgetsBinding.instance.endOfFrame;

      final renderObject = boundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return;
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return;
      }
      final bytes = byteData.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: fileName, mimeType: 'image/png')],
          text: caption,
        ),
      );
    } finally {
      entry.remove();
    }
  }
}
