import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ARScreen extends StatefulWidget {
  @override
  _ARScreenState createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // For Android platform view.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/ar_experience.html'); // For local HTML file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Experience'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
