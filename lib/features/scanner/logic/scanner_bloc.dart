import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/core/models/scan_result.dart';
import 'package:qr_scanner/features/scanner/data/scanner_repository_interface.dart';

import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc({required IScannerRepository repository})
      : _repository = repository,
        super(const ScannerInitial()) {
    on<ScannerStarted>(_onScannerStarted);
    on<QrDetected>(_onQrDetected);
    on<ScannerPaused>(_onScannerPaused);
    on<ScannerResumed>(_onScannerResumed);
    on<ScannerStopped>(_onScannerStopped);
  }

  final IScannerRepository _repository;
  StreamSubscription<BarcodeCapture>? _subscription;

  IScannerRepository get repository => _repository;

  Future<void> _onScannerStarted(
    ScannerStarted event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await _repository.startScanning();
      _subscription = _repository.barcodeStream.listen(
        (capture) => add(QrDetected(capture)),
      );
      emit(const ScannerScanning());
    } catch (e) {
      emit(ScannerError(message: e.toString()));
    }
  }

  Future<void> _onQrDetected(
    QrDetected event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is! ScannerScanning) return;
    final barcodes = event.capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Push the previous result into history before replacing it.
    final previousResult = switch (state) {
      ScannerQrFound(:final result) => result,
      ScannerScanning(:final lastResult) => lastResult,
      _ => null,
    };
    final previousHistory = switch (state) {
      ScannerQrFound(:final history) => history,
      ScannerScanning(:final history) => history,
      _ => const <ScanResult>[],
    };
    final newHistory = previousResult != null
        ? [previousResult, ...previousHistory]
        : previousHistory;

    final result = ScanResult(
      rawValue: raw,
      scannedAt: DateTime.now(),
      format: barcode.format,
    );
    // Include the new result in history immediately so it persists regardless
    // of whether the user taps "Scan again" or not.
    emit(ScannerQrFound(result: result, history: [result, ...newHistory]));
    // Pause immediately so the same code isn't detected repeatedly.
    await _repository.pauseScanning();
  }

  Future<void> _onScannerPaused(
    ScannerPaused event,
    Emitter<ScannerState> emit,
  ) async {
    await _repository.pauseScanning();
    final lastResult = switch (state) {
      ScannerScanning(:final lastResult) => lastResult,
      ScannerQrFound(:final result) => result,
      _ => null,
    };
    final history = switch (state) {
      ScannerScanning(:final history) => history,
      ScannerQrFound(:final history) => history,
      _ => const <ScanResult>[],
    };
    emit(ScannerScanning(lastResult: lastResult, history: history));
  }

  Future<void> _onScannerResumed(
    ScannerResumed event,
    Emitter<ScannerState> emit,
  ) async {
    await _repository.resumeScanning();
    // Clear the current result (show placeholder again) but preserve history.
    final history = switch (state) {
      ScannerQrFound(:final history) => history,
      ScannerScanning(:final history) => history,
      _ => const <ScanResult>[],
    };
    emit(ScannerScanning(history: history));
  }

  Future<void> _onScannerStopped(
    ScannerStopped event,
    Emitter<ScannerState> emit,
  ) async {
    await _subscription?.cancel();
    await _repository.dispose();
    emit(const ScannerInitial());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _repository.dispose();
    return super.close();
  }
}
