// The MIT License (MIT)
// Copyright (c) 2016 Steven Roose

library skiplist.test;

import 'package:test/test.dart';

import 'package:skiplist/skiplist.dart';

SkipList<int, int> sl;

void main() {
  group("regular map interface tests", () {
    test("isEmpty and isNotEmpty", () {
      sl = new SkipList();
      expect(sl.isEmpty, isTrue);
      expect(sl.isNotEmpty, isFalse);
      sl = new SkipList();
      sl[1] = null;
      expect(sl.isEmpty, isFalse);
      expect(sl.isNotEmpty, isTrue);
    });
    test("keys", () {
      var map = {1: 1, 5: 5, 2: 2, 4: 4};
      sl = new SkipList.fromMap(map);
      expect(sl.length, equals(map.length));
      expect(sl.keys, unorderedEquals(map.keys));
      var list = [1, 7, 2, 4, 8];
      sl = new SkipList.fromIterable(list);
      expect(sl.length, equals(list.length));
      expect(sl.keys, unorderedEquals(list));
    });
    test("values", () {
      var map = {1: 1, 5: 5, 2: 2, 4: 4};
      sl = new SkipList.fromMap(map);
      expect(sl.length, equals(map.length));
      expect(sl.values, unorderedEquals(map.values));
    });
    test("operator[]", () {
      var map = {1: 2, 5: 6, 2: 3, 4: 5};
      sl = new SkipList.fromMap(map);
      map.forEach((k, v) {
        expect(sl[k], equals(v));
      });
      expect(sl[9], isNull);
    });
    test("operator[]=", () {
      var map = {1: 2, 5: 6, 2: 3, 4: 5};
      sl = new SkipList();
      map.forEach((k, v) {
        expect(() => sl[k] = v, returnsNormally);
      });
      map.forEach((k, v) {
        expect(sl[k], equals(v));
      });
      expect(sl[9], isNull);
    });
    test("addAll", () {
      var map = {1: 2, 5: 6, 2: 3, 4: 5};
      sl = new SkipList();
      sl.addAll(map);
      map.forEach((k, v) {
        expect(sl[k], equals(v));
      });
      expect(sl[9], isNull);
    });
    test("clear", () {
      var map = {1: 2, 5: 6};
      sl = new SkipList.fromMap(map);
      expect(sl.length, equals(map.length));
      sl.clear();
      expect(sl.length, isZero);
      expect(sl.keys.length, isZero);
      expect(sl.values.length, isZero);
      expect(sl.containsKey(1), isFalse);
    });
    test("containsKey", () {
      var map = {1: 2, 5: 6};
      sl = new SkipList.fromMap(map);
      expect(sl.containsKey(1), isTrue);
      expect(sl.containsKey(7), isFalse);
    });
    test("containsValue", () {
      var map = {1: 2, 5: 6};
      sl = new SkipList.fromMap(map);
      expect(sl.containsValue(1), isFalse);
      expect(sl.containsValue(6), isTrue);
    });
    test("forEach", () {
      var map = {1: 2, 5: 6};
      sl = new SkipList.fromMap(map);
      int i = 0;
      sl.forEach((k, v) => i++);
      expect(i, equals(map.length));
    });
    test("putIfAbsent", () {
      var map = {1: 2, 5: 6};
      sl = new SkipList.fromMap(map);
      map.forEach((k, v) => sl.putIfAbsent(k, () => v));
      expect(sl.length, equals(map.length));
      sl.putIfAbsent(7, () => 8);
      expect(sl.length, equals(map.length + 1));
    });
    test("remove", () {
      var map = {1: 2, 5: 6, 2: 3, 4: 5};
      sl = new SkipList.fromMap(map);
      expect(sl.remove(2), equals(map[2]));
      expect(sl.length, equals(map.length - 1));
    });
  });
}
