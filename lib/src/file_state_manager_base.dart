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

  /// * [f] : A managed file.
  /// This can be either a new empty file created by your application,
  /// or the file that was just loaded into the app.
  /// * [stackSize] : Maximum stack size.
  /// Any data exceeding this size will be discarded and no more undo will be
  /// possible. Specifying null will make it infinite,
  /// but considering memory consumption,
  /// I recommend setting it to an optimal finite value.
  FileStateManager(CloneableFile f, {required this.stackSize}) {
    push(f);
  }

  /// (en) Adds elements that have been changed.
  /// This involves a deep copy, which is expensive to process,
  /// so it should generally be run when the user has completed their operation.
  /// For example, running it in onPanEnd will make the app appear to run more
  /// smoothly.
  ///
  /// (ja) 変更が加えられた要素を追加します。
  /// 処理の重いディープコピーが発生するので、基本的にはユーザーの操作完了時に実行してください。
  /// 例えば、onPanEndなどで実行すると見かけ上のアプリの動作がスムーズになります。
  /// * [f] : 管理に含めたいデータ。内部でcloneされて保持されます。
  void push(CloneableFile f) {
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
}
