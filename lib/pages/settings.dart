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

  Future init() async {
    prefs = await SharedPreferences.getInstance();
    r34control.text = prefs.getString("Rule34API") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          BackButton(),
          TextField(
            controller: r34control,
            decoration: const InputDecoration(labelText: "Rule34 API Key"),
            onChanged: (value) => {prefs.setString("Rule34API", value)},
          )
        ],
      ),
    );
  }
}
