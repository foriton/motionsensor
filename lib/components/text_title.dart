import 'package:flutter/material.dart';

class TextTitle extends StatelessWidget {
  const TextTitle({
    Key? key,
    this.titleText = "",
    this.cellHeight = 32,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w600,
    this.fontColor = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  }) : super(key: key);

  final String titleText;
  final double cellHeight;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cellHeight,
      padding: padding,
      alignment: Alignment.centerLeft,
      child: Text(
        titleText,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.0,
          color: fontColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
