import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../domain/entities/reader_config.dart';
import '../controllers/web_reader_controller.dart';
import '../controllers/selectable_web_reader_controller.dart';

class SelectableWebReaderScreen extends StatefulWidget {
  final WebReaderController controller;
  final ReaderConfig config;
  final String url;
  static final String route = "/selectable-web-reader";

  const SelectableWebReaderScreen({
    super.key,
    required this.controller,
    required this.config,
    required this.url,
  });

  @override
  State<SelectableWebReaderScreen> createState() =>
      _SelectableWebReaderScreenState();
}

class _SelectableWebReaderScreenState extends State<SelectableWebReaderScreen> {
  late SelectableWebReaderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectableWebReaderController(readerController: widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner du texte à lire"),
        actions: [
          if (_controller.selectedText != null)
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => _controller.readSelectedText(widget.config),
            ),
          if (_controller.selectedText != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _controller.clearSelection(),
            ),
        ],
      ),
      body: GestureDetector(
        onLongPressStart: (details) =>
            _controller.handleLongPressStart(details.localPosition),
        onLongPressMoveUpdate: (details) =>
            _controller.handleLongPressMoveUpdate(details.localPosition),
        onLongPressEnd: (_) => _controller.handleLongPressEnd(),
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                disableContextMenu: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
              ),
              onWebViewCreated: (controller) {
                _controller.webController = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'onSelectionChanged',
                  callback: (args) {
                    if (args.isNotEmpty) {
                      final text = args[0].toString().trim();
                      if (mounted) setState(() => _controller.selectedText = text);
                    }
                  },
                );
              },
              onLoadStop: (controller, url) async {
                await controller.evaluateJavascript(source: """
                  (function() {
                    const style = document.createElement('style');
                    style.innerHTML = \`
                      * { -webkit-user-select: text !important; user-select: text !important; }
                      ::selection { background-color: #B3D9FF !important; color: #000 !important; }
                    \`;
                    document.head.appendChild(style);
                    document.addEventListener('contextmenu', e => e.preventDefault());
                  })();
                """);
                await _controller.startSelectionMonitoring();
              },
            ),
            if (_controller.isDragging &&
                _controller.dragStartPosition != null &&
                _controller.dragCurrentPosition != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.blue.withOpacity(0.9),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gesture, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Faites glisser pour sélectionner...',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _controller.selectedText != null
          ? FloatingActionButton.extended(
        onPressed: () => _controller.readSelectedText(widget.config),
        icon: const Icon(Icons.volume_up),
        label: Text(
            'Lire (${_controller.selectedText!.split(' ').length} mots)'),
      )
          : null,
    );
  }
}
