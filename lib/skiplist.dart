// The MIT License (MIT)
// Copyright (c) 2016 Steven Roose

/// The dart_skiplist library.
///
/// This is an awesome library. More dartdocs go here.
library skiplist;

import "dart:collection";
import "dart:math";

import "package:quiver_iterables/iterables.dart" as iterables;

final _SkipListEntry _NIL = new _NilEntry();
final Random _random = new Random();

/// This class provides an implementation of skip lists, as they are described
/// in William Pugh's paper "Skip Lists: A probabilistic Alternative to
/// Balanced Trees".
///
/// Skip lists are a data structure that can be used in place of balanced trees.
/// Skip lists use probabilistic balancing rather than strictly enforced
/// balancing and as a result the algorithms for insertion and deletion in skip
/// lists are much simpler and significantly faster than equivalent algorithms
/// for balanced trees.
///
/// Skip lists have fast search by key, insert, update and delete operations,
/// all having a time complexity of O(log n).
/// All other type of operations are usually very bad.
///
/// This class implements Map, but can just as easily be used as a Set by
/// putting in null elements.
///
/// The implementation is largely based on the suggested implementation from
/// the paper. Also the configuration parameters are the same.
class SkipList<K extends Comparable, V> extends MapBase<K, V>
    implements Map<K, V> {
  final double p;
  final int maxLevel;

  int _size;
  int _level; // starts at 0
  _SkipListEntry _header;

  /// Create a skip list by specifying it's configuration parameters.
  ///
  /// Using the default values is safe and has a capacity of 65 536 elements.
  SkipList({double this.p: 1 / 4, int this.maxLevel: 8}) {
    _init();
  }
  static const _DEFAULT_CAPACITY = 65536;

  /// Create a skip list with maximum size [capacity].
  factory SkipList.withCapacity(int capacity) =>
      new SkipList(p: 1 / 4, maxLevel: _bigL(capacity, 1 / 4));

  /// Create a skip list and add all elements from [from] to it.
  factory SkipList.fromMap(Map<K, V> from) =>
      new SkipList.withCapacity(max(_DEFAULT_CAPACITY, from.length))
        ..addAll(from);

  /// Create a skip list and add all elements from [from] to it.
  factory SkipList.fromIterable(Iterable<K> from) {
    SkipList skiplist =
        new SkipList.withCapacity(max(_DEFAULT_CAPACITY, from.length));
    from.forEach((e) => skiplist[e] = null);
    return skiplist;
  }

  void _init() {
    _header = new _HeaderEntry(maxLevel);
    _level = 0;
    _size = 0;
  }

  @override
  V operator [](K key) {
    if (key == null) {
      throw new ArgumentError.notNull("key");
    }
    _SkipListEntry x = _findElementOrAfter(key);
    if (x != null && x.key == key) {
      return x.value;
    } else {
      // element not in skiplist
      return null;
    }
  }

  @override
  bool containsKey(K key) {
    if (key == null) {
      throw new ArgumentError.notNull("key");
    }
    _SkipListEntry x = _findElementOrAfter(key);
    return x != null && x.key == key;
  }

  @override
  void operator []=(K key, V value) {
    if (key == null) {
      throw new ArgumentError.notNull("key");
    }
    List<_SkipListEntry> update = new List.filled(_level + 2, _header);
    _SkipListEntry x = _findElementOrAfter(key, update);
    if (x.key != null && x.key == key) {
      // element in the list, update value
      x.value = value;
    } else {
      // element not in the list, insert new element
      _addElement(key, value, update);
    }
  }

  @override
  V remove(K key) {
    if (key == null) {
      throw new ArgumentError.notNull("key");
    }
    List<_SkipListEntry> update = new List.filled(_level + 2, _header);
    _SkipListEntry x = _findElementOrAfter(key, update);
    if (x.key != null && x.key == key) {
      for (int i = 0; i <= _level; i++) {
        if (update[i].pointers[i] != x) {
          break;
        }
        update[i].pointers[i] = x.pointers[i];
      }
      // update list level in case we removed the only element of highest level
      while (_level > 0 && _header.pointers[_level] == null) {
        _level--;
      }
      _size--;
      return x.value;
    } else {
      return null;
    }
  }

  @override
  V putIfAbsent(K key, V isAbsent()) {
    if (key == null) {
      throw new ArgumentError.notNull("key");
    }
    List<_SkipListEntry> update = new List.filled(_level + 2, _header);
    _SkipListEntry x = _findElementOrAfter(key, update);
    if (x.key != null && x.key == key) {
      // element already in the list, return it
      return x.value;
    } else {
      // element not in the list, insert new element
      V value = isAbsent();
      _addElement(key, value, update);
      return value;
    }
  }

  @override
  void clear() => _init();

  @override
  int get length => _size;

  @override
  bool containsValue(V value) => _entries.any((e) => e.value == value);

  @override
  Iterable<K> get keys => _entries.map((e) => e.key);

  @override
  void forEach(void action(K key, V value)) =>
      _entries.forEach((e) => action(e.key, e.value));

  /// HELPER METHODS

  /// An iterator over all elements in this list.
  Iterable<_SkipListEntry> get _entries {
    if (_size == 0) {
      return [];
    } else {
      return iterables.generate(() => _header.pointers[0], (e) {
        var point = e.pointers[0];
        return point == _NIL ? null : point;
      });
    }
  }

  /// The search algorithm
  _SkipListEntry _findElementOrAfter(K key, [List<_SkipListEntry> update]) {
    if (_size == 0) {
      return _NIL;
    }
    _SkipListEntry x = _header;
    // Optimal to start searching at L(n).
    // If L(n) exceeds maxLevel, the size of this list is too large.
    int i = _size == 0 ? 0 : min(_level, _bigL(_size, p));
    while (i >= 0) {
      while (x.pointers[i].compareTo(key) < 0) {
        x = x.pointers[i];
      }
      if (update != null) {
        update[i] = x;
      }
      i--;
    }
    // Now it should be the largest element smaller than key
    assert(x.compareTo(key) < 0 && x.pointers[0].compareTo(key) >= 0);
    return x.pointers[0];
  }

  /// Add an element with elements in [update] pointing to it.
  void _addElement(K key, V value, List<_SkipListEntry> update) {
    int level = _newLevel();
    var entry =
        new _SkipListEntry(key, value, new List<_SkipListEntry>(level + 1));
    for (int i = 0; i <= level; i++) {
      if (i > _level  +2) { //remove!
        entry.pointers[i] = _header.pointers[i];
        _header.pointers[i] = entry;
      } else {
        entry.pointers[i] = update[i].pointers[i];
        update[i].pointers[i] = entry;
      }
    }
    _level = max(_level, level);
    _size++;
  }

  /// We define L(n) = log_{1/p}(n)
  static int _bigL(int n, double p) => (log(n) / log(1 / p)).ceil();

  /// Returns a new level in [0, _level+1].
  /// p is used repeatedly as the chance of going one level higher.
  int _newLevel() {
    int level = 0;
    while (_random.nextDouble() < p && level <= _level) {
      level++;
    }
    assert(0 <= level && level <= _level + 1);
    return min(level, maxLevel - 1);
  }
}

class _SkipListEntry<K extends Comparable, V> implements Comparable {
  final K key;
  V value;
  final List<_SkipListEntry> pointers;
  _SkipListEntry(this.key, this.value, this.pointers);

  @override
  int compareTo(other) {
    if (other == _NIL) {
      return -1;
    }
    K otherKey = other is _SkipListEntry ? other.key : other;
    return Comparable.compare(key, otherKey);
  }

  @override
  String toString() => "ENTRY at $key";
}

class _HeaderEntry extends _SkipListEntry {
  _HeaderEntry(int maxLevel)
      : super(null, null, new List.filled(maxLevel, _NIL));
  /// The header entry is smaller than any other element
  @override
  int compareTo(other) => -1;
  @override
  String toString() => "HEADER";
}

class _NilEntry extends _SkipListEntry {
  _NilEntry() : super(null, null, null);
  /// The NIL entry is larger any other element
  @override
  int compareTo(other) => 1;
  @override
  String toString() => "NIL";
}
