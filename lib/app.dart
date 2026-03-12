import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/features/scanner/data/scanner_repository.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_bloc.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_event.dart';
import 'package:qr_scanner/features/scanner/ui/scanner_screen.dart';

class QrScannerApp extends StatelessWidget {
  const QrScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00695C),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: BlocProvider<ScannerBloc>(
        create: (_) => ScannerBloc(repository: ScannerRepository())
          ..add(const ScannerStarted()),
        child: const ScannerScreen(),
      ),
    );
  }
}
