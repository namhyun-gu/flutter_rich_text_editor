import 'dart:ui';

const styleNone = 0x0;
const styleBold = 0x1;
const styleItalic = 0x2;
const styleUnderline = 0x4;
const styleLineThrough = 0x8;
const styleLink = 0x10;

const useForegroundColor = 0x20;
const useBackgroundColor = 0x40;

const styleField = 0xFF;
const foregroundColorField = 0xFFFFFF << 8;
const backgroundColorField = 0xFFFFFF << 32;

const colorRed = 0xFF << 16;
const colorGreen = 0xFF << 8;
const colorBlue = 0xFF;

class SpannableStyle {
  int _value = 0;

  int get value => _value;

  SpannableStyle({int value = 0}) : _value = value;

  void setStyle(int style) => _value |= style;

  int get style => _value & styleField;

  bool hasStyle(int style) => (_value & style) == style;

  void clearStyle(int style) => _value &= ~style;

  void setForegroundColor(Color color) =>
      _value | ((color.value & ~(0xFF << 24)) << 8);

  int get foregroundColor => (_value & foregroundColorField) >> 8;

  void clearForegroundColor() => _value & ~foregroundColorField;

  void setBackgroundColor(Color color) =>
      _value | ((color.value & ~(0xFF << 24)) << 32);

  int get backgroundColor => (_value & backgroundColorField) >> 32;

  void clearBackgroundColor() => _value & ~backgroundColorField;

  SpannableStyle copy() => SpannableStyle(value: _value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpannableStyle &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return '$runtimeType(_value: $_value)';
  }
}

class SpannableStyleUtils {
  static int getColorRed(int value) => (value & colorRed) >> 16;

  static int getColorGreen(int value) => (value & colorGreen) >> 8;

  static int getColorBlue(int value) => value & colorBlue;
}

class SpannableStyleBuilder {
  SpannableStyle _style = SpannableStyle();

  SpannableStyleBuilder();

  SpannableStyleBuilder.fromStyle(this._style);

  SpannableStyleBuilder setStyle(int style) {
    _style.setStyle(style);
    return this;
  }

  SpannableStyleBuilder setForegroundColor(Color color) {
    _style.setStyle(useForegroundColor);
    _style.setForegroundColor(color);
    return this;
  }

  SpannableStyleBuilder setBackgroundColor(Color color) {
    _style.setStyle(useBackgroundColor);
    _style.setBackgroundColor(color);
    return this;
  }

  SpannableStyle build() => _style;
}
