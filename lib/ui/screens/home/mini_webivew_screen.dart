import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MiniWebivewScreen extends StatefulWidget {
  final String url;
  final String title;

  const MiniWebivewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<MiniWebivewScreen> createState() => _SimpleWebViewScreenState();
}

class _SimpleWebViewScreenState extends State<MiniWebivewScreen> {
  late final WebViewController _controller;
  var _loadingPercentage = 0;

  // Track if the refresh was triggered by the user
  bool _isManualReload = false;

  void _clearMemory() {
    _controller.clearCache();
    _controller.loadRequest(Uri.parse('about:blank'));
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            _loadingPercentage = progress;
            // Stop animation when loading finishes
            if (progress == 100) {
              _isManualReload = false;
            }
          });
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _isManualReload = false);
          }
        },
      ),
    );
    // LOAD THE RAW URL
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _clearMemory,
          icon: const Icon(Icons.arrow_back),
        ),
        // SHOW THE RAW TITLE
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              setState(() => _isManualReload = true);
              _controller.reload();
            },
            // Your custom animation logic
            icon: _isManualReload
                ? const Icon(Icons.refresh)
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 1.seconds, curve: Curves.linear)
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(
              backgroundColor: const Color(0xFF092E79),
              color: secondaryShade,
              value: _loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}