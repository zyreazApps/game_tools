import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_tools/utils/mathUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/player.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Player> _playersList = [];
  final _formKey = GlobalKey<FormState>();
  List<String> _avatarList = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  //Loading counter value on start
  Future<void> _loadPlayers() async {
    var sharedPref = await SharedPreferences.getInstance();
    _avatarList = await _getImages();
    setState(() {
      _playersList = (sharedPref.getStringList('playersList') ?? [])
          .convertToPlayerInfoList();
    });
  }

  void _createPlayer(String playerName) async {
    var sharedPref = await SharedPreferences.getInstance();
    final player = Player(playerName,
        _avatarList[MathUtils.getRandom(1, _avatarList.length)], []);
    setState(() {
      _playersList.add(player);
      sharedPref.setStringList(
          'playersList', _playersList.convertToStringList());
    });
  }

  void _removePlayers() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      _playersList.removeWhere((player) => player.isChecked);
      sharedPref.setStringList('playersList', _playersList.convertToStringList());
    });
  }

  Future<List<String>> _getImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) => key.contains('.png'))
        .toList();

    return imagePaths;
  }

  List<Widget> _createCards() {
    List<Widget> cardsList = [];
    for (var player in _playersList) {
      cardsList.add(_card(player));
    }
    return cardsList;
  }

  Widget _card(Player player) {
    return CheckboxListTile(
            value: player.isChecked,
            onChanged: (bool? value) {
              setState(() {
                player.isChecked = value!;
              });
            },
            secondary: Image.asset(player.avatarPath),
            title: Text(player.name),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add player',
            onPressed: () {
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  clipBehavior: Clip.none,
                  content: Stack(
                    children: <Widget>[
                      Positioned(
                        right: -40.0,
                        top: -40.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onSaved: (String? value) {
                                  _createPlayer(value!);
                                },
                                keyboardType: TextInputType.name,
                                decoration: const InputDecoration(
                                    labelText: "Player Name"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                child: const Text("Submit"),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState?.save();
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete player',
            onPressed: () {
              _removePlayers();
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: ListView.builder(
          itemCount: _playersList.length,
          itemBuilder: (context, index) {
            return _createCards()[index];
          }),
    );
  }
}
