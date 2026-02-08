import 'package:flutter/material.dart' hide Element;
import 'package:hen_reader/classes/post.dart';
import 'package:hen_reader/sources/focus_pages/e-hentai.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';

class Ehentai {
  Ehentai();

  Uri nextUrl = Uri.parse("");

  Future<List<EhentaiPost>> ParseGallery(Response res) async {
    List<EhentaiPost> result = List.empty(growable: true);
    if (res.statusCode == 200) {
      {
        String href = "";
        String name = "";
        String thumb = "";
        Document doc = parse(res.body);

        List<Element> rows = doc.querySelectorAll("table.itg tr");

        for (var row in rows) {
          Element? td2c = row.querySelector("td.gl2c");
          if (td2c != null) {
            thumb =
                td2c.querySelector("div.glthumb img")?.attributes["data-src"] ??
                "";
            if (thumb.isEmpty) {
              thumb =
                  td2c.querySelector('div.glthumb img')?.attributes['src'] ??
                  '';
            }

            name = row.querySelector("td.gl3c a div.glink")?.text ?? "";
            href = row.querySelector("td.gl3c a")?.attributes["href"] ?? "";

            if (href.isNotEmpty) {
              //pageLink = doc.selectFirst(".gt200")?.selectFirst("a")?.attr("href") ?: ""
              Response res2 = await get(Uri.parse(href));

              Document doc = parse(res2.body);

              Element? gt200 = doc.querySelector(".gt200");
              if (gt200 != null) {
                String pageLink =
                    gt200.querySelector("a")?.attributes["href"] ?? "";
                result.add(
                  EhentaiPost(
                    postTitle: name,
                    href: pageLink,
                    thumbnail: thumb,
                  ),
                );
              }
            }
          }
        }

        String nextGallery =
            doc.querySelector("#dnext")?.attributes["href"] ?? "";
        nextUrl = Uri.parse(nextGallery);
      }
    }

    return result;
  }

  Future<List<EhentaiPost>> GetPosts(String searchQuery) async {
    List<EhentaiPost> result = List.empty(growable: true);
    String input = searchQuery.replaceAll(" ", "+");

    Uri gallery = Uri.parse(
      "https://e-hentai.org/?f_search=$input+-other%3A+ai_generated",
    );

    Response res = await get(gallery);

    result = await ParseGallery(res);

    return result;
  }

  Future<List<EhentaiPost>> GetMorePosts(String searchQuery) async {
    List<EhentaiPost> result = List.empty(growable: true);

    Uri gallery = nextUrl;

    Response res = await get(gallery);

    result = await ParseGallery(res);

    return result;
  }
}

class EhentaiPost extends Post {
  final String postTitle;
  final String href;
  final String thumbnail;
  EhentaiPost({
    required this.postTitle,
    required this.href,
    required this.thumbnail,
  });

  String nextUrl = "";
  String currentUrl = "";
  String prevUrl = "";

  @override
  Uri PostUrl() {
    return Uri.parse(href);
  }

  @override
  String get thumbnailUrl => thumbnail;

  @override
  String get title => postTitle;

  @override
  Widget FocusBuilder(BuildContext) => FocusPageEhentai(post: this);

  Future GetNextImage() async{
    /*var doc = Ksoup.parseGetRequest(url)

        val sn = doc.selectFirst("div.sn")?.selectFirst("div")

        pageCount.value = (sn?.select("span")?.lastOrNull()?.text() ?: "0").toInt()

        nextPage.value = doc.select("#next")?.attr("href") ?: ""
        prevPage.value = doc.select("#prev")?.attr("href") ?: ""

        currentPage.value = doc.select("#img")?.attr("src")?.replace("webp", "gif") ?: ""*/
    if(nextUrl == "") nextUrl = href;

    Response res = await get(Uri.parse(nextUrl));

    Document doc = parse(res.body);

    Element? sn = doc.querySelector("div.sn")?.querySelector("div");
    if(sn != null){
      nextUrl = doc.querySelector("#next")?.attributes["href"] ?? "";
      prevUrl = doc.querySelector("#prev")?.attributes["href"] ?? "";

      currentUrl = doc.querySelector("#img")?.attributes["src"]?.replaceFirst("webp", "gif") ?? "";
    }
  }

  Future GetPrevImage() async{
    /*var doc = Ksoup.parseGetRequest(url)

        val sn = doc.selectFirst("div.sn")?.selectFirst("div")

        pageCount.value = (sn?.select("span")?.lastOrNull()?.text() ?: "0").toInt()

        nextPage.value = doc.select("#next")?.attr("href") ?: ""
        prevPage.value = doc.select("#prev")?.attr("href") ?: ""

        currentPage.value = doc.select("#img")?.attr("src")?.replace("webp", "gif") ?: ""*/
    if(prevUrl == "") prevUrl = href;

    Response res = await get(Uri.parse(prevUrl));

    Document doc = parse(res.body);

    Element? sn = doc.querySelector("div.sn")?.querySelector("div");
    if(sn != null){
      nextUrl = doc.querySelector("#next")?.attributes["href"] ?? "";
      prevUrl = doc.querySelector("#prev")?.attributes["href"] ?? "";

      currentUrl = doc.querySelector("#img")?.attributes["src"]?.replaceFirst("webp", "gif") ?? "";
    }
  }
}
