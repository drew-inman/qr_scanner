import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';

class QrResultPanel extends StatelessWidget {
  const QrResultPanel({super.key, required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(217),
            ),
            child: switch (state) {
              ScannerQrFound(:final result) =>
                _FilledState(rawValue: result.rawValue),
              _ => const _EmptyState(),
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_scanner_outlined,
          size: 22,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Text(
          AppStrings.scanResultPlaceholder,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _FilledState extends StatelessWidget {
  const _FilledState({required this.rawValue});

  final String rawValue;

  void _showQrPopup(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            // Position above the result panel (~100px) plus its margin (16px) plus a gap (12px)
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: bottomPadding + 144,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: _QrCodePopup(data: rawValue),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.scanResultLabel,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                rawValue,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: rawValue));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(AppStrings.copiedToClipboard),
                    backgroundColor: colorScheme.inverseSurface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_outlined),
              tooltip: AppStrings.copyButtonLabel,
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => _showQrPopup(context),
              icon: const Icon(Icons.qr_code_outlined),
              tooltip: AppStrings.generateQrButtonLabel,
            ),
          ],
        ),
      ],
    );
  }
}

class _QrCodePopup extends StatelessWidget {
  const _QrCodePopup({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha(230),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.generateQrButtonLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                ),
                const SizedBox(height: 12),
                QrImageView(
                  data: data,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
