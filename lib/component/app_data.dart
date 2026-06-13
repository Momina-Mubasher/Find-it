import 'dart:io';

class AppItem {
  String title;
  String description;
  String location;
  String date;
  String category;
  int type;
  File image;

  AppItem({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.category,
    required this.type,
    required this.image,
  });
}

List<AppItem> lostItems = [];
List<AppItem> foundItems = [];