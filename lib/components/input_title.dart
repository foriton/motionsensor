import 'package:flutter/material.dart';

class InputTitle extends StatelessWidget {
  const InputTitle({
    Key? key,
    this.title = "",
    this.isRequired = false,
    this.padding,
    this.textFontSize = 15,
  }) : super(key: key);

  final String title;
  final bool isRequired;
  final double textFontSize;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      alignment: Alignment.centerLeft,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 1),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      height: 1.0,
                      fontSize: textFontSize,
                      color: const Color(0xFF686C73),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isRequired)
            Column(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF10000),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
        ],
      ),
    );
  }
}
