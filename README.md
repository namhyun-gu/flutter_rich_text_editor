# flutter_rich_text_editor

Rich text editor for flutter

## Requirements

Must be use flutter **v1.8.3** or later, Dart 2.2.2 or later

## Using

* Import library 

```dart
import 'package:rich_text_editor/rich_text_editor.dart';
```

* Initialize controller

> SpannableTextEditingController is extends TextEditingController. Therefore you can use TextEditingController interfaces.

```dart
SpannableTextEditingController _controller = SpannableTextEditingController();

// Initialize with saved text (No style applied)
SpannableTextEditingController _controller = SpannableTextEditingController(
  text: "Hello",
);

// Initialize with saved text and style
String savedStyleJson;
SpannableList styleList = SpannableList.fromJson(savedStyleJson); 

SpannableTextEditingController _controller = SpannableTextEditingController(
  text: "Hello",
  styleList: styleList
);
```

* Add controller to TextField

```dart
TextField(
  controller: _controller,
  keyboardType: TextInputType.multiline,
  maxLines: null,
  decoration: InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    filled: false,
  ),
)
```

* Control Selection style

```dart
// Set selection style
_controller.setSelectionStyle((currentStyle) {
  var newStyle = currentStyle;
  // Set bold
  newStyle.setStyle(styleBold);
  return newStyle;
});

// Get selection style
SpannbleStyle style = _controller.getSelectionStyle();
```

> Can use predefined StyleToolbar widget

```dart
StyleToolbar(
  controller: _controller,
),
```

* Save style list

> Currently not support standard rich text format. can use json type list only.

```dart
_controller.currentStyleList.toJson()
```

* Use style list to RichText widget

```dart
String text;
SpannableList list;
TextStyle defaultStyle;

RichText(
  text: list.toTextSpan(text, defaultStyle: defaultStyle),
);
```

* Use SpannableStyle

> Current support styles : styleBold, styleItalic, styleUnderline, styleLineThrough

```dart
var style = SpannableStyle();

style.setStyle(styleBold);
style.hasStyle(styleBold); // true
style.clearStyle(styleBold);
style.hasStyle(styleBold); // false
```