import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tracking_app/colors.dart';
import 'package:tracking_app/general_widgets/nav_drawer.dart';
import 'package:tracking_app/general_widgets/search_container.dart';
import 'package:tracking_app/general_widgets/small_container.dart';
import 'package:tracking_app/home/providers/student_provider.dart';
import 'package:tracking_app/home/screens/chat_page.dart';
import 'package:tracking_app/home/screens/profile_page.dart';

import '../../Responsiveness.dart';
import '../../styles.dart';

class HomePage extends StatefulWidget {
  static const String pageName = '/homePage';

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController _controller;
  // static final LatLng myLocation = userLocation;
  bool isMapCreated = false;
  SizeConfig sizeConfig = new SizeConfig();
  bool switchValue = false;
  final user = FirebaseAuth.instance.currentUser;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // final CameraPosition _kGooglePlex = CameraPosition(
  //   target: myLocation,
  //   zoom: 14.4746,
  // );
  // final List<Widget> chipContainers = [
  //   ChipContainer(Jcolors.green_notty, 'Broken Bath Tub', JStyles.chipText),
  //   ChipContainer(Jcolors.blue, 'Broken Pipe', JStyles.chipText),
  //   ChipContainer(Jcolors.brown_notty, 'Broken Bath Tub', JStyles.chipText),
  //   ChipContainer(Jcolors.blue_notty, 'Broken Bath Tub', JStyles.chipText),
  //   ChipContainer(Jcolors.green_notty, 'Broken Bath Tub', JStyles.chipText),
  //   ChipContainer(Jcolors.red_notty, 'Broken Bath Tub', JStyles.chipText)
  // ];

  // final List<RatingContainer> ratings = [
  //   RatingContainer('Easy to work with', 4),
  //   RatingContainer('Communication', 2),
  //   RatingContainer('Relations', 4),
  // ];
  final Set<Marker> markers = new Set();
  void _createMarker() async {
    Position userPosition = await Geolocator.getCurrentPosition();
    markers.add(Marker(
      markerId: MarkerId("marker_1"),
      infoWindow: InfoWindow(
        //popup info
        title: 'Your Current Location',
      ),
      position: LatLng(userPosition.latitude, userPosition.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange,
      ),
    ));
  }

  bool allowTracking = false;

  FocusNode _searchFocusNode = new FocusNode();

  List<StudentProvider> students = [];
  TextEditingController _searchController = new TextEditingController();
  //Position usersPosition;
  LatLng userLocation;

  Future<Position> _determinePosition(bool value) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
// this code is used to obtain the on
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    // to upload each users location to firebase:
    final local = await Geolocator.getCurrentPosition();

    final usersLocationDatabase = FirebaseDatabase.instance;
    final ref = usersLocationDatabase.reference().child('/usersLocation');
    await ref.child(FirebaseAuth.instance.currentUser.uid).set({
      ...local.toJson(),
      'userName': FirebaseAuth.instance.currentUser.displayName,
      'shouldTrack': value,
    });

    userLocation = LatLng(local.latitude, local.longitude);

    return local;
  }

  List<StudentProvider> quickSearches = [];
  void searchStudents(String input) {
    setState(() {
      quickSearches = [...students]
          .where((student) =>
              student.studentName.toLowerCase().trim().contains(input) ||
              student.matricNo.toLowerCase().trim().contains(input))
          .toList();
    });
  }

  // Future<String> getJsonFile(String path) async {
  //   return await rootBundle.loadString(path);
  // }

  // void setGoogleMapStyle() async {
  //   _controller.setMapStyle(await getJsonFile('assets/map/mapTheme.json'));
  // }
  Future<Position> getUserCurrentLocation() {
    final pos = Geolocator.getCurrentPosition();
    return pos;
  }

  // void getAllUsersData() async {
  //   List mvalues = [];
  //   final database = FirebaseDatabase.instance;
  //   final studentsInfo = await database.reference().child('/users').get();
  //   print(studentsInfo.value);
  //   Map<Object, dynamic> values = studentsInfo.value as Map<dynamic, dynamic>;
  //   values.forEach((key, values) {
  //     mvalues.add(values);
  //     if (mvalues != null) {
  //       mvalues.forEach((student) {
  //         students.add(StudentProvider(
  //             uid: key,
  //             studentName: student['userName'],
  //             matricNo: student['Matriculation Number'],
  //             roomNo: student['Room NO'],
  //             emailAddress: student['emailAddress'],
  //             registrationNo: student['Registration Number'],
  //             phoneNo: student['Phone Number']));
  //       });
  //     }
  //   });

  //   print(students);
  // }

  @override
  void initState() {
    super.initState();
    quickSearches = students;
    _createMarker();
    getUserCurrentLocation();

    // getAllUsersData();
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  List list = [];
  List<UserLocation> usersLocation = [];
  @override
  Widget build(BuildContext context) {
    // final  statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: NavDrawer(user.displayName),
      body: StreamBuilder<Event>(
          stream: FirebaseDatabase.instance
              .reference()
              .child('usersLocation')
              .onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                !snapshot.hasError &&
                snapshot.data.snapshot.value != null) {
              DataSnapshot dataValues = snapshot.data.snapshot;
              Map<Object, dynamic> values =
                  dataValues.value as Map<dynamic, dynamic>;
              values.forEach((key, values) {
                list.add(values);
              });

              print(values);
              if (values != null) {
                values.forEach((key, value) {
                  if (key == FirebaseAuth.instance.currentUser.uid) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      allowTracking = value['shouldTrack'];
                      print('allow tracking:' + allowTracking.toString());
                    });
                  }

                  usersLocation.add(new UserLocation(
                      uid: key,
                      userName: value['userName'],
                      longitude: value['longitude'],
                      latitude: value['latitude']));

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (value['shouldTrack'] == true &&
                        key != FirebaseAuth.instance.currentUser.uid) {
                      markers.add(Marker(
                        //add first marker
                        markerId: MarkerId(key),
                        position: LatLng(value['latitude'],
                            value['longitude']), //position of marker
                        infoWindow: InfoWindow(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (ctx) {
                              return ChatPage(
                                  arguments: ChatPageArguments(
                                      peerAvatar:
                                          'data:image/png;base64,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',
                                      peerId: key,
                                      peerNickname: value['userName']));
                            }));
                          },
                          //popup info
                          title: '${value['userName']}\'s Location on Campus',
                          snippet: 'Click to chat with',
                        ),

                        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
                      ));
                    }
                  });
                });
              }
            }
            //   print('ojnknjn' + snapshot.data.snapshot.value);

            return SafeArea(
              child: FutureBuilder(
                future: getUserCurrentLocation(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Column(
                    children: [
                      Container(
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            Container(
                              height: sizeConfig.heightMargin(context, 97),
                              //  kBottomNavigationBarHeight,
                              child: GoogleMap(
                                mapType: MapType.normal,
                                mapToolbarEnabled: false,
                                //zoomGesturesEnabled: true,
                                myLocationButtonEnabled: true,

                                zoomControlsEnabled: false,
                                myLocationEnabled: true,
                                markers: markers,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(snapshot.data.latitude,
                                      snapshot.data.longitude),
                                  zoom: 18,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  _controller = controller;
                                  isMapCreated = true;
                                  //  setGoogleMapStyle();
                                  // changeMapMode();
                                  setState(() {});
                                },
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: IgnorePointer(
                                ignoring: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                    colors: switchValue
                                        ? [
                                            Jcolors.black,
                                            Jcolors.black.withOpacity(0.608),
                                            Jcolors.black.withOpacity(0.2643),
                                            Jcolors.black.withOpacity(0),
                                          ]
                                        : [
                                            Jcolors.blue_fade,
                                            Jcolors.blue_fade
                                                .withOpacity(0.608),
                                            Jcolors.blue_fade
                                                .withOpacity(0.2643),
                                            Jcolors.blue_fade.withOpacity(0),
                                          ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.mirror,
                                  )),
                                  height: sizeConfig.heightMargin(context, 22),
                                  padding: const EdgeInsets.only(
                                      left: 24, right: 13, top: 30),
                                  // child:
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                height: sizeConfig.heightMargin(context, 22),
                                padding: const EdgeInsets.only(
                                    left: 24, right: 13, top: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 86,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Jcolors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              user.displayName != null
                                                  ? 'Good ${greeting()} ${user.displayName} 👋🏾'
                                                  : 'Good ${greeting()}',
                                              style:
                                                  JStyles.bottomText.copyWith(
                                                color: Jcolors.text,
                                              )),
                                          SizedBox(
                                            height: sizeConfig.heightMargin(
                                                context, 1.5625),
                                          ),
                                          Expanded(
                                              child: Text('Welcome',
                                                  style: JStyles.subTitle)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _scaffoldKey.currentState
                                          .openEndDrawer(),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Jcolors.white,
                                        child: Stack(
                                          overflow: Overflow.visible,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/images/fi_menu.svg'),
                                            Text(
                                              '2',
                                              style: JStyles.circleAvatarText,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Jcolors.blue_notty,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16)),
                                ),
                                child: Column(
                                  //  overflow: Overflow.visible,
                                  children: [
                                    // Positioned(
                                    //   top: -40,
                                    //   right: 0,
                                    //   left: 0,
                                    // child:
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Jcolors.blue_notty,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16)),
                                      ),
                                      padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 24,
                                          bottom: 10,
                                          right: 24),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            allowTracking
                                                ? 'You can be tracked'
                                                : 'You cannot be tracked',
                                            style: JStyles.numberText
                                                .copyWith(color: Jcolors.white),
                                          ),
                                          Switch.adaptive(
                                              activeColor: Jcolors.blue,
                                              value: allowTracking,
                                              onChanged: (value) async {
                                                await _determinePosition(value);
                                                setState(() {
                                                  // allowTracking = value;
                                                  // print('setstate$value');
                                                });
                                                print(
                                                    'allow tracking in switch:' +
                                                        allowTracking
                                                            .toString());

                                                //  usersPosition =
                                              })
                                        ],
                                      ),
                                      // ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width: double.infinity,
                                        height: _searchFocusNode.hasFocus
                                            ? 300
                                            : 230,
                                        //  height: sizeConfig.heightMargin(context, 30),
                                        padding: const EdgeInsets.only(
                                            left: 24,
                                            right: 14,
                                            top: 16,
                                            bottom: 16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SearchContainer(Center(
                                                  child: TextField(
                                                    focusNode: _searchFocusNode,
                                                    onSubmitted: (value) {
                                                      _searchFocusNode
                                                          .unfocus();
                                                    },
                                                    onTap: () {},
                                                    onChanged: (value) {
                                                      searchStudents(value);
                                                      if (value.isEmpty) {
                                                        _searchFocusNode
                                                            .unfocus();
                                                      }
                                                    },
                                                    style: JStyles
                                                        .onBoardMessage
                                                        .copyWith(
                                                            color: Jcolors
                                                                .sub_text),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Jcolors.sub_fade,
                                                      ),
                                                      hintText:
                                                          'Search for a Student',
                                                      hintStyle: JStyles
                                                          .onBoardMessage
                                                          .copyWith(
                                                              color: Jcolors
                                                                  .sub_fade),
                                                    ),
                                                  ),
                                                )),
                                                Container(
                                                  height: 110,
                                                  width: sizeConfig.widthMargin(
                                                      context, 89),
                                                  child: StreamBuilder<Event>(
                                                    stream: FirebaseDatabase
                                                        .instance
                                                        .reference()
                                                        .child('/users')
                                                        .onValue,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.data ==
                                                          null) {
                                                        return Container(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        );
                                                      }
                                                      List mvalues = [];

                                                      Map<Object, dynamic>
                                                          values = snapshot
                                                                  .data
                                                                  .snapshot
                                                                  .value
                                                              as Map<dynamic,
                                                                  dynamic>;

                                                      values.forEach(
                                                          (key, values) {
                                                        if (key ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid ||
                                                            students.any(
                                                                (student) =>
                                                                    student
                                                                        .uid ==
                                                                    key)) {
                                                          return;
                                                        }
                                                        if (values[
                                                                'userName'] ==
                                                            null) {
                                                          return;
                                                        }

                                                        students.add(StudentProvider(
                                                            uid: key,
                                                            studentName: values[
                                                                'userName'],
                                                            matricNo: values[
                                                                'Matriculation Number'],
                                                            roomNo: values[
                                                                'Room NO'],
                                                            emailAddress: values[
                                                                'emailAddress'],
                                                            registrationNo: values[
                                                                'Registration Number'],
                                                            courseOfStudy: values[
                                                                'Course OF Study'],
                                                            hallOfResidence: values[
                                                                'Hall of Residence'],
                                                            phoneNo: values[
                                                                'Phone Number']));
                                                      });
                                                      return Container(
                                                        //color: Colors.red,
                                                        height: _searchFocusNode
                                                                .hasFocus
                                                            ? 210
                                                            : 110,
                                                        width: sizeConfig
                                                            .widthMargin(
                                                                context, 89),
                                                        child: students.isEmpty
                                                            ? Center(
                                                                child: Text(
                                                                    'NO STUDENT IS AVAILABLE!',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            24,
                                                                        color: Colors
                                                                            .blueGrey)),
                                                              )
                                                            : ListView.builder(
                                                                itemCount:
                                                                    quickSearches
                                                                        .length,
                                                                itemBuilder:
                                                                    (ctx,
                                                                        index) {
                                                                  return GestureDetector(
                                                                    onTap: () => Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ProfilePage(student: quickSearches[index]))),
                                                                    child:
                                                                        Container(
                                                                      key:
                                                                          UniqueKey(),
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                              10),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          color: Jcolors
                                                                              .light_blue,
                                                                          borderRadius:
                                                                              BorderRadius.circular(10)),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text('Name: ' +
                                                                              quickSearches[index].studentName),
                                                                          Row(
                                                                            children: [
                                                                              Text('Matric NO: ' + quickSearches[index].matricNo),
                                                                              Spacer(),
                                                                              Text('Room NO: ' + quickSearches[index].roomNo),
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
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          color: Jcolors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class UserLocation {
  final String uid;
  final String userName;
  final double longitude;
  final double latitude;
  UserLocation({
    @required this.uid,
    @required this.userName,
    @required this.longitude,
    @required this.latitude,
  });
}
