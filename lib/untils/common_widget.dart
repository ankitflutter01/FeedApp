import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_color.dart';

void commonToast(String sms){
  Fluttertoast.showToast(
      msg: sms,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppColors.blackColorShade2,
      textColor: AppColors.whiteColorShade,
      fontSize: 16.0
  );
}

///Application Common Text
class CommonAppText extends StatelessWidget {
  final Color? color ;
  final Color? fontShadowColor;
  final Color? decorationColor;
  final double? fontSize;
  final double? decorationThickness;
  final double? height;
  final double? fontShadowBlurRadius;
  final double? letterSpacing;
  final String? text;
  final TextAlign? textAlignment;
  final FontWeight? fontWeight ;
  final int maxLine ;
  final TextDecoration? textDecoration;
  final TextOverflow? textOverflow;

  const CommonAppText(
      {
        this.text,
        this.color,
        this.fontShadowColor,
        this.decorationColor,
        this.fontSize,
        this.decorationThickness,
        this.height,
        this.fontShadowBlurRadius,
        this.letterSpacing = 0.2,
        this.textAlignment,
        this.fontWeight,
        this.maxLine = 2,
        this.textDecoration,
        this.textOverflow = TextOverflow.ellipsis,
        super.key,});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: maxLine,
      textAlign: textAlignment ?? TextAlign.start,
      overflow: textOverflow,
      style: TextStyle(
          shadows: [
            Shadow(
              blurRadius: fontShadowBlurRadius ?? 0,  // shadow blur
              color: fontShadowColor ?? Colors.transparent, // shadow color
              offset: const Offset(2.0,2.0), // how much shadow will be shown
            ),
          ],
          letterSpacing: letterSpacing ?? 0,
          color:  color ?? AppColors.blackColorShade2,
          fontSize: fontSize,
          height: height,
          decoration: textDecoration ?? TextDecoration.none,
          decorationThickness: decorationThickness ?? 2,
          decorationColor: decorationColor ?? AppColors.primaryColorOne,
          fontWeight: fontWeight,
          overflow: TextOverflow.ellipsis,
          ),
    );
  }
}
