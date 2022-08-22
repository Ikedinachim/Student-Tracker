import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tracking_app/authentication/screens/attendance_page.dart';
import 'package:tracking_app/authentication/screens/login_page.dart';
import 'package:tracking_app/colors.dart';
import 'package:tracking_app/home/screens/about_page.dart';
import 'package:tracking_app/styles.dart';

import '../Responsiveness.dart';

class NavDrawer extends StatefulWidget {
  final String userName;
  String imageUrl;

  NavDrawer(this.userName, {this.imageUrl});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  SizeConfig sizeConfig = new SizeConfig();
  String imageUrl = "";
  String fileName = '';
//  bool isLoading = false;
  Future getProfileImage() async {
    File pickedFile;

    pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (imageFile != null) {
        // setState(() {
        // //  isLoading = true;
        // });
        await uploadFile(imageFile);
      }
    }
  }

  Future uploadFile(File image) async {
    fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final profilePicture = FirebaseDatabase.instance;
    final firebaseStorage = FirebaseStorage.instance;
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      profilePicture
          .reference()
          .child(
              '/users/${FirebaseAuth.instance.currentUser.uid}/Profile Picture')
          .set(imageUrl);
      setState(() {
        // isLoading = false;
      });
    } on FirebaseException catch (e) {
      // setState(() {
      //   isLoading = false;
      // });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String itemName,
      [bool showDivider = true]) {
    return Container(
      width: 207,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              SizedBox(
                width: 20,
              ),
              Text(
                '$itemName',
                style: JStyles.onBoardMessage.copyWith(color: Jcolors.black),
              )
            ],
          ),
          if (showDivider) Divider(),
          SizedBox(
            height: sizeConfig.heightMargin(context, 3.125),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig().heightMargin(context, 6.25),
            ),
            Container(
              width: 207,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await getProfileImage();
                    },
                    child: StreamBuilder<Event>(
                        stream: FirebaseDatabase.instance
                            .reference()
                            .child(
                                '/users/${FirebaseAuth.instance.currentUser.uid}/Profile Picture')
                            .onValue,
                        builder: (context, snapshot) {
                          return CircleAvatar(
                            radius: 30,
                            backgroundImage: snapshot.data == null ||
                                    snapshot.data.snapshot.value
                                        .toString()
                                        .isEmpty
                                ? AssetImage('assets/images/person.png')
                                : NetworkImage(snapshot.data.snapshot.value),
                          );
                        }),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.userName}',
                        style: JStyles.numberText.copyWith(fontSize: 20),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        'View profile',
                        style: JStyles.circleAvatarText2,
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: sizeConfig.heightMargin(context, 1.5625),
            ),

            SizedBox(width: 20),

            Divider(
              color: Colors.grey,
              height: 3,
            ),

            SizedBox(
              height: sizeConfig.heightMargin(context, 10),
            ),
            // GestureDetector(
            //     onTap: () {},
            //     child: _buildDrawerItem(context, Icons.chat, 'Reach Someone')),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AboutPage.pageName);
                },
                child: _buildDrawerItem(
                    context, Icons.info_rounded, 'About The App')),
            // _buildDrawerItem(context, 'Headset.svg', 'Support'),
            // _buildDrawerItem(
            //     context, 'Handshake.svg', 'Leave a feedback', false),
            SizedBox(
              height: sizeConfig.heightMargin(context, 1.5),
            ),
            StreamBuilder<Event>(
                stream: FirebaseDatabase.instance
                    .reference()
                    .child(
                        '/users/${FirebaseAuth.instance.currentUser.uid}/isLecturer')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.data.snapshot.value == true) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(AttandacePage.pageName),
                      child: _buildDrawerItem(
                          context, Icons.info_rounded, 'Take Attendance'),
                    );
                  } else {
                    return null;
                  }
                }),
            SizedBox(
              height: 50,
            ),

            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut().whenComplete(() =>
                    Navigator.of(context)
                        .pushReplacementNamed(LoginPage.pageName));
              },
              child: Container(
                width: 207,
                height: sizeConfig.heightMargin(context, 7.8125),
                decoration: BoxDecoration(
                    color: Jcolors.blue,
                    borderRadius: BorderRadius.circular(12)),
                child:
                    Center(child: SvgPicture.asset('assets/images/logout.svg')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
