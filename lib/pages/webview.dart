import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:venera/components/components.dart';
import 'package:venera/utils/translations.dart';
import 'dart:io' as io;

export 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show WebUri, URLRequest;

extension WebviewExtension on InAppWebViewController {
  Future<List<io.Cookie>?> getCookies(String url) async {
    if (url.contains("https://")) {
      url.replaceAll("https://", "");
    }
    if (url[url.length - 1] == '/') {
      url = url.substring(0, url.length - 1);
    }
    CookieManager cookieManager = CookieManager.instance();
    final cookies = await cookieManager.getCookies(
      url: WebUri(url),
      webViewController: this,
    );
    var res = <io.Cookie>[];
    for (var cookie in cookies) {
      var c = io.Cookie(cookie.name, cookie.value);
      c.domain = cookie.domain;
      res.add(c);
    }
    return res;
  }

  Future<String?> getUA() async {
    var res = await evaluateJavascript(source: "navigator.userAgent");
    if (res is String) {
      if (res[0] == "'" || res[0] == "\"") {
        res = res.substring(1, res.length - 1);
      }
    }
    return res is String ? res : null;
  }
}

class AppWebview extends StatefulWidget {
  const AppWebview(
      {required this.initialUrl,
      this.onTitleChange,
      this.onNavigation,
      this.singlePage = false,
      this.onStarted,
      this.onLoadStop,
      super.key});

  final String initialUrl;

  final void Function(String title, InAppWebViewController controller)?
      onTitleChange;

  final bool Function(String url, InAppWebViewController controller)?
      onNavigation;

  final void Function(InAppWebViewController controller)? onStarted;

  final void Function(InAppWebViewController controller)? onLoadStop;

  final bool singlePage;

  @override
  State<AppWebview> createState() => _AppWebviewState();
}

class _AppWebviewState extends State<AppWebview> {
  InAppWebViewController? controller;

  String title = "Webview";

  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final actions = [
      Tooltip(
        message: "More",
        child: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            final mediaQuery = MediaQuery.of(context);
            showMenuX(
              context,
              Offset(mediaQuery.size.width, mediaQuery.padding.top),
              [
                MenuEntry(
                  icon: Icons.open_in_browser,
                  text: "Open in browser".tl,
                  onClick: () async =>
                      launchUrlString((await controller?.getUrl())!.toString()),
                ),
                MenuEntry(
                  icon: Icons.copy,
                  text: "Copy link".tl,
                  onClick: () async => Clipboard.setData(ClipboardData(
                      text: (await controller?.getUrl())!.toString())),
                ),
                MenuEntry(
                  icon: Icons.refresh,
                  text: "Reload".tl,
                  onClick: () => controller?.reload(),
                ),
              ],
            );
          },
        ),
      )
    ];

    Widget body = Stack(
      children: [
        Positioned.fill(
          child: InAppWebView(
            initialSettings: InAppWebViewSettings(
              isInspectable: true,
            ),
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            onTitleChanged: (c, t) {
              if (mounted) {
                setState(() {
                  title = t ?? "Webview";
                });
              }
              widget.onTitleChange?.call(title, controller!);
            },
            shouldOverrideUrlLoading: (c, r) async {
              var res = widget.onNavigation
                      ?.call(r.request.url?.toString() ?? "", c) ??
                  false;
              if (res) {
                return NavigationActionPolicy.CANCEL;
              } else {
                return NavigationActionPolicy.ALLOW;
              }
            },
            onWebViewCreated: (c) {
              controller = c;
              widget.onStarted?.call(c);
            },
            onLoadStop: (c, r) {
              widget.onLoadStop?.call(c);
            },
            onProgressChanged: (c, p) {
              if (mounted) {
                setState(() {
                  _progress = p / 100;
                });
              }
            },
          ),
        ),
        if (_progress < 1.0)
          const Positioned.fill(
              child: Center(child: CircularProgressIndicator()))
      ],
    );

    return Scaffold(
        appBar: Appbar(
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: actions,
        ),
        body: body);
  }
}
