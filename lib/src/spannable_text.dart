import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:rich_text_editor/diff_patch_match/DiffMatchPatch.dart';

import 'spannable_list.dart';
import 'spannable_style.dart';

typedef SetStyleCallback = SpannableStyle Function(SpannableStyle style);

class SpannableTextEditingController extends TextEditingController {
  static const historyMaxLength = 5;

  SpannableList currentStyleList;
  SpannableStyle currentComposingStyle;

  Queue<ControllerHistory> _histories = Queue();
  Queue<ControllerHistory> _undoHistories = Queue();

  bool _updatedByHistory = false;

  SpannableTextEditingController({
    String text = '',
    SpannableList styleList,
    SpannableStyle composingStyle,
  }) : super(text: text) {
    currentStyleList = styleList ?? SpannableList.generate(text.length);
    currentComposingStyle = composingStyle ?? SpannableStyle();
  }

  @override
  set value(TextEditingValue newValue) {
    if (value.text != newValue.text) {
      if (!_updatedByHistory) {
        _updateHistories(_histories);
        _undoHistories.clear();
        _updateList(value.text, newValue.text);
      }
      _updatedByHistory = false;
    }
    super.value = newValue;
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    return currentStyleList.toTextSpan(text, defaultStyle: style);
  }

  SpannableStyle get composingStyle => currentComposingStyle.copy();

  set composingStyle(SpannableStyle newComposingStyle) {
    currentComposingStyle = newComposingStyle;
    notifyListeners();
  }

  void setSelectionStyle(SetStyleCallback callback) {
    if (selection.isValid && selection.isNormalized) {
      _updateHistories(_histories);
      for (var offset = selection.start; offset < selection.end; offset++) {
        currentStyleList.modify(offset, callback);
      }
      notifyListeners();
    }
  }

  SpannableStyle getSelectionStyle() {
    if (selection.isValid && selection.isNormalized) {
      SpannableStyle style = SpannableStyle();
      for (var offset = selection.start; offset < selection.end; offset++) {
        final current = currentStyleList.index(offset);
        style.setStyle(style.style | current.style);
        style.clearForegroundColor();
        style.clearBackgroundColor();
      }
      return style;
    }
    return null;
  }

  void clearComposingStyle() {
    currentComposingStyle = SpannableStyle();
  }

  bool canUndo() => _histories.isNotEmpty;

  void undo() {
    assert(canUndo());
    _updateHistories(_undoHistories);
    _applyHistory(_histories.removeLast());
  }

  bool canRedo() => _undoHistories.isNotEmpty;

  void redo() {
    assert(canRedo());
    _updateHistories(_histories);
    _applyHistory(_undoHistories.removeLast());
  }

  void _applyHistory(ControllerHistory history) {
    _updatedByHistory = true;
    currentStyleList = history.styleList;
    value = history.value;
  }

  void _updateHistories(Queue<ControllerHistory> histories) {
    if (histories.length == historyMaxLength) {
      histories.removeFirst();
    }
    histories.add(ControllerHistory(
      value: value,
      styleList: currentStyleList.copy(),
    ));
  }

  void _updateList(String oldText, String newText) {
    var textChange = _calculateTextChange(oldText, newText);
    if (textChange != null) {
      var style;
      if (textChange.operation == Operation.insert) {
        style = (composingStyle ?? SpannableStyle()).copy();
      }

      for (var index = 0; index < textChange.length; index++) {
        if (textChange.operation == Operation.insert) {
          currentStyleList.insert(textChange.offset + index, style);
        } else if (textChange.operation == Operation.delete) {
          currentStyleList.delete(textChange.offset);
        }
      }
    }
  }

  _TextChange _calculateTextChange(String oldText, String newText) {
    if (oldText == null) {
      return null;
    }

    var dmp = DiffMatchPatch();
    var diffList = dmp.diff_main(oldText, newText);
    var operation, length;
    var offset = 0;
    for (var index = 0; index < diffList.length; index++) {
      final diff = diffList[index];
      if (diff.operation == Operation.equal) {
        offset += diff.text.length;
      } else if (diff.operation == Operation.insert) {
        if (index + 1 < diffList.length) {
          final nextDiff = diffList[index + 1];
          if (nextDiff.operation == Operation.delete) {
            if (nextDiff.text.length == diff.text.length) break;
            if (nextDiff.text.length < diff.text.length) {
              operation = Operation.delete;
              length = diff.text.length - nextDiff.text.length;
              break;
            }
          }
        }
        operation = Operation.insert;
        length = diff.text.length;
        break;
      } else if (diff.operation == Operation.delete) {
        if (index + 1 < diffList.length) {
          final nextDiff = diffList[index + 1];

          if (nextDiff.operation == Operation.insert) {
            if (nextDiff.text.length == diff.text.length) break;
            if (nextDiff.text.length > diff.text.length) {
              offset++;
              operation = Operation.insert;
              length = nextDiff.text.length - diff.text.length;
              break;
            }
          }
        }
        operation = Operation.delete;
        length = diff.text.length;
        break;
      }
    }

    if (operation != null) {
      return _TextChange(operation, offset, length);
    } else {
      return null;
    }
  }
}

@immutable
class ControllerHistory {
  final TextEditingValue value;
  final SpannableList styleList;

  ControllerHistory({
    this.value,
    this.styleList,
  });

  @override
  String toString() {
    return '_ControllerHistory(text: ${value.text}, styleList: $styleList)';
  }
}

@immutable
class _TextChange {
  final Operation operation;
  final int offset;
  final int length;

  _TextChange(this.operation, this.offset, this.length);

  @override
  String toString() {
    return '$runtimeType(operation: $operation, offset: $offset, length: $length)';
  }
}
