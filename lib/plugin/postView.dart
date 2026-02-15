import 'package:flutter/material.dart';
import 'package:hen_reader/plugin/post.dart';
import 'package:video_player/video_player.dart';

class PluginPostFocusView extends StatefulWidget {
  final PluginPost post;

  const PluginPostFocusView({Key? key, required this.post}) : super(key: key);

  @override
  _PluginPostFocusViewState createState() => _PluginPostFocusViewState();
}

class _PluginPostFocusViewState extends State<PluginPostFocusView> {
  late VideoPlayerController vpController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                BackButton(onPressed: () {
                  Navigator.pop(context);
                }),
              ],
            ),
            Expanded(
              child: widget.post.ParseUI(widget.post.UI, context, refresh: () => setState(() {})),
            ),
          ],
        ),
      ),
    );
  }
}
