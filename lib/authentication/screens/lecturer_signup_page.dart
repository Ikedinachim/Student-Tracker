import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracking_app/authentication/screens/login_page.dart';
import 'package:tracking_app/authentication/widgets/input_container.dart';
import 'package:tracking_app/home/screens/home_page.dart';
import 'package:firebase_database/firebase_database.dart';

class LecturerSignUpPage extends StatefulWidget {
  static const pageName = '/LecturerSignUpPage';
  @override
  _LecturerSignUpPageState createState() => _LecturerSignUpPageState();
}

class _LecturerSignUpPageState extends State<LecturerSignUpPage> {
  String _userName;
  String _userEmail;

  String _userPhoneNumber;
  String _userId;
  String _department;
  String _userPassword;
  final _formKey = new GlobalKey<FormState>();

  _signUpUser() async {
    print('sign up user');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        final auth = FirebaseAuth.instance;
        final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

        final userCredential = await auth.createUserWithEmailAndPassword(
            email: _userEmail, password: _userPassword);
        userCredential.user.updateProfile(displayName: _userName);
        Map<String, Object> userData = {
          'userName': _userName,
          'emailAddress': _userEmail,
          'Profile Picture': '',
          'Phone Number': _userPhoneNumber,
          'User ID': userCredential.user.uid,
          'isLecturer': true,
        };
        final ref = firebaseDatabase.reference().child('/users');
        ref.child(userCredential.user.uid).set(userData);
        // _userId = userCredential.user.uid;
        //await Hive.openBox('userInfo');
        await Hive.box('userInfo').put('details', {
          'userName': _userName,
          'userEmail': _userEmail,
          'phoneNumber': _userPhoneNumber,
          'password': _userPassword
        });
        Navigator.of(context).pushReplacementNamed(HomePage.pageName);
      } on PlatformException catch (error) {
        print('platform exception: $error');
      } catch (error) {
        print('other error: $error');
        if (error.message.contains(
            'A network error (such as timeout, interrupted connection or unreachable host) has occurred.')) {
          ScaffoldMessenger.of(context).showSnackBar(noInternetSnackBar);
        }
      }
    }
  }

  Widget noInternetSnackBar =
      SnackBar(content: Text('CONNECT TO THE INTERNET!'));
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 70,
                width: double.infinity,
                //  color: Colors.red,
                child: Center(
                  child: Text(
                    'Lecturer Sign Up',
                    style: GoogleFonts.chivo(
                        color: Colors.blueGrey,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputContainer(
                        'Full Name',
                        TextFormField(
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Full Name'),
                          validator: (input) {
                            if (input.isEmpty || input == null) {
                              return 'Full Name is Required!';
                            }
                            if (input.length < 4) {
                              return 'Name must be at least 4 characters long';
                            }
                            return null;
                          },
                          onSaved: (input) => _userName = input,
                        ),
                      ),
                      InputContainer(
                        'Email',
                        TextFormField(
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'Email'),
                          validator: (input) {
                            if (input.isEmpty || input == null) {
                              return 'Email is Required!';
                            }
                            if (!input.contains('@')) {
                              return 'Valid Email is Required!';
                            }
                            return null;
                          },
                          onSaved: (input) => _userEmail = input,
                        ),
                      ),
                      InputContainer(
                        'Phone Number',
                        TextFormField(
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  top: 5, bottom: 5, right: 10),
                              border: InputBorder.none,
                              hintText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          validator: (input) {
                            if (input.isEmpty || input == null) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                          onSaved: (input) => _userPhoneNumber = input,
                        ),
                      ),
                      InputContainer(
                        'Department',
                        TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Your Department',
                            contentPadding: const EdgeInsets.only(
                                top: 5, bottom: 5, right: 10),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (input) {
                            if (input.isEmpty || input == null) {
                              return 'Please Fill in your hall location!';
                            }
                            return null;
                          },
                          onSaved: (input) => _department = input,
                        ),
                      ),
                      InputContainer(
                        'Password',
                        TextFormField(
                          validator: (input) {
                            _userPassword = input;
                            if (input.isEmpty) {
                              return 'Password is Required!';
                            }
                            if (input.length < 7) {
                              return 'Password must be at least 7 characters long';
                            }
                            return null;
                          },
                          onSaved: (input) => _userPassword = input,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: 'Password', border: InputBorder.none),
                        ),
                      ),
                      InputContainer(
                        'Confirm Password',
                        TextFormField(
                          obscureText: false,
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Field Cannot be Empty!';
                            }
                            if (!(input == _userPassword)) {
                              return 'Password Mismatch!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              border: InputBorder.none),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        child: Text('Already Signed Up? Log In'),
                        onTap: () =>
                            Navigator.of(context).pushNamed(LoginPage.pageName),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      GestureDetector(
                        onTap: () {
                          _signUpUser();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 2, color: Colors.black)),
                          child: Icon(Icons.arrow_forward),
                        ),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
