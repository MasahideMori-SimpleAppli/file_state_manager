import 'package:file_state_manager/file_state_manager.dart';

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

  // Required if you want to set enableDiffCheck param to true.
  @override
  bool operator ==(Object other) {
    if (other is ExampleClass) {
      return count == other.count && child == other.child;
    } else {
      return false;
    }
  }

  // Required if you want to set enableDiffCheck param to true.
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

  // Required if you want to set enableDiffCheck param to true.
  @override
  bool operator ==(Object other) {
    if (other is ExampleClassChild) {
      return message == other.message;
    } else {
      return false;
    }
  }

  // Required if you want to set enableDiffCheck param to true.
  @override
  int get hashCode {
    return Object.hashAll([message]);
  }
}

void main() {
  // Undo, Redo.
  final saveFile = ExampleClass(0, ExampleClassChild("First State"));
  // Also enableDiffCheck param to true.
  final fsm = FileStateManager(saveFile, stackSize: 30, enableDiffCheck: true);
  saveFile.child.message = "Second State";
  fsm.push(saveFile);
  if (fsm.canUndo()) {
    // First State
    print((fsm.undo()! as ExampleClass).child.message);
  }
  if (fsm.canRedo()) {
    // Second State
    print((fsm.redo()! as ExampleClass).child.message);
  }

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
  final restoredFSM = FileStateManager(restoredHistory.removeAt(0),
      stackSize: 30, enableDiffCheck: true);
  for (ExampleClass i in restoredHistory) {
    restoredFSM.push(i);
  }

  // Check file
  ExampleClass restoredNowState = restoredFSM.now() as ExampleClass;
  // Second State
  print(restoredNowState.child.message);
  if (restoredFSM.canUndo()) {
    // First State
    print((restoredFSM.undo()! as ExampleClass).child.message);
  }
  // 0
  print(restoredFSM.nowIndex());
  // Push an object with the same parameters (invalid because diff checking is enabled)
  saveFile.child.message = "First State";
  restoredFSM.push(saveFile);
  // 0
  print(restoredFSM.nowIndex());

  // You can also explicitly disable the next push.
  restoredFSM.skipNextPush();
  saveFile.child.message = "Second State";
  // Invalid push
  restoredFSM.push(saveFile);
  // 0
  print(restoredFSM.nowIndex());
  // Valid push
  restoredFSM.push(saveFile);
  // 1
  print(restoredFSM.nowIndex());
}
