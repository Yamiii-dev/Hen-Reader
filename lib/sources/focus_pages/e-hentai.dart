import 'package:flutter/material.dart';
import 'package:hen_reader/sources/e-hentai.dart';
import 'package:hen_reader/sources/rule34.dart';
import 'package:url_launcher/url_launcher.dart';

class FocusPageEhentai extends StatefulWidget {
  final EhentaiPost post;
  const FocusPageEhentai({super.key, required this.post});

  @override
  State<StatefulWidget> createState() => FocusPageEhentaiState();
}

class FocusPageEhentaiState extends State<FocusPageEhentai> {
  bool isLoading = false;
  @override
  void initState() {
    super.initState();

    widget.post.nextUrl = "";

    nextImage();
  }

  Future nextImage() async {
    setState(() {
      isLoading = true;
    });
    await widget.post.GetNextImage();
    setState(() {
      widget.post.currentUrl = widget.post.currentUrl;
      isLoading = false;
    });
  }

  Future prevImage() async {
    setState(() {
      isLoading = true;
    });
    await widget.post.GetPrevImage();
    setState(() {
      widget.post.currentUrl = widget.post.currentUrl;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Row(
                  children: [
                    BackButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(child: Container()),
                    PopupMenuButton<int>(
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(value: 0, child: Text("Open Post")),
                      ],
                      onSelected: (value) => {
                        switch (value) {
                          0 => {
                            launchUrl(
                              widget.post.PostUrl(),
                              mode: LaunchMode.externalApplication,
                            ),
                          },

                          int() => throw UnimplementedError(),
                        },
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: widget.post.currentUrl != ""
                      ? Image.network(widget.post.currentUrl)
                      : Container(),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        prevImage();
                      },
                      icon: Icon(Icons.navigate_before),
                    ),
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {
                        nextImage();
                      },
                      icon: Icon(Icons.navigate_next),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if(isLoading)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator(),)
            )
        ],
      ),
    );
  }
}
