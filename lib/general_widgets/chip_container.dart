import 'package:flutter/widgets.dart';

class ChipContainer extends StatelessWidget {
  final Color color;
  final String text;
  final TextStyle style;
  ChipContainer(this.color, this.text, this.style);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // height: sizeConfig.heightMargin(context, 3.4375),
      child: Center(
        child: Text(
          text,
          style: style,
        ),
      ),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(36)),
    );
  }
}
