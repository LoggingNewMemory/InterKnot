import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebClientView extends StatefulWidget {
  final String url;
  final Function(InAppWebViewController) onWebViewCreated;

  const WebClientView({
    super.key,
    required this.url,
    required this.onWebViewCreated,
  });

  @override
  State<WebClientView> createState() => _WebClientViewState();
}

class _WebClientViewState extends State<WebClientView> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1.0)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                userAgent:
                    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                clearCache: false,
              ),
              android: AndroidInAppWebViewOptions(
                domStorageEnabled: true,
                databaseEnabled: true,
                useHybridComposition: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            gestureRecognizers: {
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
            },
            onWebViewCreated: (controller) {
              widget.onWebViewCreated(controller);
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  _progress = progress / 100;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
