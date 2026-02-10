import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    init();
  }

  TextEditingController r34control = TextEditingController();

  Map<String, List<String>> orderedSettings = {};

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    r34control.text = prefs.getString("Rule34API") ?? "";
    List<String> settings =
        prefs.getStringList("PluginSettings") ?? List.empty();
    for (var setting in settings) {
      final parts = setting.split("\u0001");
      final settingName = parts[0].trim();
      final pluginName = parts[1].trim();
      debugPrint(
        "pluginName=[$pluginName] len=${pluginName.length} codes=${pluginName.runes.toList()}",
      );
      orderedSettings.putIfAbsent(pluginName, () => []);
      orderedSettings[pluginName]!.add(settingName);
    }
    debugPrint(orderedSettings.keys.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          BackButton(),
          ExpansionTile(
            title: Text("Rule34"),
            children: [
              TextField(
                controller: r34control,
                decoration: const InputDecoration(labelText: "API Key"),
                onChanged: (value) => {prefs.setString("Rule34API", value)},
              ),
            ],
          ),
          for (var plugin in orderedSettings.keys)
            ExpansionTile(
              title: Text(plugin),
              children: [
                for (String setting in orderedSettings[plugin] ?? List.empty())
                  TextField(
                    controller: TextEditingController(
                      text: prefs.getString(setting + "\u0001" + plugin)
                    ),
                    decoration: InputDecoration(labelText: setting),
                    onChanged: (value) => {
                      prefs.setString(setting + "\u0001" + plugin, value),
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
