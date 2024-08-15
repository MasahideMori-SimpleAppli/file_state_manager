import 'package:file_state_manager/file_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';

class ExampleClass extends CloneableFile {
  late int count;
  late ExampleClassChild child;

  ExampleClass(this.count, this.child);

  ExampleClass.fromDict(Map<String, dynamic> src) {
    count = src["count"];
    child = ExampleClassChild.fromDict(src["child"]);
  }

  @override
  ExampleClass clone() {
    return ExampleClass.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {"count": count, "child": child.toDict()};
  }

  @override
  bool operator ==(Object other) {
    if (other is ExampleClass) {
      return count == other.count && child == other.child;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll([count, child]);
  }
}

class ExampleClassChild extends CloneableFile {
  late String message;

  ExampleClassChild(this.message);

  ExampleClassChild.fromDict(Map<String, dynamic> src) {
    message = src["message"];
  }

  @override
  ExampleClass clone() {
    return ExampleClass.fromDict(toDict());
  }

  @override
  Map<String, dynamic> toDict() {
    return {"message": message};
  }

  @override
  bool operator ==(Object other) {
    if (other is ExampleClassChild) {
      return message == other.message;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll([message]);
  }
}

void main() {
  group('General test', () {
    test('Undo, Redo test', () {
      final saveFile = ExampleClass(0, ExampleClassChild("First State"));
      final fsm = FileStateManager(saveFile, stackSize: null);
      expect(fsm.canUndo(), false);
      saveFile.child.message = "Second State";
      fsm.push(saveFile);
      expect(fsm.canUndo(), true);
      expect(fsm.canRedo(), false);
      expect(fsm.redo() == null, true);
      expect(
          (fsm.undo()! as ExampleClass).child.message == "First State", true);
      expect(fsm.canRedo(), true);
      expect(
          (fsm.redo()! as ExampleClass).child.message == "Second State", true);
      fsm.undo();
      saveFile.child.message = "Third State";
      fsm.push(saveFile);
      expect(fsm.canUndo(), true);
      expect(
          (fsm.undo()! as ExampleClass).child.message == "First State", true);
      expect(fsm.canRedo(), true);
      expect(
          (fsm.redo()! as ExampleClass).child.message == "Third State", true);
      fsm.undo();
      expect(fsm.canUndo(), false);
      expect(fsm.undo() == null, true);
    });

    test('Stack size test', () {
      final saveFile = ExampleClass(0, ExampleClassChild("First State"));
      final fsm = FileStateManager(saveFile, stackSize: 2);
      saveFile.child.message = "Second State";
      fsm.push(saveFile);
      expect(fsm.canUndo(), true);
      expect(
          (fsm.undo()! as ExampleClass).child.message == "First State", true);
      expect(fsm.canRedo(), true);
      expect(
          (fsm.redo()! as ExampleClass).child.message == "Second State", true);
      saveFile.child.message = "Third State";
      fsm.push(saveFile);
      expect(fsm.canUndo(), true);
      expect(
          (fsm.undo()! as ExampleClass).child.message == "Second State", true);
      expect(fsm.canRedo(), true);
      expect(
          (fsm.redo()! as ExampleClass).child.message == "Third State", true);
      expect(fsm.canUndo(), true);
      expect(
          (fsm.undo()! as ExampleClass).child.message == "Second State", true);
      expect(fsm.canUndo(), false);
    });

    test('History restore test', () {
      final saveFile = ExampleClass(0, ExampleClassChild("First State"));
      final fsm = FileStateManager(saveFile, stackSize: 30);
      saveFile.child.message = "Second State";
      fsm.push(saveFile);

      // Save and restore the entire history.
      // Convert to map
      List<Map<String, dynamic>> history = [];
      for (CloneableFile i in fsm.getStack()) {
        history.add((i as ExampleClass).toDict());
      }
      // Restore from map
      List<ExampleClass> restoredHistory = [];
      for (Map<String, dynamic> i in history) {
        restoredHistory.add(ExampleClass.fromDict(i));
      }
      final restoredFSM =
          FileStateManager(restoredHistory.removeAt(0), stackSize: 30);
      for (ExampleClass i in restoredHistory) {
        restoredFSM.push(i);
      }

      // Check file
      ExampleClass restoredNowState = restoredFSM.now() as ExampleClass;
      // Second State
      expect(restoredNowState.child.message == "Second State", true);
      expect(restoredFSM.canUndo(), true);
      if (restoredFSM.canUndo()) {
        // First State
        expect(
            (restoredFSM.undo()! as ExampleClass).child.message ==
                "First State",
            true);
      }
    });

    test('enableDiffCheck test', () {
      // non enabled test
      final saveFile1 = ExampleClass(0, ExampleClassChild("First State"));
      final saveFile1Clone = saveFile1.clone();
      expect(saveFile1.hashCode == saveFile1Clone.hashCode, true);
      expect(saveFile1 == saveFile1Clone, true);
      final fsm1 = FileStateManager(saveFile1, stackSize: 30);
      saveFile1.child.message = "Second State";
      expect(saveFile1.hashCode == saveFile1Clone.hashCode, false);
      expect(saveFile1 == saveFile1Clone, false);
      fsm1.push(saveFile1);
      // same params object push
      final preIndex1 = fsm1.nowIndex();
      // Push without changes
      fsm1.push(saveFile1);
      expect(preIndex1 == fsm1.nowIndex(), false);
      // Push with changes
      saveFile1.child.message = "Third State";
      fsm1.push(saveFile1);
      expect(preIndex1 == fsm1.nowIndex(), false);

      // enabled test
      final saveFile2 = ExampleClass(0, ExampleClassChild("First State"));
      final fsm2 =
          FileStateManager(saveFile2, stackSize: 30, enableDiffCheck: true);
      saveFile2.child.message = "Second State";
      fsm2.push(saveFile2);
      // same params object push (invalid)
      final int preIndex2 = fsm2.nowIndex();
      // Push without changes
      fsm2.push(saveFile2);
      expect(preIndex2 == fsm2.nowIndex(), true);
      // Push with changes
      saveFile2.child.message = "Third State";
      fsm2.push(saveFile2);
      expect(preIndex2 == fsm2.nowIndex(), false);

      // Undo, Redo check
      expect(
          (fsm2.undo() as ExampleClass).child.message == "Second State", true);
      expect(
          (fsm2.redo() as ExampleClass).child.message == "Third State", true);
    });

    test('skip next test', () {
      final saveFile1 = ExampleClass(0, ExampleClassChild("First State"));
      final fsm1 = FileStateManager(saveFile1, stackSize: 30);
      expect(fsm1.nowIndex() == 0, true);
      saveFile1.child.message = "Second State";
      fsm1.push(saveFile1);
      expect(fsm1.nowIndex() == 1, true);
      saveFile1.child.message = "Third State";
      fsm1.skipNextPush();
      fsm1.push(saveFile1);
      expect(fsm1.nowIndex() == 1, true);
      fsm1.push(saveFile1);
      expect(fsm1.nowIndex() == 2, true);
    });
  });

  group('Util test', () {
    test('UtilObjectHash test', () {
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
  });
}
