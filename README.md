# flutter_rich_text_editor

Rich text editor for flutter

## Requirements

Must be use flutter **v1.8.3** or later, Dart 2.2.2 or later

## Getting Started

* Add this lines to pubspec.yaml

```yaml
rich_text_editor:
  git:
    url: https://github.com/namhyun-gu/flutter_rich_text_editor
```

## Using

* Import library 

```dart
import 'package:rich_text_editor/rich_text_editor.dart';
```

* Initialize controller

> SpannableTextEditingController is extends TextEditingController. Therefore you can use TextEditingController interfaces.

```dart
SpannableTextEditingController controller = SpannableTextEditingController();

// Initialize with saved text (No style applied)
SpannableTextEditingController controller = SpannableTextEditingController(
  text: "Hello",
);

// Initialize with saved text and style
String savedStyleJson;
SpannableList styleList = SpannableList.fromJson(savedStyleJson); 

SpannableTextEditingController controller = SpannableTextEditingController(
  text: "Hello",
  styleList: styleList
);
```

* Add controller to TextField

```dart
TextField(
  controller: controller,
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
controller.setSelectionStyle((currentStyle) {
  var newStyle = currentStyle;
  // Set bold
  newStyle.setStyle(styleBold);
  return newStyle;
});

// Get selection style
SpannbleStyle style = controller.getSelectionStyle();
```

* Control composing style

```dart
var newStyle = controller.composingStyle;
// Set bold
newStyle.setStyle(styleBold);
controller.composingStyle = newStyle;
```

> Can use predefined StyleToolbar widget

```dart
StyleToolbar(
  controller: controller,
),
```

* Undo & Redo operation

```dart
// Undo
controller.canUndo();
controller.undo();

// Redo
controller.canRedo();
controller.redo();
```

* Save style list

> Currently not support standard rich text format. can use json type list only.

```dart
controller.currentStyleList.toJson()
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