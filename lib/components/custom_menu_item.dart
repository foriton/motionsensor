import 'package:flutter/material.dart';

class CustomMenuItem extends StatelessWidget {
  const CustomMenuItem({
    Key? key,
    required this.iconData,
    required this.title,
    required this.onPressed,
    this.imagePath,
    this.isSwitchItem = false,
    this.switchOnOff = false,
    this.isTextItem = false,
    this.textItemValue = "",
    this.textItemColor = const Color(0xFF898D93),
    this.isNoIcon = false,
  }) : super(key: key);

  final IconData iconData;
  final String title;
  final GestureTapCallback onPressed;
  final String? imagePath;
  final bool isSwitchItem;
  final bool switchOnOff;
  final bool isTextItem;
  final String textItemValue;
  final Color textItemColor;
  final bool isNoIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isNoIcon)
              (imagePath != null && imagePath!.isNotEmpty)
                  ? Image.asset(
                      imagePath!,
                      width: 24,
                      height: 24,
                    )
                  : Icon(iconData, color: const Color(0xFF686C73), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (isSwitchItem)
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  switchOnOff ? "assets/images/icons_switch_on.png" : "assets/images/icons_switch_off.png",
                  width: 46,
                  height: 28,
                ),
              )
            else if (isTextItem)
              Container(
                alignment: Alignment.center,
                child: Text(
                  textItemValue,
                  style: TextStyle(
                    fontSize: 15,
                    color: textItemColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            else
              Row(
                children: const [
                  SizedBox(width: 20),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF898D93),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
