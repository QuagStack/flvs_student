import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flvs_student/models/enrollment.dart';
import 'package:flvs_student/components/enrollmentCard.dart';
import 'package:flvs_student/screens/classroomAnnouncements_screen.dart';
import 'login_screen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class StudentDashScreen extends StatefulWidget {
  static const String id = 'studentDash_screen';

  @override
  _StudentDashScreenState createState() => _StudentDashScreenState();
}

class _StudentDashScreenState extends State<StudentDashScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  var enrollmentCards = new List<EnrollmentCard>();
  var enrollmentCollection = new List<Enrollment>();
  var rowWidgets = new List<Row>();
  var workingRow = new Row();
  var enrollmentPages = new List<Column>();
  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getEnrollments();
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

  void getEnrollments() async {
    final enrollments = await _firestore
        .collection('enrollments')
        .doc(loggedInUser.email)
        .collection('enrollments')
        .get();

    for (var enrollment in enrollments.docs) {
      print(enrollments.docs
          .indexWhere((element) => element.id == enrollment.id));
      Enrollment e = new Enrollment(
          enrollment["courseName"],
          enrollment["enrollmentId"],
          enrollment["grade"],
          enrollment["letterGrade"],
          enrollment["teacherEmail"],
          enrollment["teacherName"],
          enrollment["classroom"],
          enrollment["segment"],
          null,
          enrollment["teacherPhone"],
          enrollment["teacherImageLocation"]);

      //Get Image URL
      var imageURL =
          await _firestore.collection('classroomImages').doc(e.classroom).get();
      print(imageURL);
      e.imageUrl = imageURL["imageLocation"];

      List<EnrollmentEvent> enrollmentEvents = new List<EnrollmentEvent>();
      var events = await _firestore
          .collection('enrollments')
          .doc(loggedInUser.email)
          .collection("enrollments")
          .doc(enrollment["enrollmentId"])
          .collection('enrollmentEvents')
          .get();
      for (var event in events.docs) {
        enrollmentEvents.add(new EnrollmentEvent(
            DateTime.fromMillisecondsSinceEpoch(
                event["eventDate"].seconds * 1000),
            event["eventDescription"],
            event["eventLocation"]));
      }
      e.enrollmentEvents = enrollmentEvents;
      enrollmentCollection.add(e);
      var card = createEnrollmentCard(e);
      setState(() {
        enrollmentPages.add(new Column(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(e.imageUrl), fit: BoxFit.fill),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (enrollments.docs.indexWhere((element) =>
                                      element.id == enrollment.id) +
                                  1)
                              .toString() +
                          "/" +
                          enrollments.docs.length.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ClassRoomAnnouncementsScreen(
                                  classroomId: e.classroom,
                                )));
                      },
                      icon: Icon(FontAwesome.envelope_open_o,
                          color: Colors.white),
                    ),
                  ],
                ),
                card
              ],
            ),
          ),
          _buildEventList()
        ]));
      });
    }
    buildEnrollmentRows();
  }

  Color generateLetterGradeColor(String letterGrade) {
    switch (letterGrade) {
      case "A":
      case "B":
        return Colors.white;
        break;
      case "C":
        return Colors.yellow;
        break;
      case "D":
      case "F":
        return Colors.red;
        break;
      default:
        return Colors.white;
    }

    if (letterGrade == "C") {
      return Colors.yellow;
    }
  }

  EnrollmentCard createEnrollmentCard(Enrollment enrollment) {
    var per = enrollment.grade.toDouble();
    var card = new EnrollmentCard(
      className: enrollment.courseName,
      classroomImage: enrollment.imageUrl,
      cardColor: Colors.blueGrey,
      percent: per,
      cardChild: new CircularPercentIndicator(
        radius: 200.0,
        lineWidth: 20.0,
        percent: per / 100,
        animation: true,
        animationDuration: 1200,
        circularStrokeCap: CircularStrokeCap.round,
        center: (Text(
          enrollment.letterGrade,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 80.0,
              color: generateLetterGradeColor(enrollment.letterGrade)),
        )),
        progressColor: Colors.white,
      ),
      onPressed: () {
        slideEnrollmentInfo(enrollment);
      },
    );
    enrollmentCards.add(card);
    return card;
  }

  void buildEnrollmentRows() {
    for (var cardIndex = 0;
        cardIndex < enrollmentCards.length;
        cardIndex = cardIndex + 2) {
      if (enrollmentCards.asMap().containsKey(cardIndex + 1)) {
        setState(() {
          rowWidgets.add(new Row(
            children: [
              Expanded(child: enrollmentCards[cardIndex]),
              Expanded(child: enrollmentCards[cardIndex + 1])
            ],
          ));
        });
        continue;
      } else {
        setState(() {
          rowWidgets.add(new Row(
            children: [
              Expanded(child: enrollmentCards[cardIndex]),
            ],
          ));
        });
        continue;
      }
    }
  }

  Widget _buildEventList() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) => Container(
          decoration: BoxDecoration(
            color: (index % 2 == 0) ? Colors.white : Colors.white38,
            border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(FontAwesome.calendar),
            title: Text(DateFormat("MM/dd/yyyy").format(
                enrollmentCollection[index].enrollmentEvents[index].eventDate)),
            subtitle: Text(enrollmentCollection[index]
                .enrollmentEvents[index]
                .eventDescription),
            onTap: () async {
              try {
                var e = new Event();
                e.title = enrollmentCollection[index]
                    .enrollmentEvents[index]
                    .eventDescription;
                e.description = enrollmentCollection[index]
                    .enrollmentEvents[index]
                    .eventDescription;
                e.allDay = true;
                e.location = enrollmentCollection[index]
                    .enrollmentEvents[index]
                    .eventLocation;
                e.startDate = enrollmentCollection[index]
                    .enrollmentEvents[index]
                    .eventDate;
                e.endDate = enrollmentCollection[index]
                    .enrollmentEvents[index]
                    .eventDate;

                Add2Calendar.addEvent2Cal(e).then((success) {
                  final snackBar = SnackBar(
                    backgroundColor: Colors.blue,
                    content: Text(
                      'Event Successfully Added To Calendar',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    action: SnackBarAction(
                      textColor: Colors.white,
                      label: 'Close',
                      onPressed: () {},
                    ),
                  );

                  // Find the Scaffold in the widget tree and use
                  // it to show a SnackBar.
                  Scaffold.of(context).showSnackBar(snackBar);
                });
              } on Exception catch (e) {
                print('error caught: $e');
              }
            },
          ),
        ),
        itemCount: enrollmentCollection.length,
      ),
    );
  }

  void slideEnrollmentInfo(Enrollment enrollment) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              color: Colors.white.withOpacity(0.00),
              child: Container(
                  height: 700,
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
                              child: FlatButton(
                                onPressed: () async {
                                  print("pressed");
                                  if (await canLaunch(
                                      'sms:${enrollment.teacherPhone}?body=hello%20there')) {
                                    await launch(
                                        'sms:${enrollment.teacherPhone}?body=hello%20there');
                                  } else {
                                    throw 'Could not launch';
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      enrollment.teacherImageLocation),
                                  backgroundColor: Colors.brown.shade800,
                                  radius: 90.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: Center(
                            child: Text("Tap your instructor to contact",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ))
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: Center(
                            child: Text(
                                enrollment.courseName +
                                    " Segment " +
                                    enrollment.segment,
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
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
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              // autoPlay: false,
            ),
            items: enrollmentPages
                .map((item) => Container(
                      child: Center(child: item),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
