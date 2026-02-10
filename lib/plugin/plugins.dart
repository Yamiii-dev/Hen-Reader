import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_js/extensions/fetch.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:hen_reader/classes/post.dart';
import 'package:hen_reader/plugin/post.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

class Plugin {
  final JavascriptRuntime runtime = getJavascriptRuntime();
  final String name;
  final dynamic focusUI;
  final String folderName;
  Plugin({required this.name, required this.focusUI, required this.folderName});

  void dispose() {
    runtime.dispose();
  }
}

class Plugins {
  List<Plugin> plugins = List.empty(growable: true);

  bool initialized = false;

  int currentPlugin = 0;

  Future init() async {
    initialized = false;
    currentPlugin = 0;
    plugins = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("PluginSettings", []);
    final appDir = await getApplicationDocumentsDirectory();
    Directory pluginFolder = Directory("${appDir.path}/hen_reader/plugins");
    debugPrint(appDir.path);
    bool checkPluginFolder = await pluginFolder.exists();
    if (!checkPluginFolder) {
      await pluginFolder.create(recursive: true);
    }
    final scripts = await pluginFolder.list().toList();

    if (scripts.isNotEmpty) {
      for (var script in scripts) {
        if (script is Directory) {
          File code = File((script as Directory).path + "/main.js");
          File meta = File((script as Directory).path + "/meta.json");
          File ui = File((script as Directory).path + "/ui.yaml");

          Map<String, dynamic> metaJson = json.decode(meta.readAsStringSync());

          dynamic uiYaml = loadYaml(ui.readAsStringSync());

          String name = (metaJson["name"] as String);

          Plugin plugin = Plugin(
            name: name,
            focusUI: uiYaml,
            folderName: (script as Directory).path.split("/").last
          );
          if(metaJson["settings"] != null){
            List<String> settings = prefs.getStringList("PluginSettings") ?? [];
            Map<String, dynamic> settingsJson = metaJson["settings"] as Map<String, dynamic>;
            for(var setting in settingsJson.keys){
              settings.add(setting + "\u0001" + name);
            }
            prefs.setStringList("PluginSettings", settings);
          }
          plugin.runtime.evaluate(code.readAsStringSync());
          plugin.runtime.onMessage("getJson", (dynamic message) async {
            final url = message[0] as String;
            final res = await http.get(Uri.parse(url));

            final json = jsonDecode(res.body);

            return json;
          });
          plugin.runtime.onMessage("getSetting", (dynamic message) async{
            final key = message[0] as String;
            final value = prefs.getString(key + "\u0001" + name);
            return value;
          });
          plugin.runtime.evaluate("""
          async function getJson(url){
            return await sendMessage("getJson", JSON.stringify([url]));
          }
          async function getSetting(key){
            return await sendMessage("getSetting", JSON.stringify([key]));
          }
          """);
          plugins.add(plugin);
        }
      }
    }

    initialized = true;
  }

  Future<List<Post>> Search(String searchQuery, int currentPage) async {
    List<Post> posts = List.empty(growable: true);
    var result = await plugins[currentPlugin].runtime.evaluateAsync(
      "search('$searchQuery', $currentPage)",
    );
    var raw = result.rawResult is Future
        ? await (await plugins[currentPlugin].runtime.handlePromise(
            result,
          )).rawResult
        : result.rawResult;
    if (raw is List) {
      for (var post in raw) {
        if (post["thumb"] != null) {
          posts.add(
            PluginPost(
              thumb: post["thumb"] as String,
              name: post["title"] as String,
              UI: plugins[currentPlugin].focusUI,
              plugins: this,
              extra: Map<String, dynamic>.from(post)
                ..remove('title')
                ..remove('thumb'),
            ),
          );
        }
      }
    }
    return posts;
  }

  Future RunJSAction(
    String actionName,
    PluginPost post,
    Map<String, dynamic> params,
  ) async {
    final postObj = {"title": post.name, "thumb": post.thumb, ...post.extra};

    final postJson = jsonEncode(postObj);
    final paramsJson = jsonEncode(params);

    final result = await plugins[currentPlugin].runtime.evaluateAsync(
      "$actionName($postJson, $paramsJson)",
    );

    final updatedData = result.rawResult;
    post.extra = Map<String, dynamic>.from(updatedData)
      ..remove('title')
      ..remove('thumb');
  }

  void dispose() {
    for (int i = 0; i < plugins.length; i++) plugins[i].dispose();
    plugins.clear();
  }
}
