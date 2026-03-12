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
    final barcodes = event.capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final raw = barcode.rawValue;
    if (raw == null || raw.isEmpty) return;

    final result = ScanResult(
      rawValue: raw,
      scannedAt: DateTime.now(),
      format: barcode.format,
    );
    emit(ScannerQrFound(result: result));
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
    emit(ScannerScanning(lastResult: lastResult));
  }

  Future<void> _onScannerResumed(
    ScannerResumed event,
    Emitter<ScannerState> emit,
  ) async {
    await _repository.resumeScanning();
    emit(const ScannerScanning());
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
