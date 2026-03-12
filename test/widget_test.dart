import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';
import 'package:qr_scanner/features/scanner/ui/widgets/qr_result_panel.dart';

void main() {
  group('QrResultPanel', () {
    testWidgets('shows placeholder in initial state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrResultPanel(state: ScannerInitial()),
          ),
        ),
      );

      expect(find.text(AppStrings.scanResultPlaceholder), findsOneWidget);
    });

    testWidgets('shows placeholder in scanning state with no result',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrResultPanel(state: ScannerScanning()),
          ),
        ),
      );

      expect(find.text(AppStrings.scanResultPlaceholder), findsOneWidget);
    });
  });
}
