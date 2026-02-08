import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hen_reader/classes/post.dart';
import 'package:hen_reader/sources/focus_pages/rule34.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Rule34 {
  Future<List<PostR34>> GetPosts(String searchQuery, int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<PostR34> result = List.empty(growable: true);

    String tagsEdited = searchQuery.replaceAll(" ", "+");

    Uri requestPath = Uri.parse(
      "https://api.rule34.xxx/index.php?page=dapi&s=post&q=index&limit=50&tags=$tagsEdited&pid=$page&json=1" +
          (prefs.getString("Rule34API") ?? ""),
    );

    Response res = await get(requestPath);

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        for (var element in body) {
          result.add(PostR34Factory().fromJson(element));
        }
      } catch (indentifier) {
        return List.empty();
      }
    }

    return result;
  }
}

class PostR34 extends Post {
  final String thumbnail;
  final String fileUrl;
  final String id;
  @override
  Uri PostUrl() {
    return Uri.parse("https://rule34.xxx/index.php?page=post&s=view&id=$id");
  }

  PostR34({required this.thumbnail, required this.fileUrl, required this.id});

  @override
  String get title => id;

  @override
  String get thumbnailUrl => thumbnail;

  @override
  Widget FocusBuilder(BuildContext) => FocusPageR34(post: this);
}

class PostR34Factory extends PostFactory {
  @override
  PostR34 fromJson(Map<String, dynamic> json) {
    return PostR34(
      thumbnail: json["sample_url"] as String,
      fileUrl: json["file_url"] as String,
      id: json["id"].toString(),
    );
  }
}
