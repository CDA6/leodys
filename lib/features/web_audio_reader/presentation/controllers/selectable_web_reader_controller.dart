import 'dart:ui';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../domain/entities/reader_config.dart';
import '../controllers/web_reader_controller.dart';

class SelectableWebReaderController {
  final WebReaderController readerController;

  InAppWebViewController? webController;
  String? selectedText;
  bool isDragging = false;
  Offset? dragStartPosition;
  Offset? dragCurrentPosition;

  SelectableWebReaderController({required this.readerController});

  /// Call when long press starts
  Future<void> handleLongPressStart(Offset position) async {
    dragStartPosition = position;
    dragCurrentPosition = null;
    isDragging = true;
    selectedText = null;

    await _startSelectionAtPosition(position);
  }

  /// Call when dragging
  Future<void> handleLongPressMoveUpdate(Offset position) async {
    if (!isDragging) return;
    dragCurrentPosition = position;
    await _updateSelectionToPosition(position);
  }

  /// Call when long press ends
  Future<void> handleLongPressEnd() async {
    isDragging = false;
    await getSelectedText();
  }

  Future<void> _startSelectionAtPosition(Offset position) async {
    if (webController == null) return;
    final script = """
      (function() {
        var x = ${position.dx};
        var y = ${position.dy};
        window.getSelection().removeAllRanges();
        var range;
        if (document.caretRangeFromPoint) {
          range = document.caretRangeFromPoint(x, y);
        } else if (document.caretPositionFromPoint) {
          var pos = document.caretPositionFromPoint(x, y);
          range = document.createRange();
          range.setStart(pos.offsetNode, pos.offset);
        }
        if (range) {
          window._selectionStartRange = range.cloneRange();
          var textNode = range.startContainer;
          if (textNode.nodeType === Node.TEXT_NODE) {
            var text = textNode.textContent;
            var offset = range.startOffset;
            var start = offset;
            while (start > 0 && /[\\wàâäéèêëïîôùûüÿæœçÀÂÄÉÈÊËÏÎÔÙÛÜŸÆŒÇ]/.test(text[start-1])) start--;
            range.setStart(textNode, start);
            window._selectionStartRange.setStart(textNode, start);
          }
          window.getSelection().addRange(range);
        }
      })();
    """;
    await webController!.evaluateJavascript(source: script);
  }

  Future<void> _updateSelectionToPosition(Offset position) async {
    if (webController == null || dragStartPosition == null) return;

    final script = """
      (function() {
        var x = ${position.dx};
        var y = ${position.dy};
        if (!window._selectionStartRange) return false;
        var endRange;
        if (document.caretRangeFromPoint) endRange = document.caretRangeFromPoint(x,y);
        else if (document.caretPositionFromPoint){
          var pos = document.caretPositionFromPoint(x,y);
          endRange = document.createRange();
          endRange.setStart(pos.offsetNode,pos.offset);
        }
        if (!endRange) return false;
        var selection = window.getSelection();
        selection.removeAllRanges();
        var newRange = document.createRange();
        try{
          var startNode = window._selectionStartRange.startContainer;
          var startOffset = window._selectionStartRange.startOffset;
          var endNode = endRange.startContainer;
          var endOffset = endRange.startOffset;
          var comparison = startNode.compareDocumentPosition(endNode);
          if(comparison & Node.DOCUMENT_POSITION_FOLLOWING || (startNode===endNode && startOffset<=endOffset)){
            newRange.setStart(startNode,startOffset);
            if(endNode.nodeType===Node.TEXT_NODE){
              var text=endNode.textContent;
              var end=endOffset;
              while(end<text.length && /[\\wàâäéèêëïîôùûüÿæœçÀÂÄÉÈÊËÏÎÔÙÛÜŸÆŒÇ]/.test(text[end])) end++;
              newRange.setEnd(endNode,end);
            }else newRange.setEnd(endNode,endOffset);
          } else {
            newRange.setEnd(startNode,startOffset);
            if(endNode.nodeType===Node.TEXT_NODE){
              var text=endNode.textContent;
              var start=endOffset;
              while(start>0 && /[\\wàâäéèêëïîôùûüÿæœçÀÂÄÉÈÊËÏÎÔÙÛÜŸÆŒÇ]/.test(text[start-1])) start--;
              newRange.setStart(endNode,start);
            } else newRange.setStart(endNode,endOffset);
          }
          selection.addRange(newRange);
          return true;
        }catch(e){ return false; }
      })();
    """;

    await webController!.evaluateJavascript(source: script);
  }

  /// Get the currently selected text
  Future<void> getSelectedText() async {
    if (webController == null) return;
    final result =
    await webController!.evaluateJavascript(source: "window.getSelection().toString();");
    final text = result?.toString().trim() ?? "";
    selectedText = text.isNotEmpty ? text : null;
  }

  Future<void> readSelectedText(ReaderConfig config) async {
    if (selectedText != null && selectedText!.isNotEmpty) {
      await readerController.readText(selectedText!, config);
      await clearSelection();
    }
  }

  Future<void> clearSelection() async {
    if (webController == null) return;
    await webController!.evaluateJavascript(source: """
      window.getSelection().removeAllRanges();
      delete window._selectionStartRange;
    """);
    selectedText = null;
    dragStartPosition = null;
    dragCurrentPosition = null;
    isDragging = false;
  }

  /// Initialize JS selection monitoring
  Future<void> startSelectionMonitoring() async {
    if (webController == null) return;
    await webController!.evaluateJavascript(source: """
      (function(){
        if(window._selectionChangeListener) document.removeEventListener('selectionchange',window._selectionChangeListener);
        window._selectionChangeListener=function(){
          clearTimeout(window._selectionTimeout);
          window._selectionTimeout=setTimeout(function(){
            var text=window.getSelection().toString().trim();
            if(text.length>0) window.flutter_inappwebview.callHandler('onSelectionChanged', text);
          },100);
        };
        document.addEventListener('selectionchange',window._selectionChangeListener);
      })();
    """);
  }
}
