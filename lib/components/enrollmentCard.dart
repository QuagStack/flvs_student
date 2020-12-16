import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flvs_student/models/enrollment.dart';

class EnrollmentCard extends StatelessWidget {
  EnrollmentCard(
      {@required this.cardColor,
      this.cardChild,
      this.onPressed,
      this.classroomImage,
      this.className,
      this.percent});

  final Color cardColor;
  final String classroomImage;
  final Widget cardChild;
  final Function onPressed;
  final String className;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardColor.withOpacity(0.00),
      width: MediaQuery.of(context).size.width,
      //color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
        child: FlatButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: cardChild,
                  ),
                  Text('$className: ${percent.toString()}%',
                      style: TextStyle(color: Colors.white, fontSize: 25.0)),
                ],
              ),
              margin: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
