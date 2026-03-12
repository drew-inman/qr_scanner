import 'package:equatable/equatable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

sealed class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the screen initializes — starts the camera.
final class ScannerStarted extends ScannerEvent {
  const ScannerStarted();
}

/// Fired by CameraView's onDetect callback when a barcode is detected.
final class QrDetected extends ScannerEvent {
  const QrDetected(this.capture);

  final BarcodeCapture capture;

  @override
  List<Object?> get props => [capture];
}

/// Fired when the app goes to background.
final class ScannerPaused extends ScannerEvent {
  const ScannerPaused();
}

/// Fired when the app returns to foreground.
final class ScannerResumed extends ScannerEvent {
  const ScannerResumed();
}

/// Fired on screen dispose — releases camera resources.
final class ScannerStopped extends ScannerEvent {
  const ScannerStopped();
}
