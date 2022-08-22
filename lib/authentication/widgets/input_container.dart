import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputContainer extends StatelessWidget {
  final String text;
  final Widget child;
  InputContainer(this.text, this.child);

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: const EdgeInsets.only(left: 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              child: Text(
                text,
                style: GoogleFonts.aBeeZee(fontSize: 14, color: Colors.black),
              ),
              padding: const EdgeInsets.only(left: 22)),
          SizedBox(
            height: 4,
          ),
          Center(
            child: Container(
                child: child,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: Colors.blueGrey,
                      style: BorderStyle.solid),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.only(left: 20, bottom: 5),
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 0.89),
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
