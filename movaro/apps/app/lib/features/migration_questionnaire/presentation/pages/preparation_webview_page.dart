import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PreparationWebViewPage extends StatefulWidget {
  const PreparationWebViewPage({
    required this.title,
    required this.uri,
    super.key,
  });

  final String title;
  final Uri uri;

  @override
  State<PreparationWebViewPage> createState() => _PreparationWebViewPageState();
}

class _PreparationWebViewPageState extends State<PreparationWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Spoof a standard mobile Chrome UA so CDN/WAF security layers
      // (e.g. Cloudflare on Claro, TIM, Vivo) don't reject the request.
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Pixel 7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (!mounted) {
              return;
            }
            setState(() => _progress = value);
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    0,
                  ),
                  child: AppGlassHeader(
                    title: widget.title,
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      18,
                      context.pageHorizontalPadding,
                      context.pageVerticalPadding,
                    ),
                    child: FrostedPanel(
                      padding: const EdgeInsets.all(0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          children: [
                            WebViewWidget(controller: _controller),
                            if (_progress < 100)
                              LinearProgressIndicator(
                                value: _progress / 100,
                                minHeight: 3,
                                color: AppColors.primary,
                                backgroundColor: Colors.transparent,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
