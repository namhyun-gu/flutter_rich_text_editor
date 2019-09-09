import 'dart:convert';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'spannable_style.dart';

typedef ModifyCallback = SpannableStyle Function(SpannableStyle style);

class SpannableList {
  List<SpannableStyle> _list;

  List<SpannableStyle> get list => _list;

  SpannableList(List<SpannableStyle> list) : _list = list ?? <SpannableStyle>[];

  factory SpannableList.fromJson(String styleJson) {
    if (styleJson.isNotEmpty) {
      var list = json.decode(styleJson);
      var decodedList = list.map((e) => SpannableStyle(value: e)).toList();
      return SpannableList(decodedList.cast<SpannableStyle>());
    }
    return null;
  }

  SpannableList.generate(int length) {
    _list = List.filled(length, SpannableStyle(value: 0), growable: true);
  }

  void insert(int offset, SpannableStyle style) {
    _list.insert(offset, style);
  }

  void delete(int offset) => _list.removeAt(offset);

  SpannableStyle index(int offset) => _list[offset];

  void modify(int offset, ModifyCallback callback) =>
      _list[offset] = callback(index(offset));

  void concat(SpannableList anotherList) {
    _list.addAll(anotherList.list);
  }

  SpannableList copy() {
    return SpannableList(_list.map((e) => e.copy()).toList());
  }

  void clear() => _list.clear();

  int get length => _list.length;

  String toJson() {
    return json.encode(_list.map((style) => style.value).toList());
  }

  TextSpan toTextSpan(String text, {TextStyle defaultStyle}) {
    var children = <InlineSpan>[];
    if (length > 0) {
      var groupList = _getGroupList();
      groupList.forEach((group) {
        var childSpan = TextSpan(
          style: _buildStyle(group.style),
          text: text.substring(group.start, group.start + group.length),
        );
        children.add(childSpan);
      });
    }
    return TextSpan(
      style: defaultStyle,
      children: children,
    );
  }

  TextStyle _buildStyle(SpannableStyle style) {
    var decoration = TextDecoration.combine([
      if (style.hasStyle(styleUnderline)) TextDecoration.underline,
      if (style.hasStyle(styleLineThrough)) TextDecoration.lineThrough,
    ]);

    var foregroundColor;
    if (style.hasStyle(useForegroundColor)) {
      foregroundColor = getColorFromValue(style.foregroundColor);
    }

    var backgroundColor;
    if (style.hasStyle(useBackgroundColor)) {
      backgroundColor = getColorFromValue(style.backgroundColor);
    }

    return TextStyle(
      color: foregroundColor,
      backgroundColor: backgroundColor,
      fontWeight: style.hasStyle(styleBold) ? FontWeight.bold : null,
      fontStyle: style.hasStyle(styleItalic) ? FontStyle.italic : null,
      decoration: decoration,
    );
  }

  List<_SpannableStyleGroup> _getGroupList() {
    var groupList = List<_SpannableStyleGroup>();
    var temp;
    var start;
    for (var offset = 0; offset <= length; offset++) {
      if (offset == length) {
        groupList.add(_SpannableStyleGroup(
          style: temp,
          start: start,
          length: offset - start,
        ));
        break;
      }

      var element = index(offset);
      if (temp == null) {
        start = offset;
        temp = element;
      } else if (temp != element) {
        groupList.add(_SpannableStyleGroup(
          style: temp,
          start: start,
          length: offset - start,
        ));
        start = offset;
        temp = element;
      }
    }
    return groupList;
  }

  @override
  String toString() {
    return '$runtimeType(_list: $_list)';
  }
}

class _SpannableStyleGroup {
  final SpannableStyle style;
  final int start;
  final int length;

  _SpannableStyleGroup({
    this.style,
    this.start,
    this.length,
  });

  @override
  String toString() {
    return '$runtimeType(style: $style, start: $start, length: $length)';
  }
}
