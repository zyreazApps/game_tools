import 'package:flutter/material.dart';
import 'utils/mathUtils.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  int _randomValue = 0;

  void _throwDice() async {
    var numberOfDiceRotation = MathUtils.getRandom(10, 60);
    for (var i = 0; i < numberOfDiceRotation; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      setState(() {
        _randomValue = MathUtils.getRandom(1, 6);
      });
    }
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _randomValue = MathUtils.getRandom(1, 6);
    });

    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _randomValue = MathUtils.getRandom(1, 6);
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _randomValue = MathUtils.getRandom(1, 6);
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _randomValue = MathUtils.getRandom(1, 6);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_randomValue',
              style: Theme.of(context).textTheme.headline1,
            ),
            ElevatedButton(
              onPressed: _throwDice,
              child: const Text('Throw the dice!'),
            ),
          ],
        ),
      ),
    );
  }
}