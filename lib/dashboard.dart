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

  void _removePlayer(Player player) async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      _playersList.remove(player);
      sharedPref.setStringList(
          'playersList', _playersList.convertToStringList());
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
    return GestureDetector(
        onLongPress: () {
          setState(() {
            // Toggle light when tapped.
            _removePlayer(player);
          });
        },
        child: Card(
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(player.avatarPath), fit: BoxFit.cover),
                ),
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: <Widget>[
                    // Stroked text as border.
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline3!.fontSize,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = const Color(0xFF160F29),
                      ),
                    ),
                    // Solid text as fill.
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline3!.fontSize,
                        color: const Color(0xFFF3DFC1),
                      ),
                    ),
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
          ),
          shrinkWrap: true,
          itemCount: _playersList.length,
          itemBuilder: (context, index) {
            return _createCards()[index];
          }),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
