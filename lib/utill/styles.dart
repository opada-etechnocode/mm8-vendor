import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_fonts.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

TextStyle get titilliumRegular => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

TextStyle get titilliumSemiBold => TextStyle(
  fontFamily: AppFonts.current,
  fontSize: Dimensions.fontSizeLarge,
  fontWeight: FontWeight.w500,
);

TextStyle get titilliumBold => TextStyle(
  fontFamily: AppFonts.current,
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w600,
);

TextStyle get titilliumItalic => TextStyle(
  fontFamily: AppFonts.current,
  fontSize: Dimensions.fontSizeDefault,
  fontStyle: FontStyle.italic,
);

TextStyle get robotoHintRegular => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeSmall,
  color: Colors.grey,
);

TextStyle get robotoRegular => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
  color: Colors.black,
);

TextStyle get robotoRegularMainHeadingAddProduct => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
  color: Colors.black,
);

TextStyle get robotoRegularForAddProductHeading => TextStyle(
  fontFamily: AppFonts.current,
  color: const Color(0xFF9D9D9D),
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeSmall,
);

TextStyle get robotoTitleRegular => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeLarge,
);

TextStyle get robotoSmallTitleRegular => TextStyle(
  fontFamily: AppFonts.current,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeSmall,
);

TextStyle get robotoBold => TextStyle(
  fontFamily: AppFonts.current,
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w600,
);

TextStyle get robotoMedium => TextStyle(
  fontFamily: AppFonts.current,
  fontSize: Dimensions.fontSizeDefault,
  fontWeight: FontWeight.w500,
);

class ThemeShadow {
  static List<BoxShadow> getShadow(BuildContext context) {
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: Provider.of<ThemeController>(context, listen: false).darkTheme
            ? Colors.black26
            : Theme.of(context).primaryColor.withValues(alpha: .075),
        blurRadius: 5,
        spreadRadius: 1,
        offset: const Offset(1, 1),
      )
    ];
    return boxShadow;
  }
}