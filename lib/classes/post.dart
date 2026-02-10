import 'package:flutter/material.dart';

abstract class Post {
  String get thumbnailUrl;
  String get title;

  Uri PostUrl();

  Widget FocusBuilder(BuildContext);
}

abstract class PostFactory {
  Post fromJson(Map<String, dynamic> json);
}
