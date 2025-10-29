import 'package:flutter/material.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsWebViewScreen extends StatefulWidget {
  final NewsItem news;

  const NewsWebViewScreen({super.key, required this.news});

  @override
  State<NewsWebViewScreen> createState() => _NewsWebViewScreenState();
}

class _NewsWebViewScreenState extends State<NewsWebViewScreen> {
  // A controller for the WebView, which we will initialize in initState.
  // 'late' means we promise to initialize it before we use it.
  late final WebViewController _controller;

  // A state variable to track the loading progress of the web page.
  var _loadingPercentage = 0;

  void _clearMemory() {
    _controller.clearCache(); // remove cached resources
    _controller.loadRequest(Uri.parse('about:blank')); // stop and unload page
    Navigator.pop(context);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController.
    _controller = WebViewController();

    // Set up the controller. Call methods separately to avoid chaining issues with Futures.
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        // Update the loading percentage as the page loads.
        onProgress: (progress) => setState(() => _loadingPercentage = progress),
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
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(widget.news.source),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          // Show a loading indicator while the page is loading.
          if (_loadingPercentage < 100)
            LinearProgressIndicator(
              // The value should be between 0.0 and 1.0.
              value: _loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
