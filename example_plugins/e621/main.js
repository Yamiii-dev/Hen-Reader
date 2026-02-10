async function search(searchQuery, currentPage) {
  var searchEdited = searchQuery.replace(" ", "+");
  var apiKey = await getSetting("API key");
  var login = await getSetting("Login");
  var url = "https://e621.net/posts.json?tags=" +
      searchEdited +
      "&page=" +
      (currentPage + 1) +
      "&limit=50" +
      "&api_key=" +
      apiKey +
      "&login="+
      login;
  console.log(url);
  var json = await getJson(
    url
  );
  var obj = [];
  if (!json["posts"] || !Array.isArray(json["posts"])) return [];
  for (var i of json["posts"]) {
    obj.push({
      title: i["id"].toString(),
      thumb: i["preview"]["url"],
      focusImage: i["file"]["url"],
    });
  }
  return obj;
}
