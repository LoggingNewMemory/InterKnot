import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

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
  InAppWebViewController? _webViewController;

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
            initialSettings: InAppWebViewSettings(
              // Use a modern desktop user agent
              userAgent:
                  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
              javaScriptEnabled: true,
              // Allows media (like voice notes) to play automatically
              mediaPlaybackRequiresUserGesture: false,
              // Keep cache enabled to stay logged in
              cacheEnabled: true,
              // Allow file access, useful for uploads
              allowFileAccess: true,
              // Enable DOM storage for session data
              domStorageEnabled: true,
              // Camera/microphone permissions are now handled by the onPermissionRequest callback
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
              _webViewController = controller;
              widget.onWebViewCreated(controller);
            },
            onProgressChanged: (controller, progress) {
              if (mounted) {
                setState(() {
                  _progress = progress / 100;
                });
              }
            },
            // This is crucial for granting camera/microphone permissions to the webpage
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            // This handles file downloads initiated by the webpage
            onDownloadStartRequest: (controller, downloadStartRequest) async {
              final directory = await getExternalStorageDirectory();
              if (directory != null) {
                await FlutterDownloader.enqueue(
                  url: downloadStartRequest.url.toString(),
                  savedDir: directory.path,
                  showNotification: true,
                  openFileFromNotification: true,
                  saveInPublicStorage: true,
                );
              }
            },
            // Handle JavaScript alerts to prevent the app from freezing
            onJsAlert: (controller, jsAlertRequest) async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(jsAlertRequest.message ?? ''),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
              return JsAlertResponse(handledByClient: true);
            },
          ),
        ),
      ],
    );
  }
}
