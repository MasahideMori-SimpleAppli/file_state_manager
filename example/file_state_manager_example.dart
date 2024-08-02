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
  final saveFile = ExampleClass(0, ExampleClassChild("First State"));
  final fsm = FileStateManager(saveFile, stackSize: null);
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
}
