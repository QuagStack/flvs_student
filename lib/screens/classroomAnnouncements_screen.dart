import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flvs_student/models/classroomAnnouncement.dart';
import 'package:flvs_student/models/enrollment.dart';
import 'login_screen.dart';
import 'package:flvs_student/screens/studentDash_screen.dart';
import '../constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flvs_student/components/rounded_button.dart';
import 'package:percent_indicator/percent_indicator.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ClassRoomAnnouncementsScreen extends StatefulWidget {
  static const String id = 'classroomAnnouncements_Screen';
  final String classroomId;
  const ClassRoomAnnouncementsScreen({Key key, this.classroomId})
      : super(key: key);

  @override
  _ClassRoomAnnouncementsState createState() => _ClassRoomAnnouncementsState();
}

class _ClassRoomAnnouncementsState extends State<ClassRoomAnnouncementsScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  List<ClassroomAnnouncement> _announcements =
      new List<ClassroomAnnouncement>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getAnnouncements(widget.classroomId);
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      } else {
        Navigator.pushNamed(context, LoginScreen.id);
      }
    } catch (e) {
      print(e);
    }
  }

  void getAnnouncements(String classroomId) async {
    final announcements = await _firestore
        .collection('classroomAnnouncements')
        .doc('annoucements')
        .collection(classroomId)
        .get();
    for (var ann in announcements.docs) {
      ClassroomAnnouncement a = new ClassroomAnnouncement(
          ann["classroomId"],
          ann["postedDate"].toDate(),
          ann["body"],
          ann["title"],
          ann["imageLocation"]);
      setState(() {
        _announcements.add(a);
      });
    }
  }

  void slideAnnouncement(ClassroomAnnouncement announcement) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              color: Colors.white.withOpacity(0.00),
              child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Colors.white60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        children: [
                          Flexible(
                              child: Center(
                                  child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(announcement.imageLocation),
                            backgroundColor: Colors.brown.shade800,
                            radius: 90.0,
                          )))
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: Center(
                            child: Text(announcement.title,
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                          ))
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: Center(
                            child: Text(announcement.announcement,
                                style: TextStyle(fontSize: 20)),
                          ))
                        ],
                      ),
                    ],
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.classroomId.toUpperCase() + " Announcements"),
          leading: IconButton(
            icon: const Icon(FontAwesome.backward),
            tooltip: 'Back',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) => Container(
          decoration: BoxDecoration(
            color: (index % 2 == 0) ? Colors.white : Colors.white38,
            border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(FontAwesome.bullhorn),
            title: Text(_announcements[index].title),
            onTap: () async {
              try {
                slideAnnouncement(_announcements[index]);
              } on Exception catch (e) {
                print('error caught: $e');
              }
            },
          ),
        ),
        itemCount: _announcements.length,
      ),
    );
  }
}
