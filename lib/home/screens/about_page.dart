import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);
  static const String pageName = '/aboutPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ABOUT THE APP'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'This software application was developed by Azikiwe Emmanuel. A final year student studying Computer Engineering as a requirement to obtain a Bachelor\'s degree in Engineering',
            style: GoogleFonts.roboto(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
