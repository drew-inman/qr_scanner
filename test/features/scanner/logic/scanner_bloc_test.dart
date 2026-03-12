import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/features/scanner/data/scanner_repository_interface.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_bloc.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_event.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';

class MockIScannerRepository extends Mock implements IScannerRepository {}

class MockMobileScannerController extends Mock
    implements MobileScannerController {}

void main() {
  late MockIScannerRepository repository;
  late StreamController<BarcodeCapture> streamController;

  setUp(() {
    repository = MockIScannerRepository();
    streamController = StreamController<BarcodeCapture>.broadcast();

    when(() => repository.barcodeStream).thenAnswer(
      (_) => streamController.stream,
    );
    when(() => repository.startScanning()).thenAnswer((_) async {});
    when(() => repository.pauseScanning()).thenAnswer((_) async {});
    when(() => repository.resumeScanning()).thenAnswer((_) async {});
    when(() => repository.dispose()).thenAnswer((_) async {});
    when(() => repository.controller).thenReturn(MockMobileScannerController());
  });

  tearDown(() async {
    await streamController.close();
  });

  group('ScannerBloc', () {
    blocTest<ScannerBloc, ScannerState>(
      'emits [ScannerScanning] when ScannerStarted succeeds',
      build: () => ScannerBloc(repository: repository),
      act: (bloc) => bloc.add(const ScannerStarted()),
      expect: () => [const ScannerScanning()],
    );

    blocTest<ScannerBloc, ScannerState>(
      'emits [ScannerError] when startScanning throws',
      build: () {
        when(() => repository.startScanning())
            .thenThrow(Exception('permission denied'));
        return ScannerBloc(repository: repository);
      },
      act: (bloc) => bloc.add(const ScannerStarted()),
      expect: () => [
        isA<ScannerError>(),
      ],
    );

    blocTest<ScannerBloc, ScannerState>(
      'emits [ScannerScanning, ScannerQrFound] when valid QR detected',
      build: () => ScannerBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const ScannerStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          QrDetected(
            BarcodeCapture(
              barcodes: [
                const Barcode(
                  rawValue: 'https://example.com',
                  format: BarcodeFormat.qrCode,
                ),
              ],
            ),
          ),
        );
      },
      expect: () => [
        const ScannerScanning(),
        isA<ScannerQrFound>().having(
          (s) => s.result.rawValue,
          'rawValue',
          'https://example.com',
        ),
      ],
    );

    blocTest<ScannerBloc, ScannerState>(
      'emits [ScannerInitial] when ScannerStopped',
      build: () => ScannerBloc(repository: repository),
      seed: () => const ScannerScanning(),
      act: (bloc) => bloc.add(const ScannerStopped()),
      expect: () => [const ScannerInitial()],
    );
  });
}
