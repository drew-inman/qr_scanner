import 'package:equatable/equatable.dart';

import 'package:qr_scanner/core/models/scan_result.dart';

sealed class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Camera not yet started.
final class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

/// Camera is active. [lastResult] is null until first successful scan.
final class ScannerScanning extends ScannerState {
  const ScannerScanning({this.lastResult});

  final ScanResult? lastResult;

  @override
  List<Object?> get props => [lastResult];
}

/// A QR code was successfully decoded.
final class ScannerQrFound extends ScannerState {
  const ScannerQrFound({required this.result});

  final ScanResult result;

  @override
  List<Object?> get props => [result];
}

/// An error occurred (e.g. permission denied, hardware failure).
final class ScannerError extends ScannerState {
  const ScannerError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
