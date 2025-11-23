import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsWebViewScreen extends StatefulWidget {
  final NewsItem news;

  const NewsWebViewScreen({super.key, required this.news});

  @override
  State<NewsWebViewScreen> createState() => _NewsWebViewScreenState();
}

class _NewsWebViewScreenState extends State<NewsWebViewScreen> {
  late final WebViewController _controller;
  var _loadingPercentage = 0;

  // Track if the refresh was triggered by the user
  bool _isManualReload = false;

  void _clearMemory() {
    _controller.clearCache();
    _controller.loadRequest(Uri.parse('about:blank'));
    Navigator.pop(context);
    // Removed super.dispose() - Flutter calls this automatically
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
          // Double check to ensure animation stops
          if (mounted) {
            setState(() => _isManualReload = false);
          }
        },
      ),
    );
    _controller.loadRequest(Uri.parse(widget.news.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _clearMemory,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.news.source),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              // Trigger animation and reload
              setState(() => _isManualReload = true);
              _controller.reload();
            },
            // Conditional Rendering:
            // If manual reload is active, animate the icon.
            // If not, show the static icon.
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
              color: secondaryShade, // Ensure this var exists in util.dart
              value: _loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
