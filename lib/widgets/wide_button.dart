import 'package:flutter/material.dart';

class OutlineBorderButton extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double? height;
  final double? width;
  final double? borderWidth;
  final double radius;
  final double? fontSize;
  final Color? textColor;
  final Color borderColor;
  final Color? backgroundColor;
  final ButtonTextTheme? textTheme;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle textStyle;

  const OutlineBorderButton({
    super.key,
    required this.title,
    required this.textStyle,
    this.onPressed,
    this.height,
    this.width,
    this.fontSize,
    required this.radius,
    this.textColor,
    required this.borderColor,
    this.onLongPress,
    this.textTheme,
    this.backgroundColor,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius?? BorderRadius.circular(10),
          ),
          backgroundColor:
          backgroundColor,
          side: BorderSide(
              color: borderColor),
        ),
        onPressed: onPressed,
        child: Text(
          title.toString(),
          style: textStyle,
        ),
      ),
    );
  }
}