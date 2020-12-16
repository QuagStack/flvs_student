import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flvs_student/components/enrollmentCard.dart';
import 'package:flvs_student/models/enrollment.dart';
import 'package:flvs_student/screens/studentDash_screen.dart';
import '../constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flvs_student/components/rounded_button.dart';
import 'package:percent_indicator/percent_indicator.dart';

class EnrollmentDetailsScreen extends StatefulWidget {
  static const String id = 'enrollmentDetails_Screen';
  final Enrollment enrollment;
  const EnrollmentDetailsScreen({Key key, this.enrollment}) : super(key: key);

  @override
  _EnrollmentDetailsScreenState createState() =>
      _EnrollmentDetailsScreenState();
}

class _EnrollmentDetailsScreenState extends State<EnrollmentDetailsScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final Enrollment args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              EnrollmentCard(
                cardColor: Colors.white,
                className: args.courseName,
                percent: args.grade / 100,
                cardChild: new CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 20.0,
                  percent: args.grade / 100,
                  animation: true,
                  animationDuration: 1200,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: (Text(
                    args.letterGrade,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.blue),
                  )),
                  progressColor: Colors.blue,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
