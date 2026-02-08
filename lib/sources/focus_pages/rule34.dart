
import 'package:flutter/material.dart';
import 'package:hen_reader/sources/rule34.dart';
import 'package:url_launcher/url_launcher.dart';

class FocusPageR34 extends StatefulWidget {
  final PostR34 post;
  const FocusPageR34({super.key, required this.post});

  @override
  State<StatefulWidget> createState() => FocusPageR34State();
}

class FocusPageR34State extends State<FocusPageR34> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( child: Column(
        children: [
          Row(children: [
            BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(child: Container()),
          PopupMenuButton<int>(itemBuilder: (context) => [
            PopupMenuItem<int>(value: 0, child: Text("Open Post"))
          ],
          onSelected: (value) => {
            switch(value){
              0 => {
                launchUrl(widget.post.PostUrl(), mode: LaunchMode.externalApplication)
              },

              int() => throw UnimplementedError(),
            }
          },)
          ],),
          Expanded(
            child: Image.network(widget.post.fileUrl, fit: BoxFit.contain,),
          ),
          /*Row(children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.navigate_before)),
            Expanded(child: Container()),
            IconButton(onPressed: () {}, icon: Icon(Icons.navigate_next))
          ],)*/
        ],
      ),
      )
    );
  }
}
