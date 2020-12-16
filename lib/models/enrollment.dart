class Enrollment {
  final String courseName;
  final String enrollmentId;
  final int grade;
  final String letterGrade;
  final String teacherEmail;
  final String teacherName;
  final String classroom;
  final String segment;
  String imageUrl;
  final String teacherPhone;
  final String teacherImageLocation;
  List<EnrollmentEvent> enrollmentEvents;

  Enrollment(
      this.courseName,
      this.enrollmentId,
      this.grade,
      this.letterGrade,
      this.teacherEmail,
      this.teacherName,
      this.classroom,
      this.segment,
      this.enrollmentEvents,
      this.teacherPhone,
      this.teacherImageLocation);

  Enrollment.fromJson(Map<String, dynamic> json)
      : courseName = json['courseName'],
        enrollmentId = json['enrollmentId'],
        grade = json["grade"],
        letterGrade = json["letterGrade"],
        teacherEmail = json["teacherEmail"],
        teacherName = json["teacherName"],
        classroom = json["classroom"],
        segment = json["segment"],
        teacherPhone = json["teacherPhone"],
        teacherImageLocation = json["teacherImageLocation"],
        enrollmentEvents = null;
}

class EnrollmentEvent {
  final DateTime eventDate;
  final String eventDescription;
  final String eventLocation;

  EnrollmentEvent(this.eventDate, this.eventDescription, this.eventLocation);
  EnrollmentEvent.fromJson(Map<String, dynamic> json)
      : eventDate = json["eventDate"],
        eventDescription = json["eventDescription"],
        eventLocation = json["eventLocation"];
}
