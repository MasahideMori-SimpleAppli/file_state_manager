/// (en) An abstract class that has deep copy and serialization capabilities
/// and is managed by the FileStateManager.
///
/// (ja) ディープコピーとシリアライズの機能を持ち、FileStateManagerで管理される抽象クラス。
abstract class CloneableFile {
  /// Normal constructor.
  CloneableFile();

  /// (en) Restore this object from the dictionary.
  ///
  /// (ja) このオブジェクトを辞書から復元します。
  ///
  /// * [src] : A dictionary made with toDict of this class.
  factory CloneableFile.fromDict(Map<String, dynamic> src) {
    throw UnimplementedError();
  }

  /// (en) Returns a deep copy of this object.
  ///
  /// (ja) このオブジェクトのディープコピーを返します。
  CloneableFile clone();

  /// (en) Convert the object to a dictionary.
  /// The returned dictionary can only contain primitive types, null, lists
  /// or maps with only primitive elements.
  /// If you want to include other classes,
  /// the target class should inherit from this class and chain calls toDict.
  ///
  /// (ja) このオブジェクトを辞書に変換します。
  /// 戻り値の辞書にはプリミティブ型かプリミティブ型要素のみのリスト
  /// またはマップ等、そしてnullのみを含められます。
  /// それ以外のクラスを含めたい場合、対象のクラスもこのクラスを継承し、
  /// toDictを連鎖的に呼び出すようにしてください。
  Map<String, dynamic> toDict();
}
