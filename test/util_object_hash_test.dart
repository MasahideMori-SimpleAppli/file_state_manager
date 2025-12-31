import 'package:file_state_manager/file_state_manager.dart';
import 'package:test/test.dart';

void main() {
  group('UtilObjectHash', () {
    test('Old test', () {
      Map<String, String> m1 = {"a": "a"};
      Map<String, String> m2 = {"a": "a"};
      Map<String, String> m3 = {"a": "b"};
      Map<String, String> m4 = {"b": "a"};
      Map<String, String> m5 = {"a": "a", "b": "b"};
      expect(UtilObjectHash.calcMap(m1) == UtilObjectHash.calcMap(m2), true);
      expect(UtilObjectHash.calcMap(m1) == UtilObjectHash.calcMap(m3), false);
      expect(UtilObjectHash.calcMap(m1) == UtilObjectHash.calcMap(m4), false);
      expect(UtilObjectHash.calcMap(m1) == UtilObjectHash.calcMap(m5), false);
      Map<String, Map<String, int>> m6 = {
        "a": {"a": 1}
      };
      Map<String, Map<String, int>> m7 = {
        "a": {"a": 1}
      };
      Map<String, Map<String, int>> m8 = {
        "a": {"a": 2}
      };
      Map<String, Map<String, int>> m9 = {
        "b": {"a": 1}
      };
      Map<String, Map<String, int>> m10 = {
        "a": {"a": 1},
        "b": {"a": 1}
      };
      expect(UtilObjectHash.calcMap(m6) == UtilObjectHash.calcMap(m7), true);
      expect(UtilObjectHash.calcMap(m6) == UtilObjectHash.calcMap(m8), false);
      expect(UtilObjectHash.calcMap(m6) == UtilObjectHash.calcMap(m9), false);
      expect(UtilObjectHash.calcMap(m6) == UtilObjectHash.calcMap(m10), false);
      List<String> l1 = ["a"];
      List<String> l2 = ["a"];
      List<String> l3 = ["b"];
      List<String> l4 = ["a", "b"];
      expect(UtilObjectHash.calcList(l1) == UtilObjectHash.calcList(l2), true);
      expect(UtilObjectHash.calcList(l1) == UtilObjectHash.calcList(l3), false);
      expect(UtilObjectHash.calcList(l1) == UtilObjectHash.calcList(l4), false);
      List<List<int>> l6 = [
        [1]
      ];
      List<List<int>> l7 = [
        [1]
      ];
      List<List<int>> l8 = [
        [2]
      ];
      List<List<int>> l9 = [
        [1],
        [1]
      ];
      expect(UtilObjectHash.calcList(l6) == UtilObjectHash.calcList(l7), true);
      expect(UtilObjectHash.calcList(l6) == UtilObjectHash.calcList(l8), false);
      expect(UtilObjectHash.calcList(l6) == UtilObjectHash.calcList(l9), false);
      Set<String> s1 = {"a"};
      Set<String> s2 = {"a"};
      Set<String> s3 = {"b"};
      Set<String> s4 = {"a", "b"};
      expect(UtilObjectHash.calcSet(s1) == UtilObjectHash.calcSet(s2), true);
      expect(UtilObjectHash.calcSet(s1) == UtilObjectHash.calcSet(s3), false);
      expect(UtilObjectHash.calcSet(s1) == UtilObjectHash.calcSet(s4), false);
      Set<Set<int>> s6 = {
        {1}
      };
      Set<Set<int>> s7 = {
        {1}
      };
      Set<Set<int>> s8 = {
        {2}
      };
      Set<Set<int>> s9 = {
        {1},
        {1}
      };
      expect(UtilObjectHash.calcSet(s6) == UtilObjectHash.calcSet(s7), true);
      expect(UtilObjectHash.calcSet(s6) == UtilObjectHash.calcSet(s8), false);
      expect(UtilObjectHash.calcSet(s6) == UtilObjectHash.calcSet(s9), false);
    });

    test('Map hash is order-independent', () {
      final map1 = {
        'a': 1,
        'b': 2,
      };
      final map2 = {
        'b': 2,
        'a': 1,
      };

      expect(
        UtilObjectHash.calcMap(map1),
        equals(UtilObjectHash.calcMap(map2)),
      );
    });

    test('List hash is order-dependent', () {
      final list1 = [1, 2, 3];
      final list2 = [3, 2, 1];

      expect(
        UtilObjectHash.calcList(list1),
        isNot(equals(UtilObjectHash.calcList(list2))),
      );
    });

    test('Set hash is order-independent', () {
      final set1 = {1, 2, 3};
      final set2 = {3, 2, 1};

      expect(
        UtilObjectHash.calcSet(set1),
        equals(UtilObjectHash.calcSet(set2)),
      );
    });

    test('Nested structures produce consistent hash', () {
      final obj1 = {
        'list': [
          1,
          2,
          {'x': 10, 'y': 20}
        ],
        'set': {3, 4},
      };

      final obj2 = {
        'set': {4, 3},
        'list': [
          1,
          2,
          {'y': 20, 'x': 10}
        ],
      };

      expect(
        UtilObjectHash.calcMap(obj1),
        equals(UtilObjectHash.calcMap(obj2)),
      );
    });

    test('Different nested values produce different hash', () {
      final obj1 = {
        'a': [1, 2, 3],
      };

      final obj2 = {
        'a': [1, 2, 4],
      };

      expect(
        UtilObjectHash.calcMap(obj1),
        isNot(equals(UtilObjectHash.calcMap(obj2))),
      );
    });

    test('Null values are handled safely', () {
      final map1 = {'a': null};
      final map2 = {'a': null};

      expect(
        UtilObjectHash.calcMap(map1),
        equals(UtilObjectHash.calcMap(map2)),
      );
    });

    test('Primitive values fall back to hashCode', () {
      expect(
        UtilObjectHash.calcList([1, 'a', true]),
        equals(UtilObjectHash.calcList([1, 'a', true])),
      );
    });
  });
}
