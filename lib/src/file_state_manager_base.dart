import 'package:file_state_manager/file_state_manager.dart';

/// (en) This is a manager class that allows you to Undo and Redo
/// complex file changes.
/// It is suitable for managing the data saved by an application.
/// However, please note that it is not suitable for tracking detailed changes,
/// such as tracking only specific variables.
///
/// (ja) 複雑なファイルの変更をUndo,Redoできるようにするためのマネージャクラスです。
/// これはアプリケーションで保存されるデータ全体の管理に適しています。
/// ただし、特定の変数だけの追跡など、細かい変更の追跡には不向きなので注意してください。
class FileStateManager {
  final List<CloneableFile> _urStack = [];
  int _nowIndex = -1;
  final int? stackSize;
  final bool enableDiffCheck;
  bool _skipNext = false;

  /// * [f] : A managed file.
  /// This can be either a new empty file created by your application,
  /// or the file that was just loaded into the app.
  /// * [stackSize] : Maximum stack size.
  /// Any data exceeding this size will be discarded and no more undo will be
  /// possible. Specifying null will make it infinite,
  /// but considering memory consumption,
  /// I recommend setting it to an optimal finite value.
  /// * [enableDiffCheck] : The initial value is false.
  /// If true, When you call push, an equals comparison is done to see if
  /// a change occurred.
  /// If you enable this, you must also override the == operator and hashCode
  /// of the managed classes of this manager.
  FileStateManager(CloneableFile f,
      {required this.stackSize, this.enableDiffCheck = false}) {
    push(f);
  }

  /// (en) Adds elements that have been changed.
  /// This involves a deep copy, which is expensive to process,
  /// so it should generally be run when the user has completed their operation.
  /// For example, running it in onPanEnd will make the app appear to run more
  /// smoothly.
  /// If enableDiffCheck is true, pushing the non changed data will have no effect.
  /// After skipNextPush is called, the first push is disabled.
  ///
  /// (ja) 変更が加えられた要素を追加します。
  /// 処理の重いディープコピーが発生するので、基本的にはユーザーの操作完了時に実行してください。
  /// 例えば、onPanEndなどで実行すると見かけ上のアプリの動作がスムーズになります。
  /// enableDiffCheckがtrueの場合、変更の無いデータをpushしても何も起こりません。
  /// skipNextPushが呼び出された後の、１回目のpushは無効化されます。
  ///
  /// * [f] : Data you want to include in the management.
  /// It will be cloned and stored internally.
  void push(CloneableFile f) {
    if (_skipNext) {
      _skipNext = false;
      return;
    }
    if (enableDiffCheck) {
      if (_urStack.isNotEmpty) {
        if (_urStack[_nowIndex] == f) {
          return;
        }
      }
    }
    final clonedData = f.clone();
    // スタック内に収まるように調整。
    if (stackSize == null) {
      _nowIndex++;
    } else {
      if (_nowIndex < stackSize! - 1) {
        _nowIndex++;
      } else {
        _urStack.removeAt(0);
      }
    }
    // 新しいデータを追加し、以降のデータがあれば削除する。
    _urStack.insert(_nowIndex, clonedData);
    for (int i = _urStack.length - 1; i > _nowIndex; i--) {
      _urStack.removeAt(i);
    }
  }

  /// (en) Calling this will disable the next push.
  /// This can be used as an alternative to enableDiffCheck parameter
  /// when dealing with large files where comparisons are expensive.
  ///
  /// (ja) これを呼び出すと、次回のpushが無効化されます。
  /// これは比較にコストのかかる大きなファイルを扱う場合、
  /// enableDiffCheckパラメータの代替として利用できます。
  void skipNextPush() {
    _skipNext = true;
  }

  /// (en) Returns true only if Undo is possible.
  ///
  /// (ja) Undo可能な場合のみtrueを返します。
  bool canUndo() {
    return _urStack.length >= 2 && _nowIndex >= 1;
  }

  /// (en) Returns true only if Redo is possible.
  ///
  /// (ja) Redo可能な場合のみtrueを返します。
  bool canRedo() {
    return _nowIndex < _urStack.length - 1;
  }

  /// (en) Returns the previously pushed data. If there is no data, returns null.
  /// A deep copy is performed on the return object before it is returned.
  ///
  /// (ja) １つ前にpushされたデータを返します。データが無い場合はnullを返します。
  /// 返されるオブジェクトはディープコピーが実行されてから返却されます。
  CloneableFile? undo() {
    if (canUndo()) {
      _nowIndex -= 1;
      return _urStack[_nowIndex].clone();
    } else {
      return null;
    }
  }

  /// (en) Returns the next pushed data. If there is no data, returns null.
  /// A deep copy is performed on the return object before it is returned.
  ///
  /// (ja) １つ後にpushされたデータを返します。データが無い場合はnullを返します。
  /// 返されるオブジェクトはディープコピーが実行されてから返却されます。
  CloneableFile? redo() {
    if (canRedo()) {
      _nowIndex += 1;
      return _urStack[_nowIndex].clone();
    } else {
      return null;
    }
  }

  /// (en) Returns the now data.
  /// A deep copy is performed on the return object before it is returned.
  ///
  /// (ja) 現在のデータを返します。
  /// 返されるオブジェクトはディープコピーが実行されてから返却されます。
  CloneableFile? now() {
    return _urStack[_nowIndex].clone();
  }

  /// (en) Returns the current index into the stack.
  ///
  /// (ja) 現在スタックのどこを参照しているのかという、インデックスを返します。
  int nowIndex() {
    return _nowIndex;
  }

  /// (en)　Returns a reference to the stack maintained by this class.
  /// This can be useful if you want to save the entire history.
  ///
  /// (ja) このクラスで保持しているスタックの参照を返します。
  /// これは履歴全体を保存したいような場合に利用できます。
  List<CloneableFile> getStack() {
    return _urStack;
  }
}
