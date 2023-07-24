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
    dataRows.add(DataRow(
      color: MaterialStateColor.resolveWith((states) => Colors.grey),
      cells: List<DataCell>.generate(
          _playersList.length,
          (cellIndex) => DataCell(Center(
                child: Text(
                  _playersList[cellIndex].total.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ))),
    ));

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
                                    alignment: Alignment.topCenter,
                                    image: AssetImage(
                                        _playersList[columnIndex].avatarPath),
                                    fit: BoxFit.fitWidth),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: Text(_playersList[columnIndex].name))
                        ],
                      ),
                    ),
                  )),
          rows: _dataRows()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add player',
              onPressed: _addRow,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete score',
              onPressed: () {
                _clearScore();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _dataTable(),
            ],
          ),
        ));
  }
}
