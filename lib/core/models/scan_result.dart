import 'package:equatable/equatable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResult extends Equatable {
  const ScanResult({
    required this.rawValue,
    required this.scannedAt,
    this.format = BarcodeFormat.qrCode,
  });

  final String rawValue;
  final DateTime scannedAt;
  final BarcodeFormat format;

  ScanResult copyWith({
    String? rawValue,
    DateTime? scannedAt,
    BarcodeFormat? format,
  }) {
    return ScanResult(
      rawValue: rawValue ?? this.rawValue,
      scannedAt: scannedAt ?? this.scannedAt,
      format: format ?? this.format,
    );
  }

  @override
  List<Object?> get props => [rawValue, scannedAt, format];
}
