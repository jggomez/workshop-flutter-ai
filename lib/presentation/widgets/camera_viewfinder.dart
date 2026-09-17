import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 4:5 Viewfinder component for attendee photo capture and preview.
class CameraViewfinder extends StatelessWidget {
  final Uint8List? photoBytes;
  final VoidCallback onCapturePressed;
  final VoidCallback onUploadPressed;
  final VoidCallback onRetakePressed;
  final bool isLoading;

  const CameraViewfinder({
    super.key,
    required this.photoBytes,
    required this.onCapturePressed,
    required this.onUploadPressed,
    required this.onRetakePressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: photoBytes != null
                ? AppColors.dashCyan
                : AppColors.borderSubtle,
            width: 2,
          ),
          boxShadow: [
            if (photoBytes != null)
              BoxShadow(
                color: AppColors.dashCyan.withValues(alpha: 0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Image or Placeholder
            if (photoBytes != null)
              Positioned.fill(
                child: Image.memory(
                  photoBytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceCard,
                    child: const Center(
                      child: Icon(Icons.person,
                          size: 64, color: AppColors.dashCyan),
                    ),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF131C2E), AppColors.surfaceDark],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.dashCyan.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.dashCyan.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 36,
                          color: AppColors.dashCyan,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Sonríe para tu Dash Credencial!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Captura con tu cámara o sube una imagen',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Subtle Viewfinder Corner Guides (only shown when waiting for capture)
            if (photoBytes == null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: CustomPaint(
                    painter: _ViewfinderCornersPainter(),
                  ),
                ),
              ),

            // Bottom Action Bar inside Viewfinder
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: photoBytes != null
                  ? ElevatedButton.icon(
                      onPressed: isLoading ? null : onRetakePressed,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Tomar otra foto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.surfaceDark.withValues(alpha: 0.85),
                        foregroundColor: AppColors.dashCyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.dashCyan),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : onCapturePressed,
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.flutterBlue,
                              foregroundColor: AppColors.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : onUploadPressed,
                            icon: const Icon(Icons.upload_file, size: 20),
                            label: const Text('Subir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dashCyan,
                              side: const BorderSide(
                                  color: AppColors.dashCyan, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw 4 corner brackets typical of camera viewfinders.
class _ViewfinderCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.dashCyan.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
