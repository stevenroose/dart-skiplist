// The MIT License (MIT)
// Copyright (c) 2016 Steven Roose

library skiplist.test;

import "dart:math";

import 'package:test/test.dart';

import 'package:skiplist/skiplist.dart';

SkipList<int, int> sl;

void main() {
  group("constructors", () {
    test("SkipList()", () {
      sl = new SkipList();
      expect(sl.length, isZero);
      var p = 1 / 2;
      var maxLevel = 16;
      sl = new SkipList(p: p, maxLevel: maxLevel);
      expect(sl.p, equals(p));
      expect(sl.maxLevel, equals(maxLevel));
    });
    test("SkipList.capacity()", () {
      var p = 1 / 2;
      var maxLevel = 16;
      sl = new SkipList.withCapacity(pow((1 / p), maxLevel).round());
      expect(sl.length, isZero);
      expect(pow((1 / sl.p), sl.maxLevel), equals(pow((1 / p), maxLevel)));
    });
    test("SkipList.fromMap()", () {
      var map = {1: 1, 2: 2, 4: 4};
      sl = new SkipList.fromMap(map);
      expect(sl.length, equals(map.length));
      map.forEach((k, v) {
        expect(sl.containsKey(k), isTrue);
        expect(sl.containsValue(v), isTrue);
        expect(sl[k], equals(v));
      });
    });
    test("SkipList.fromIterable()", () {
      var list = [1, 2, 4];
      sl = new SkipList.fromIterable(list);
      expect(sl.length, equals(list.length));
      list.forEach((k) {
        expect(sl.containsKey(k), isTrue);
      });
    });
  });
}
