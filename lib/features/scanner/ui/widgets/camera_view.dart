import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';

class CameraView extends StatelessWidget {
  const CameraView({
    super.key,
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
        color: colorScheme.surfaceContainerLowest,
        child: MobileScanner(
          controller: controller,
          onDetect: onDetect,
          errorBuilder: (context, error, child) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.scanErrorPermissionDenied,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
          overlayBuilder: (context, constraints) {
            return Center(
              child: Container(
                width: constraints.maxWidth * 0.7,
                height: constraints.maxWidth * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
    );
  }
}


