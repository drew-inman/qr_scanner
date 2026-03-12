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

/// Camera is active. [lastResult] is the most recent scan, null until first scan.
/// [history] contains all prior scans in reverse-chronological order.
final class ScannerScanning extends ScannerState {
  const ScannerScanning({this.lastResult, this.history = const []});

  final ScanResult? lastResult;
  final List<ScanResult> history;

  @override
  List<Object?> get props => [lastResult, history];
}

/// A QR code was successfully decoded.
/// [history] contains all scans that preceded [result], newest first.
final class ScannerQrFound extends ScannerState {
  const ScannerQrFound({required this.result, this.history = const []});

  final ScanResult result;
  final List<ScanResult> history;

  @override
  List<Object?> get props => [result, history];
}

/// An error occurred (e.g. permission denied, hardware failure).
final class ScannerError extends ScannerState {
  const ScannerError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
