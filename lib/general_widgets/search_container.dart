import 'package:flutter/material.dart';
import 'package:tracking_app/colors.dart';

import '../Responsiveness.dart';

class SearchContainer extends StatelessWidget {
  final SizeConfig sizeConfig = new SizeConfig();
  final Widget child;
  SearchContainer(this.child);
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(left: 20),
      height: sizeConfig.heightMargin(context, 7),
      width: sizeConfig.widthMargin(context, 89),
      decoration: BoxDecoration(
        color: Jcolors.low_fade,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
