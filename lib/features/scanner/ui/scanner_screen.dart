import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner/features/scanner/data/scanner_repository.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_bloc.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_event.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';

import 'widgets/camera_view.dart';
import 'widgets/qr_result_panel.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<ScannerBloc>().add(const ScannerStopped());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<ScannerBloc>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        bloc.add(const ScannerPaused());
      case AppLifecycleState.resumed:
        bloc.add(const ScannerResumed());
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final repository =
        context.read<ScannerBloc>().repository as ScannerRepository;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(AppStrings.appBarTitle),
        centerTitle: true,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                flex: 2,
                child: CameraView(
                  controller: repository.controller,
                  onDetect: (capture) {
                    context.read<ScannerBloc>().add(QrDetected(capture));
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: QrResultPanel(state: state),
              ),
            ],
          );
        },
      ),
    );
  }
}
