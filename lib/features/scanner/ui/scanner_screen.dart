import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_scanner/core/constants/app_strings.dart';
import 'package:qr_scanner/features/scanner/data/scanner_repository.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_bloc.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_event.dart';
import 'package:qr_scanner/features/scanner/logic/scanner_state.dart';
import 'widgets/camera_view.dart';
import 'widgets/scanner_bottom_sheet.dart';

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
    final repository =
        context.read<ScannerBloc>().repository as ScannerRepository;

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ScannerBloc, ScannerState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraView(
                      controller: repository.controller,
                      onDetect: (capture) {
                        context.read<ScannerBloc>().add(QrDetected(capture));
                      },
                    ),
                    if (state is ScannerQrFound)
                      Center(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 56,
                              vertical: 32,
                            ),
                            textStyle: const TextStyle(fontSize: 26),
                            iconSize: 40,
                          ),
                          onPressed: () => context
                              .read<ScannerBloc>()
                              .add(const ScannerResumed()),
                          icon: const Icon(Icons.cameraswitch_outlined),
                          label: const Text(AppStrings.scanAgainButtonLabel),
                        ),
                      ),
                  ],
                ),
              ),
              ScannerBottomSheet(state: state),
            ],
          );
        },
      ),
    );
  }
}
