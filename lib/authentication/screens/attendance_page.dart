import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tracking_app/general_widgets/search_container.dart';
import 'package:tracking_app/home/models/attendance_model.dart';
import 'package:tracking_app/home/providers/student_provider.dart';
import 'package:tracking_app/home/screens/profile_page.dart';

import '../../Responsiveness.dart';
import '../../colors.dart';
import '../../styles.dart';

class AttandacePage extends StatefulWidget {
  AttandacePage({Key key}) : super(key: key);
  static const String pageName = '/attendancePage';

  @override
  State<AttandacePage> createState() => _AttandacePageState();
}

class _AttandacePageState extends State<AttandacePage> {
  SizeConfig sizeConfig = new SizeConfig();

  List<StudentProvider> students = [];

  List<StudentProvider> quickSearches = [];
  FocusNode _searchFocusNode = new FocusNode();
  bool checked = false;

  void searchStudents(String input) {
    setState(() {
      quickSearches = [...students]
          .where((student) =>
              student.studentName.toLowerCase().trim().contains(input) ||
              student.matricNo.toLowerCase().trim().contains(input))
          .toList();
    });
  }

  List<AttendanceModel> studenceAttendance = [];
  void _upLoadAttendace(List<AttendanceModel> studenceAttendance) {
    Map<String, Object> userData = {};
    Map<String, Object> mn = {};
    List map = [];
    for (var element in studenceAttendance) {
      mn = {
        'Student\'s name': element.studentName,
        'Matriculation Number': element.matricNO,
        'Present In Class': element.isAvailable,
      };
      map.add(mn);
    }
    //userData.addEntries(map)
    final auth = FirebaseAuth.instance;
    final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    final ref = firebaseDatabase
        .reference()
        .child('/LectureAttendance/${auth.currentUser.uid}');
    ref.child('/${DateFormat('yyyy-MM-dd').format(DateTime.now())}').set(map);
    print(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Text(
              'CAPTURE ATTENDANCE',
              style: TextStyle(
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            SearchContainer(Center(
              child: TextField(
                focusNode: _searchFocusNode,
                onSubmitted: (value) {
                  _searchFocusNode.unfocus();
                },
                onTap: () {},
                onChanged: (value) {
                  searchStudents(value);
                  if (value.isEmpty) {
                    _searchFocusNode.unfocus();
                  }
                },
                style: JStyles.onBoardMessage.copyWith(color: Jcolors.sub_text),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Jcolors.sub_fade,
                  ),
                  hintText: 'Search for a Student',
                  hintStyle:
                      JStyles.onBoardMessage.copyWith(color: Jcolors.sub_fade),
                ),
              ),
            )),
            SizedBox(
              height: 30,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: sizeConfig.widthMargin(context, 100),
              child: StreamBuilder<Event>(
                stream: FirebaseDatabase.instance
                    .reference()
                    .child('/users')
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List mvalues = [];

                  Map<Object, dynamic> values =
                      snapshot.data.snapshot.value as Map<dynamic, dynamic>;

                  values.forEach((key, values) {
                    if (key == FirebaseAuth.instance.currentUser.uid ||
                        students.any((student) => student.uid == key)) {
                      return;
                    }
                    if (values['userName'] == null) {
                      return;
                    }

                    students.add(StudentProvider(
                        uid: key,
                        studentName: values['userName'],
                        matricNo: values['Matriculation Number'],
                        roomNo: values['Room NO'],
                        emailAddress: values['emailAddress'],
                        registrationNo: values['Registration Number'],
                        courseOfStudy: values['Course OF Study'],
                        hallOfResidence: values['Hall of Residence'],
                        phoneNo: values['Phone Number']));
                    studenceAttendance.add(AttendanceModel(values['userName'],
                        values['Matriculation Number'], false));

                    print(studenceAttendance);
                  });
                  return Container(
                    //color: Colors.red,
                    height: _searchFocusNode.hasFocus ? 210 : 110,
                    width: sizeConfig.widthMargin(context, 89),
                    child: students.isEmpty
                        ? Center(
                            child: Text('NO STUDENT IS AVAILABLE!',
                                style: GoogleFonts.roboto(
                                    fontSize: 24, color: Colors.blueGrey)),
                          )
                        : ListView.builder(
                            itemCount: quickSearches.length,
                            itemBuilder: (ctx, index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage(
                                            student: quickSearches[index]))),
                                child: Container(
                                  key: UniqueKey(),
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Jcolors.light_blue,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ' +
                                          quickSearches[index].studentName),
                                      Row(
                                        children: [
                                          Text('Matric NO: ' +
                                              quickSearches[index].matricNo),
                                          Spacer(),
                                          Checkbox(
                                              value: studenceAttendance[index]
                                                  .isAvailable,
                                              onChanged: (val) {
                                                setState(() {
                                                  studenceAttendance[index]
                                                      .isAvailable = val;
                                                });
                                              })
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  _upLoadAttendace(studenceAttendance);
                },
                child: Text('UPLOAD ATTENDACE')),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    quickSearches = students;
    super.initState();
  }
}
