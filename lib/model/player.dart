import 'dart:convert';

class Player {
  late String name;
  late String avatarPath;
  late List<double> score;
  late bool isChecked;

  Player(this.name, this.avatarPath, this.score, {this.isChecked = false});

  double get total {
    return score.isNotEmpty ? score.reduce((value, element) => value + element) : 0;
  }

  Player.fromJson(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    name = jsonMap['name'];
    avatarPath = jsonMap['avatarPath'];
    isChecked = jsonMap['isChecked'];
    score = jsonMap['score']
        .toString()
        .split(';')
        .map((e) => double.tryParse(e) ?? 0)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarPath': avatarPath,
        'score': score.map((e) => e.toString()).join(';'),
        'isChecked': isChecked
      };

  void addScore(String? value, int index) {
    double number = double.parse(value!);
    if (index > score.length - 1) {
      score.add(number);
    } else {
      score[index] = number;
    }
  }

  void clearScore() {
    score = List.empty(growable: true);
  }
}

extension PlayerListExtension on List<Player> {
  List<String> convertToStringList() {
    final List<String> parsedPlayers = [];

    for (var player in this) {
      String json = jsonEncode(player);
      parsedPlayers.add(json);
    }

    return parsedPlayers;
  }

  void addScoreToAll() {
    forEach((element) {
      element.score.add(0);
    });
  }
}

extension StringListExtension on List<String> {
  List<Player> convertToPlayerInfoList() {
    final List<Player> parsedPlayers = [];

    for (var player in this) {
      parsedPlayers.add(Player.fromJson(player));
    }

    return parsedPlayers;
  }
}
