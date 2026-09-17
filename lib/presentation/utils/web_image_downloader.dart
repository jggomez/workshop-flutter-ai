import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_html/html.dart' as html;

/// Utility to rasterize a [RepaintBoundary] into a PNG image and trigger
/// a direct download in the user's browser.
class WebImageDownloader {
  /// Captures the widget referenced by [boundaryKey] at [pixelRatio] resolution
  /// and triggers browser download as [fileName].
  static Future<Uint8List?> captureAndDownload({
    required GlobalKey boundaryKey,
    String fileName = 'cancun_dash_badge_2026.png',
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      }

      return pngBytes;
    } catch (e) {
      debugPrint('WebImageDownloader error: $e');
      return null;
    }
  }
}
