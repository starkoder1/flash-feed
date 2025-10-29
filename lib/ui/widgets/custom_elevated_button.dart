import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.txtColor,
    required this.btnHeight,
    required this.btnWidth,
    this.icon,
    this.btnColor = primaryShade,
    this.iconAlign = IconAlignment.end,
  });

  final String text;
  final void Function() onTap;
  final double btnHeight;
  final double btnWidth;
  final Widget? icon;
  final Color txtColor;
  final Color btnColor;
  final IconAlignment iconAlign;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: btnHeight,
      width: btnWidth,
      child: ElevatedButton.icon(
        iconAlignment: iconAlign,
        onPressed: onTap,
        label: Text(text, style: TextStyle(color: txtColor)),
        icon: icon ?? const SizedBox.shrink(),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(btnColor),
          elevation: WidgetStatePropertyAll(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}
