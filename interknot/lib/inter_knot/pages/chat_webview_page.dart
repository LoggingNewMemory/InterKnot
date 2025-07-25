// chat_webview_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ChatWebviewPage extends StatefulWidget {
  @override
  _ChatWebviewPageState createState() => _ChatWebviewPageState();
}

class _ChatWebviewPageState extends State<ChatWebviewPage> {
  final List<Map<String, String>> chats = [
    {'title': 'Telegram', 'url': 'https://web.telegram.org/'},
    {'title': 'WhatsApp', 'url': 'https://web.whatsapp.com/'},
    {'title': 'WhatsApp Business', 'url': 'https://web.whatsapp.com/'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: chats.length,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Web Chat'),
          backgroundColor: Colors.grey[900],
          bottom: TabBar(
            tabs: chats.map((e) => Tab(text: e['title'])).toList(),
          ),
        ),
        body: TabBarView(
          children: chats
              .map((e) => InAppWebViewWidget(url: e['url']!))
              .toList(),
        ),
      ),
    );
  }
}

class InAppWebViewWidget extends StatefulWidget {
  final String url;
  InAppWebViewWidget({required this.url});

  @override
  _InAppWebViewWidgetState createState() => _InAppWebViewWidgetState();
}

class _InAppWebViewWidgetState extends State<InAppWebViewWidget> {
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
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
    );
  }
}
