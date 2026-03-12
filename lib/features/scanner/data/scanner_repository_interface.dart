import 'package:mobile_scanner/mobile_scanner.dart';

abstract interface class IScannerRepository {
  MobileScannerController get controller;

  Stream<BarcodeCapture> get barcodeStream;

  Future<void> startScanning();

  Future<void> pauseScanning();

  Future<void> resumeScanning();

  Future<void> dispose();
}
