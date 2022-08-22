import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracking_app/colors.dart';
import 'package:tracking_app/home/providers/student_provider.dart';
import 'package:tracking_app/home/screens/chat_page.dart';

class ProfilePage extends StatelessWidget {
  static const String pageName = '/profilePage';
  final StudentProvider student;
  ProfilePage({this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE PAGE'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/person.png'),
              ),
              buildProfileContainer(context, 'Name', student.studentName),
              buildProfileContainer(
                  context, 'Matriculation Number', student.matricNo),
              buildProfileContainer(
                  context, 'Course of Study', student.courseOfStudy),
              buildProfileContainer(
                  context, 'Hall of Residenve', student.hallOfResidence),
              buildProfileContainer(context, 'Room Number', student.roomNo),
              buildProfileContainer(
                  context, 'Email Address', student.emailAddress),
              buildProfileContainer(context, 'Registeration Number',
                  student.registrationNo.toString()),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return ChatPage(
                          arguments: ChatPageArguments(
                              peerAvatar:
                                  'data:image/png;base64,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',
                              peerId: student.uid,
                              peerNickname: student.studentName));
                    }));
                  },
                  child: Text('SEND A MESSAGE'))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileContainer(
      BuildContext context, String title, String content) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  GoogleFonts.roboto(fontSize: 13, color: Colors.blueGrey[800]),
            ),
            Text(
              content,
              style:
                  GoogleFonts.roboto(fontSize: 17, color: Colors.blueGrey[400]),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(
              width: 2, color: Colors.blueGrey, style: BorderStyle.solid),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(left: 20, bottom: 5),
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width * 0.89);
  }
}
