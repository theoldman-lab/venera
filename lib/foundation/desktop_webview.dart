import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A desktop webview wrapper for Linux platform
/// This is a simplified implementation using flutter_inappwebview
class DesktopWebview {
  DesktopWebview({
    required this.initialUrl,
    this.onTitleChange,
    this.onNavigation,
    this.onClose,
  });

  final String initialUrl;
  final void Function(String title, DesktopWebview webview)? onTitleChange;
  final void Function(String url, DesktopWebview webview)? onNavigation;
  final void Function()? onClose;

  InAppWebViewController? _controller;
  String _title = '';
  String _currentUrl = '';
  bool _isOpen = false;

  /// Check if DesktopWebview is available
  /// Always returns true since we're using flutter_inappwebview
  static Future<bool> isAvailable() async => true;

  /// Open the webview in a new page
  Future<void> open() async {
    if (_isOpen) return;
    _isOpen = true;

    runApp(_DesktopWebviewPage(this));
  }

  /// Close the webview
  Future<void> close() async {
    if (!_isOpen) return;
    _isOpen = false;
    onClose?.call();
  }

  /// Get cookies from the webview
  Future<Map<String, String>> getCookies(String url) async {
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(url),
      webViewController: _controller,
    );
    var result = <String, String>{};
    for (var cookie in cookies) {
      result[cookie.name] = cookie.value;
    }
    return result;
  }

  /// Evaluate javascript
  Future<dynamic> evaluateJavascript(String script) async {
    return await _controller?.evaluateJavascript(source: script);
  }

  /// Get user agent via javascript
  Future<String?> get userAgent async {
    return await evaluateJavascript('navigator.userAgent');
  }

  /// Internal method to set controller
  void _setController(InAppWebViewController controller) {
    _controller = controller;
  }

  /// Internal method to update title
  void _updateTitle(String title) {
    _title = title;
    onTitleChange?.call(title, this);
  }

  /// Internal method to update url
  void _updateUrl(String url) {
    _currentUrl = url;
    onNavigation?.call(url, this);
  }
}

class _DesktopWebviewPage extends StatefulWidget {
  const _DesktopWebviewPage(this.webview);

  final DesktopWebview webview;

  @override
  State<_DesktopWebviewPage> createState() => _DesktopWebviewPageState();
}

class _DesktopWebviewPageState extends State<_DesktopWebviewPage> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.webview.close();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.webview._title.isEmpty ? 'Webview' : widget.webview._title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              widget.webview.close();
            },
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  isInspectable: true,
                ),
                initialUrlRequest: URLRequest(url: WebUri(widget.webview.initialUrl)),
                onTitleChanged: (controller, title) {
                  widget.webview._setController(controller);
                  widget.webview._updateTitle(title ?? '');
                },
                shouldOverrideUrlLoading: (controller, request) async {
                  final url = request.request.url?.toString() ?? '';
                  widget.webview._setController(controller);
                  widget.webview._updateUrl(url);
                  return NavigationActionPolicy.ALLOW;
                },
                onWebViewCreated: (controller) {
                  widget.webview._setController(controller);
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
              ),
            ),
            if (_progress < 1.0)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
