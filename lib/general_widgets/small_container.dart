import 'package:flutter/material.dart';

import '../Responsiveness.dart';
import '../styles.dart';

class SmallContainer extends StatelessWidget {
  SizeConfig sizeConfig = new SizeConfig();
  final Color textColor;
  final Color buttonColor;
  final String text;
  final double width;
  SmallContainer(this.text, this.buttonColor, this.textColor, this.width);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text(
          text,
          style: JStyles.signUpText.copyWith(color: textColor),
        ),
      ),
      height: sizeConfig.heightMargin(context, 7.8125),
      width: SizeConfig().widthMargin(context, width),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: buttonColor),
    );
  }
}
