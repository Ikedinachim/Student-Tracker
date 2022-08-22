import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tracking_app/colors.dart';
import 'package:tracking_app/constants/app_constants.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  FullPhotoPage({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}
