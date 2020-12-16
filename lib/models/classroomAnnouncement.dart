class ClassroomAnnouncement {
  final String classroomId;
  final DateTime postedDate;
  final String announcement;
  final String title;
  final String imageLocation;

  ClassroomAnnouncement(this.classroomId, this.postedDate, this.announcement,
      this.title, this.imageLocation);

  ClassroomAnnouncement.fromJson(Map<String, dynamic> json)
      : classroomId = json['classroomId'],
        postedDate = json['postedDate'],
        announcement = json["body"],
        imageLocation = json["imageLocation"],
        title = json["title"];
}
