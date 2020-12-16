import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flvs_student/screens/enrollmentDetails_screen.dart';
import 'package:flvs_student/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/classroomAnnouncements_screen.dart';
import 'screens/studentDash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FlvsStudent());
}

class FlvsStudent extends StatefulWidget {
  @override
  _FlvsStudentState createState() => _FlvsStudentState();
}

class _FlvsStudentState extends State<FlvsStudent> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ClassRoomAnnouncementsScreen(
                classroomId: message['data']['classroomId'])));
      },
      onLaunch: (Map<String, dynamic> message) async {
        var thing = await _firebaseMessaging.getToken();
        print(thing);
        print('on launch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        var thing = await _firebaseMessaging.getToken();
        print(thing);
        print('on resume: $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: LoginScreen.id, routes: {
      LoginScreen.id: (context) => LoginScreen(),
      EnrollmentDetailsScreen.id: (context) => EnrollmentDetailsScreen(),
      StudentDashScreen.id: (context) => StudentDashScreen(),
      ClassRoomAnnouncementsScreen.id: (context) =>
          ClassRoomAnnouncementsScreen()
    });
  }
}
