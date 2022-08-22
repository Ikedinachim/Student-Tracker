import 'package:flutter/cupertino.dart';

class StudentProvider with ChangeNotifier {
  final String studentName;
  final String matricNo;
  final String phoneNo;
  final int registrationNo;
  final String roomNo;
  final String courseOfStudy;
  final String emailAddress;
  final String hallOfResidence;
  final String uid;
//115200
  StudentProvider({
    @required this.studentName,
    @required this.matricNo,
    @required this.roomNo,
    @required this.courseOfStudy,
    @required this.hallOfResidence,
    @required this.emailAddress,
    @required this.registrationNo,
    @required this.phoneNo,
    @required this.uid,
  });
}
