import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController();

  bool _processing = false;
  bool _scannerPaused = false;
  String? _message;
  bool _error = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _scannerPaused) return;

    final raw = capture.barcodes.isEmpty
        ? null
        : capture.barcodes.first.rawValue?.trim();

    final visitorBloc = context.read<VisitorBloc>();
    final router = GoRouter.of(context);

    setState(() {
      _processing = true;
      _scannerPaused = true;
      _message = 'Verifying visitor QR code...';
      _error = false;
    });

    try {
      await _controller.stop();

      if (raw == null || raw.isEmpty) {
        _showResult(
          'This QR code does not contain a visitor ID.',
          isError: true,
        );
        return;
      }

      final visitor = await visitorBloc.lookupVisitor(raw);

      if (!mounted) return;

      if (visitor == null) {
        _showResult(
          'No visitor found for ID: $raw',
          isError: true,
        );
        return;
      }

      setState(() {
        _processing = false;
        _message = 'Visitor verified successfully.';
        _error = false;
      });

      await router.push(
        '/visitors/details',
        extra: visitor,
      );

      if (!mounted) return;

      setState(() {
        _message = 'Visitor verified. Ready to scan another visitor.';
        _error = false;
      });
    } catch (error) {
      if (!mounted) return;

      _showResult(
        'Unable to verify this QR code. Please check the API connection and try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  void _showResult(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    setState(() {
      _message = message;
      _error = isError;
      _processing = false;
    });
  }

  Future<void> _resumeScanning() async {
    if (_processing) return;

    try {
      await _controller.start();

      if (!mounted) return;

      setState(() {
        _scannerPaused = false;
        _message = null;
        _error = false;
      });
    } catch (error) {
      _showResult(
        'Unable to start the camera. Please check camera permissions.',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan visitor QR'),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: _processing ? null : () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_outlined),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _processing ? null : () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 5, 18, 18),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  Center(
                    child: Container(
                      width: 245,
                      height: 245,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primary,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.crop_free_rounded,
                          color: AppTheme.primary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  if (_processing)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 22,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _processing
                            ? 'Looking up visitor details...'
                            : 'Align the visitor QR code inside the frame',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _error
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: _error ? AppTheme.red : AppTheme.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _error ? AppTheme.red : AppTheme.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_scannerPaused && !_processing)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _resumeScanning,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan another visitor'),
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 25),
            child: Text(
              'QR codes must contain the exact visitor ID returned by the REST API.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
