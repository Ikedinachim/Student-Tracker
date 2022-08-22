import 'package:flutter/material.dart';

//use this class for dimensions
class SizeConfig {
  double heightMargin(BuildContext context, double height) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      double screenHeight = MediaQuery.of(context).size.height / 100;
      return height * screenHeight;
    } else {
      double screenHeight = MediaQuery.of(context).size.width / 100;
      return height * screenHeight;
    }
  }

  double widthMargin(BuildContext context, double width) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      double screenHeight = MediaQuery.of(context).size.width / 100;
      return width * screenHeight;
    } else {
      double screenHeight = MediaQuery.of(context).size.height / 100;
      return width * screenHeight;
    }
  }

  double textSize(BuildContext context, double textSize) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      double screenHeight = MediaQuery.of(context).size.height / 100;
      return textSize * screenHeight;
    } else {
      double screenHeight = MediaQuery.of(context).size.width / 100;
      return textSize * screenHeight;
    }
  }

  double getYSize(BuildContext context, double size) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      return size / (MediaQuery.of(context).size.height / 100);
    } else {
      return size / (MediaQuery.of(context).size.width / 100);
    }
  }

  double getXSize(BuildContext context, double size) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      return size / (MediaQuery.of(context).size.width / 100);
    } else {
      return size / (MediaQuery.of(context).size.height / 100);
    }
  }
}
