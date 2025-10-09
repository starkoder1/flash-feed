import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.txtColor,
    this.hPadding = 150,
    this.vPadding = 10,
    this.icon,
  });

  final String text;
  final void Function() onTap;
  final double hPadding;
  final double vPadding;
  final Widget? icon;
  final Color txtColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      iconAlignment: IconAlignment.end,
      onPressed: onTap,
      label: Text(text, style: TextStyle(color: txtColor)),
      icon: icon ?? const SizedBox.shrink(),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF0864ED)),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
