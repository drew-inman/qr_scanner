import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/core/models/scan_result.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';

class ScannerBottomSheet extends StatefulWidget {
  const ScannerBottomSheet({super.key, required this.state});

  final ScannerState state;

  @override
  State<ScannerBottomSheet> createState() => _ScannerBottomSheetState();
}

class _ScannerBottomSheetState extends State<ScannerBottomSheet> {
  bool _isExpanded = false;

  void _toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final currentResult = switch (widget.state) {
      ScannerQrFound(:final result) => result,
      ScannerScanning(:final lastResult) => lastResult,
      _ => null,
    };
    final history = switch (widget.state) {
      ScannerQrFound(:final history) => history,
      ScannerScanning(:final history) => history,
      _ => const <ScanResult>[],
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(72),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ColoredBox(
            color: colorScheme.surface.withAlpha(217),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DragHandle(onTap: _toggleExpanded),
                  _ResultHeader(result: currentResult),
                  if (_isExpanded && history.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Text(
                        AppStrings.historyLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.5,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, index) =>
                            _HistoryItem(result: history[index]),
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: colorScheme.outlineVariant.withAlpha(80),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: bottomPadding + 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withAlpha(80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

void _showQrPopup(BuildContext context, String data) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withAlpha(100),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: _QrCodePopup(data: data),
        ),
      );
    },
  );
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.result});

  final ScanResult? result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
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
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
      child: Column(
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
                  result!.rawValue,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result!.rawValue));
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
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: () => _showQrPopup(context, result!.rawValue),
                icon: const Icon(Icons.qr_code_outlined),
                tooltip: AppStrings.generateQrButtonLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 8, top: 4, bottom: 4),
      child: Row(
        children: [
          Text(
            _formatDateTime(result.scannedAt),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              result.rawValue,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.rawValue));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(AppStrings.copiedToClipboard),
                  backgroundColor: colorScheme.inverseSurface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_outlined),
            iconSize: 18,
            tooltip: AppStrings.copyButtonLabel,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () => _showQrPopup(context, result.rawValue),
            icon: const Icon(Icons.qr_code_outlined),
            iconSize: 18,
            tooltip: AppStrings.generateQrButtonLabel,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
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
        child: Container(
          padding: const EdgeInsets.all(20),
          color: colorScheme.surface,
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
                size: 350,
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
    );
  }
}

String _formatDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '${months[dt.month - 1]} ${dt.day} · $hour:$minute $period';
}
