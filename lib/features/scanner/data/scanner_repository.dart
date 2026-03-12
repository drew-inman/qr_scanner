import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'scanner_repository_interface.dart';

class ScannerRepository implements IScannerRepository {
  ScannerRepository() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
    _streamController = StreamController<BarcodeCapture>.broadcast();
  }

  late final MobileScannerController _controller;
  late final StreamController<BarcodeCapture> _streamController;

  @override
  MobileScannerController get controller => _controller;

  @override
  Stream<BarcodeCapture> get barcodeStream => _streamController.stream;

  void onBarcodeDetected(BarcodeCapture capture) {
    if (!_streamController.isClosed) {
      _streamController.add(capture);
    }
  }

  @override
  Future<void> startScanning() => _controller.start();

  @override
  Future<void> pauseScanning() => _controller.stop();

  @override
  Future<void> resumeScanning() => _controller.start();

  @override
  Future<void> dispose() async {
    await _streamController.close();
    await _controller.dispose();
  }
}
