import 'package:flutter/cupertino.dart';

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
    int r = 17;
    m.forEach((dynamic key, dynamic value) {
      if (value is Map) {
        r = 37 * r + key.hashCode;
        r = 37 * r + calcMap(value);
      } else if (value is List) {
        r = 37 * r + key.hashCode;
        r = 37 * r + calcList(value);
      } else if (value is Set) {
        r = 37 * r + key.hashCode * 37;
        r = 37 * r + calcSet(value);
      } else {
        r = 37 * r + key.hashCode;
        r = 37 * r + (value?.hashCode ?? 0);
      }
    });
    return r;
  }

  /// (en) Calculate hash code for list.
  /// This method supports nesting of Maps, Lists, and Sets.
  ///
  /// (ja) Listのハッシュコードを計算します。
  /// Map, List, Setのネストに対応しています。
  static int calcList(List<dynamic> list) {
    int r = 17;
    for (int i = 0; i < list.length; i++) {
      if (list[i] is Map) {
        r = 37 * r + (calcMap(list[i]) ^ i);
      } else if (list[i] is List) {
        r = 37 * r + (calcList(list[i]) ^ i);
      } else if (list[i] is Set) {
        r = 37 * r + (calcSet(list[i]) ^ i);
      } else {
        r = 37 * r + ((list[i]?.hashCode ?? 0) ^ i);
      }
    }
    return r;
  }

  /// (en) Calculate hash code for set.
  /// This method supports nesting of Maps, Lists, and Sets.
  ///
  /// (ja) Setのハッシュコードを計算します。
  /// Map, List, Setのネストに対応しています。
  static int calcSet(Set<dynamic> s) {
    int r = 17;
    for (dynamic i in s) {
      if (i is Map) {
        r = 37 * r + calcMap(i);
      } else if (i is List) {
        r = 37 * r + calcList(i);
      } else if (i is Set) {
        r = 37 * r + calcSet(i);
      } else {
        r = 37 * r + (i?.hashCode ?? 0);
      }
    }
    return r;
  }

  /// (en) Calculate hash code for mapped TextEditingController by
  /// it's include text.
  ///
  /// (ja) マップされたTextEditingControllerのハッシュコードを、
  /// 含まれるテキストによって計算します。
  static int calcMappedTEC(Map<String, TextEditingController> m) {
    int r = 17;
    m.forEach((String key, TextEditingController value) {
      r = 37 * r + key.hashCode;
      r = 37 * r + value.text.hashCode;
    });
    return r;
  }
}
