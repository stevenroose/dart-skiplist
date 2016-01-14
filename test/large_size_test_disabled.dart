// The MIT License (MIT)
// Copyright (c) 2016 Steven Roose

library skiplist.test;

import "dart:math";

import 'package:test/test.dart';

import 'package:skiplist/skiplist.dart';

SkipList<int, int> sl;
Random random = new Random();

/// These tests ar disabled by default because they take rather long to run.
void main() {
  group("large size test", () {
    test("1000x 9000 elements", () {
      Stopwatch stopwatch = new Stopwatch()..start();
      int nbRuns = 1000;
      while (nbRuns-- >= 0) {
        sl = new SkipList<int, int>();
        sl[333] = null;
        for(int i = 0; i < 10000; i++) {
          sl[random.nextInt(9000)] = null;
        }
        expect(sl.length, lessThanOrEqualTo(9000));
        expect(sl.keys.length, lessThanOrEqualTo(9000));
        expect(sl.containsKey(333), isTrue);
      }
      stopwatch.stop();
      print("Elapsed time: ${stopwatch.elapsed}");
    });
    test("25x 65536 items p=1/4 maxLevel=default", () {
      Stopwatch stopwatch = new Stopwatch()..start();
      int nbRuns = 1000;
      while (nbRuns-- >= 0) {
        sl = new SkipList(p:1/4);
        sl[65536] = null;
        for(int i = 0; i < 65536; i++) {
          sl[random.nextInt(4294967296)] = null;
        }
        expect(sl.length, lessThanOrEqualTo(65536 + 1));
        expect(sl.containsKey(65536), isTrue);
      }
      stopwatch.stop();
      print("Elapsed time: ${stopwatch.elapsed}");
    });
    test("25x 65536 items p=1/4 maxLevel=10", () {
      Stopwatch stopwatch = new Stopwatch()..start();
      int nbRuns = 1000;
      while (nbRuns-- >= 0) {
        sl = new SkipList(p:1/4, maxLevel: 10);
        sl[65536] = null;
        for(int i = 0; i < 65536; i++) {
          sl[random.nextInt(4294967296)] = null;
        }
        expect(sl.length, lessThanOrEqualTo(65536 + 1));
        expect(sl.containsKey(65536), isTrue);
      }
      stopwatch.stop();
      print("Elapsed time: ${stopwatch.elapsed}");
    });
  });
}
