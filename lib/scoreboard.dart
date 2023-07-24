import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'model/player.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  List<Player> _playersList = [];
  bool _showTotals = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  //Loading counter value on start
  Future<void> _loadPlayers() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      _playersList = (sharedPref.getStringList('playersList') ?? [])
          .convertToPlayerInfoList();
    });
  }

  Future<void> _addScore(String? value, playerIndex, scoreIndex) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    var sharedPref = await SharedPreferences.getInstance();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _playersList[playerIndex].addScore(value, scoreIndex);
      });
      sharedPref.setStringList(
          'playersList', _playersList.convertToStringList());
    });
  }

  void _changeTotals() {
    setState(() {
      _showTotals = !_showTotals;
    });
  }

  void _clearScore() {
    setState(() {
      for (var player in _playersList) {
        player.clearScore();
      }
    });
  }

  TextEditingController _getOrCreateScore(playerIndex, scoreIndex) {
    if (scoreIndex > _playersList[playerIndex].score.length - 1) {
      _playersList[playerIndex].addScore('0', scoreIndex);
    }

    var value = _playersList[playerIndex].score[scoreIndex].toString();
    return TextEditingController(text: value);
  }

  void _addRow() async {
    var sharedPref = await SharedPreferences.getInstance();
    setState(() {
      _playersList.addScoreToAll();
    });
    sharedPref.setStringList('playersList', _playersList.convertToStringList());
  }

  List<DataRow> _dataRows() {
    var dataRows = List<DataRow>.generate(
      _playersList[0].score.length,
      (rowIndex) => DataRow(
        cells: List<DataCell>.generate(
            _playersList.length,
            (cellIndex) => DataCell(
                  TextFormField(
                    controller: _getOrCreateScore(cellIndex, rowIndex),
                    textAlign: TextAlign.center,
                    onChanged: (String? value) {
                      _addScore(value, cellIndex, rowIndex);
                    },
                    onFieldSubmitted: (String? value) {
                      _addScore(value, cellIndex, rowIndex);
                    },
                    keyboardType: TextInputType.number,
                  ),
                )),
      ),
    );
    if (_showTotals) {
      dataRows.add(DataRow(
        color: MaterialStateColor.resolveWith((states) => Colors.blue),
        cells: List<DataCell>.generate(
            _playersList.length,
            (cellIndex) => DataCell(Center(
                  child: Text(_playersList[cellIndex].total.toString(),
                      textAlign: TextAlign.center),
                ))),
      ));
    }
    return dataRows;
  }

  Widget _dataTable() {
    if (_playersList.isEmpty) {
      return const SingleChildScrollView();
    }
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            columns: List<DataColumn>.generate(
                _playersList.length,
                (columnIndex) => DataColumn(
                      label: Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      alignment: Alignment.center,
                                      image: AssetImage(
                                          _playersList[columnIndex].avatarPath),
                                      fit: BoxFit.contain),
                                ),
                                alignment: Alignment.bottomCenter,
                                child: Stack(
                                  children: <Widget>[
                                    // Stroked text as border.
                                    Text(
                                      _playersList[columnIndex].name,
                                      style: TextStyle(
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 6
                                          ..color = const Color(0xFF160F29),
                                      ),
                                    ),
                                    // Solid text as fill.
                                    Text(
                                      _playersList[columnIndex].name,
                                      style: TextStyle(
                                        color: const Color(0xFFF3DFC1),
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                    )),
            rows: _dataRows()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          _dataTable(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: _addRow, child: Text("Add row"))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() => _changeTotals()),
                      child: Text("Sum up"))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() => _clearScore()), child: Text("Clear")))
            ],
          )
        ],
      ),
    ));
  }
}
