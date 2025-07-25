// guide_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  InAppWebViewController? webViewController;
  double progress = 0;
  final String guideUrl = 'https://interknot-network.com/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('ZZZ Guide'),
        backgroundColor: Colors.grey[900],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(guideUrl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
              ),
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onProgressChanged: (controller, p) {
              setState(() => progress = p / 100);
            },
          ),
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
