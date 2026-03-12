import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';

class QrResultPanel extends StatelessWidget {
  const QrResultPanel({super.key, required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: switch (state) {
        ScannerQrFound(:final result) => _FilledState(rawValue: result.rawValue),
        _ => const _EmptyState(),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_scanner_outlined,
          size: 40,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.scanResultPlaceholder,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FilledState extends StatelessWidget {
  const _FilledState({required this.rawValue});

  final String rawValue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.scanResultLabel,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              rawValue,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
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
            label: const Text(AppStrings.copyButtonLabel),
          ),
        ),
      ],
    );
  }
}
