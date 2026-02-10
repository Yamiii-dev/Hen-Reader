import 'package:flutter/material.dart';
import 'package:hen_reader/classes/post.dart';
import 'package:hen_reader/plugin/plugins.dart';
import 'package:hen_reader/plugin/postView.dart';
import 'package:video_player/video_player.dart';

class PluginPost extends Post {
  final String thumb;
  final String name;
  final dynamic UI;
  final Plugins plugins;
  Map<String, dynamic> extra; // plugin-specific data
  PluginPost({
    required this.thumb,
    required this.name,
    required this.UI,
    required this.plugins,
    this.extra = const {},
  });

  String get thumbnailUrl => thumb;
  String get title => name;

  dynamic operator [](String key) => extra[key];

  Uri PostUrl() {
    return Uri.parse("");
  }

  Widget FocusBuilder(context) {
    return PluginPostFocusView(post: this);
  }

  Widget ParseUI(
    dynamic node,
    BuildContext context, {
    required VoidCallback refresh,
  }) {
    debugPrint(node["type"].toString());

    /* VideoPLayerController vpController = VideoPlayerController.networkUrl(Uri.parse());
    vpController.initialize();
    vpController.addListener(() {refresh();});
    vpController.play();*/

    switch (node["type"] as String) {
      case ("Image"):
        if (node["bind"] == null) {
          return Image.network(
            "https://firstbenefits.org/wp-content/uploads/2017/10/placeholder.png",
          );
        } else {
          return Image.network(extra[node["bind"]]);
        }
      case ("Content"):
        if (node["bind"] == null) {
          return Image.network(
            "https://firstbenefits.org/wp-content/uploads/2017/10/placeholder.png",
          );
        } else {
          String url = extra[node["bind"]];
          if (url.endsWith(".webm") || url.endsWith(".mp4")) {
            return VideoNode(url: url);
          } else {
            return Image.network(url);
          }
        }
      case ("Text"):
        if (node["text"] != null) {
          return Text(node["text"]);
        }
        return Text("");
      case ("TextButton"):
        return TextButton(
          onPressed: () {
            plugins.RunJSAction(
              node["action"],
              this,
              node["params"] ?? Map<String, dynamic>.identity(),
            );
            refresh();
          },
          child: Text(node["text"]),
        );
      case ("Column"):
        return Column(
          children: [
            for (var child in node["children"])
              ParseUI(child, context, refresh: refresh),
          ],
        );
      case ("Row"):
        return Row(
          children: [
            for (var child in node["children"])
              ParseUI(child, context, refresh: refresh),
          ],
        );
      case ("ListView"):
        return ListView(
          children: [
            for (var child in node["children"])
              ParseUI(child, context, refresh: refresh),
          ],
        );
      case ("Expanded"):
        if (node["child"] != null) {
          return Expanded(
            child: ParseUI(node["child"], context, refresh: refresh),
          );
        } else
          return Expanded(child: Container());
    }
    return Container();
  }
}

class VideoNode extends StatefulWidget {
  final String url;
  VideoNode({super.key, required this.url});

  @override
  State<StatefulWidget> createState() => VideoNodeState();
}

class VideoNodeState extends State<VideoNode> {
  late VideoPlayerController vpController;
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    vpController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    vpController.initialize().then((_) {
      setState(() {
        initialized = true;
        vpController.addListener(() {
          setState(() {});
        });
        vpController.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized)
      return Center(child: SizedBox.square(child: CircularProgressIndicator(), dimension: 350,));

    return vpController.value.isInitialized
        ? GestureDetector(
            onTap: () {
              if (vpController.value.isPlaying)
                vpController.pause();
              else
                vpController.play();
            },
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: vpController.value.aspectRatio,
                    child: VideoPlayer(vpController),
                  ),
                ),
                vpController.value.isPlaying
                    ? Container()
                    : Center(child: Icon(Icons.play_arrow, size: 350)),
              ],
            ),
          )
        : Center(child: SizedBox.square(child: CircularProgressIndicator(), dimension: 350,));
  }

  @override
  void dispose() {
    super.dispose();
    vpController.dispose();
  }
}
