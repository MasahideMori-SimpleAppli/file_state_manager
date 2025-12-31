/// (en) This is a utility for object hash calculations.
/// This makes it easy to calculate hashes, for example
/// if you want to enable enableDiffCheck flag in FileStateManager.
///
/// (ja) これはオブジェクトハッシュ計算用のユーティリティです。
/// 利用することで、FileStateManagerのenableDiffCheckフラグを有効化したい場合などに、
/// ハッシュ計算を簡単に行えます。
class UtilObjectHash {
  /// (en) Calculate hash code for map.
  /// This method supports nesting of Maps, Lists, and Sets.
  ///
  /// (ja) Mapのハッシュコードを計算します。
  /// Map, List, Setのネストに対応しています。
  static int calcMap(Map<dynamic, dynamic> m) {
    return Object.hashAllUnordered(m.entries.map((e) {
      // キーと値のペア自体のハッシュは順序を固定して計算
      return Object.hash(e.key?.hashCode ?? 0, _deepHashCode(e.value));
    }));
  }

  /// (en) Calculate hash code for list.
  /// This method supports nesting of Maps, Lists, and Sets.
  ///
  /// (ja) Listのハッシュコードを計算します。
  /// Map, List, Setのネストに対応しています。
  static int calcList(List<dynamic> list) {
    return Object.hashAll(list.map((e) => _deepHashCode(e)));
  }

  /// (en) Calculate hash code for set.
  /// This method supports nesting of Maps, Lists, and Sets.
  ///
  /// (ja) Setのハッシュコードを計算します。
  /// Map, List, Setのネストに対応しています。
  static int calcSet(Set<dynamic> s) {
    return Object.hashAllUnordered(s.map((e) => _deepHashCode(e)));
  }

  /// 再帰的にハッシュを計算するためのヘルパーメソッド
  static int _deepHashCode(dynamic value) {
    if (value is Map) return calcMap(value);
    if (value is List) return calcList(value);
    if (value is Set) return calcSet(value);
    return value?.hashCode ?? 0;
  }
}
