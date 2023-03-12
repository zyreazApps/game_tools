import 'dart:math';

class MathUtils {
  static int getRandom(int min, int max) {
    return min + Random().nextInt((max + 1) - min);
  }
}