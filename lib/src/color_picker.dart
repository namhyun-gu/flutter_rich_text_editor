import 'package:flutter/material.dart';

typedef ColorSelectCallback = void Function(Color);

class ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;

  const ColorPicker({
    Key key,
    @required this.colors,
    this.selectionColor,
    this.itemSize = 40,
  })  : assert(colors != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _ColorContainer(
            colors: colors,
            itemSize: itemSize,
            selectionColor: selectionColor,
            onColorSelected: (color) {
              Navigator.pop(context, ColorSelection(color));
            },
          ),
        ),
      ],
    );
  }
}

class _ColorContainer extends StatelessWidget {
  final List<Color> colors;
  final double itemSize;
  final Color selectionColor;
  final ColorSelectCallback onColorSelected;

  _ColorContainer({
    Key key,
    @required this.colors,
    this.selectionColor,
    this.itemSize,
    this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: colors
          .map((color) => _ColorButton(
                color: color,
                selected: color?.value == selectionColor?.value,
                onTap: () => onColorSelected(color),
              ))
          .toList(),
      maxCrossAxisExtent: itemSize,
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  const _ColorButton({
    Key key,
    @required this.color,
    this.onTap,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return Stack(
      children: <Widget>[
        Material(
          color: color ?? themeData.textTheme.body1.color,
          shape: CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: CircleBorder(),
          ),
        ),
        Visibility(
          visible: selected,
          child: Container(
            decoration: BoxDecoration(
              color: themeData.dividerColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              color: color != null
                  ? Colors.white
                  : themeData.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
            ),
          ),
        )
      ],
    );
  }
}

@immutable
class ColorSelection {
  final Color color;

  ColorSelection(this.color);

  @override
  String toString() {
    return '_ColorSelection(color: $color)';
  }
}
