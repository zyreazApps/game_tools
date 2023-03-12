import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? countdownTimer;
  Duration myDuration = const Duration();
  Duration savedDuration = const Duration();
  var hours = TextEditingController(text: "00");
  var minutes = TextEditingController(text: "00");
  var seconds = TextEditingController(text: "00");

  void _createDuration() {
    setState(() {
      myDuration = Duration(
          hours: int.parse(hours.text),
          minutes: int.parse(minutes.text),
          seconds: int.parse(seconds.text));
    });
  }

  void _startTimer() {
    savedDuration = myDuration;
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void _stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void _resetCountdown() {
    _stopTimer();
    setState(() {
      myDuration = savedDuration;

      hours.text = myDuration.inHours.toString().padLeft(2, '0');
      minutes.text = myDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
      seconds.text = myDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
  });
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final reducedSeconds = myDuration.inSeconds - reduceSecondsBy;
      if (reducedSeconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: reducedSeconds);
      }

      hours.text = myDuration.inHours.toString().padLeft(2, '0');
      minutes.text = myDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
      seconds.text = myDuration.inSeconds.remainder(60).toString().padLeft(2, '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: <Widget>[
                Expanded(
                    child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9]?\d')),
                  ],
                  controller: hours,
                  textAlign: TextAlign.center,
                  onFieldSubmitted: (String value) {
                    hours.text = value;
                    _createDuration();
                  },
                  keyboardType: TextInputType.number,
                )),
                const Text(":"),
                Expanded(
                    child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-5]?\d')),
                  ],
                  controller: minutes,
                  textAlign: TextAlign.center,
                  onFieldSubmitted: (String value) {
                    minutes.text = value;
                    _createDuration();
                  },
                  keyboardType: TextInputType.number,
                )),
                const Text(":"),
                Expanded(
                    child: TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-5]?\d')),
                  ],
                  controller: seconds,
                  textAlign: TextAlign.center,
                  onFieldSubmitted: (String value) {
                    seconds.text = value;
                    _createDuration();
                  },
                  keyboardType: TextInputType.number,
                ))
              ],
            ),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: (() => _startTimer()), child: Text("Start"))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      ElevatedButton(onPressed: (() => _stopTimer()), child: Text("Stop"))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      ElevatedButton(onPressed: (() => _resetCountdown()), child: Text("Reset")))
            ],
          )
          ],
        ),
      ),
    );
  }
}
