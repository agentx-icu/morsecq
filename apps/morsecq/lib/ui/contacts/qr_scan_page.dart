import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../chat/chat_strings.dart';
import 'tox_id.dart';

/// Full-screen camera scanner that pops with the first valid Tox ID it sees.
/// Only reachable on Android / iOS; the add-friend sheet disables the entry
/// point elsewhere (desktop has no `mobile_scanner` implementation).
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  static Future<String?> open(BuildContext context) => Navigator.of(
    context,
  ).push<String>(MaterialPageRoute<String>(builder: (_) => const QrScanPage()));

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  String? _hint;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final Barcode code in capture.barcodes) {
      final String id = normalizeToxId(code.rawValue ?? '');
      if (isValidToxId(id)) {
        _done = true;
        Navigator.of(context).pop(id);
        return;
      }
    }
    if (_hint == null && mounted) {
      setState(() => _hint = ChatStrings.scanQrNotToxId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ChatStrings.scanQrTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_hint != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 32,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_hint!, textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
