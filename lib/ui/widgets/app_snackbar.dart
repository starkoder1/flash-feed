import 'package:flutter/material.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Widget? trailing, // This is your optional widget at the end
  Duration duration = const Duration(seconds: 3),
  Color? backgroundColor,
}) {
  // clear any existing snackbars so they don't stack up
  ScaffoldMessenger.of(context).clearSnackBars();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor ?? Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: duration,
      content: Container(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded ensures the text doesn't overflow if the trailing widget is big
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
            // Only show the trailing widget if it was provided
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      ),
    ),
  );
}
