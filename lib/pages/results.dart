import 'package:flutter/material.dart';

import "package:hen_reader/classes/post.dart";
import 'package:hen_reader/pages/settings.dart';
import 'package:hen_reader/sources/e-hentai.dart';
import 'package:hen_reader/sources/rule34.dart';
import 'package:system_theme/system_theme.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<StatefulWidget> createState() => ResultsPageState();
}

enum Source { rule34, ehentai }

class ResultsPageState extends State<ResultsPage> {
  late ScrollController gridControl;

  @override
  void initState() {
    super.initState();
    gridControl = ScrollController(initialScrollOffset: 5.0)
      ..addListener(gridListener);
  }

  String searchQuery = "";

  int currentPage = 0;

  List<Post> posts = List.empty();

  Rule34 r32API = Rule34();
  Ehentai ehentai = Ehentai();

  Source currentSource = Source.rule34;

  bool isLoading = false;

  void addPostsToList() async {
    List<Post> result = List.empty();
    if (currentSource == Source.rule34)
      result = await r32API.GetPosts(searchQuery, currentPage);
    else if (currentSource == Source.ehentai)
      result = await ehentai.GetMorePosts(searchQuery);
    currentPage++;
    setState(() {
      posts.addAll(result);
    });
  }

  Future search() async {
    setState(() {
      isLoading = true;
    });
    currentPage = 0;
    List<Post> result = List.empty();
    if (currentSource == Source.rule34)
      result = await r32API.GetPosts(searchQuery, currentPage);
    else if (currentSource == Source.ehentai)
      result = await ehentai.GetPosts(searchQuery);
    currentPage++;
    setState(() {
      posts = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: SystemTheme.accentColor.accent,
        actions: [
          IconButton(
            onPressed: () async {
              await search();
            },
            icon: Icon(Icons.search),
          ),
        ],
        title: TextField(
          onChanged: (searchText) => {
            setState(() {
              searchQuery = searchText;
            }),
          },
          onSubmitted: (_) async {
            await search();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text("Select Source:"),
            Divider(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                currentSource = Source.rule34;
                search();
                Navigator.pop(context);
              },
              child: Text("Rule34"),
            ),
            TextButton(
              onPressed: () {
                currentSource = Source.ehentai;
                search();
                Navigator.pop(context);
              },
              child: Text("E-Hentai"),
            ),
            Divider(),
            TextButton.icon(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));}, label: Text("Settings"), icon: Icon(Icons.settings))

          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              posts.isNotEmpty
                  ? Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350.0,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      posts[index].FocusBuilder(context),
                                ),
                              ),
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    posts[index].thumbnailUrl,
                                  ),
                                ),
                                Text(posts[index].title),
                              ],
                            ),
                          );
                        },
                        itemCount: posts.length,
                        controller: gridControl,
                      ),
                    )
                  : Container(),
            ],
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

  void gridListener() {
    if (gridControl.offset >= gridControl.position.maxScrollExtent &&
        !gridControl.position.outOfRange) {
      addPostsToList();
    }
  }
}
