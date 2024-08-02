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
      // Undo, Redo.
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
  });
}
