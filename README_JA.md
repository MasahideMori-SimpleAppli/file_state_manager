# file_state_manager

## 概要
アプリケーションの保存データを簡単にUndo, Redoできるようにするためのパッケージです。
このパッケージは、詳細な変更履歴を追跡するためのものではありません。
これは複雑な大量のデータ変更が発生するアプリケーションのために作成されました。

## 使い方
pub.devのExampleタブをチェックしてください。

## サポート
基本的にサポートはありません。
問題がある場合は問題を報告してください。
このパッケージは優先度が低いですが、修正される可能性があります。

## バージョン管理について
それぞれ、Cの部分が変更されます。  
ただし、バージョン1.0.0未満は以下のルールに関係無くファイル構造が変化する場合があります。  
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
  - C.X.X
- メソッドの追加など
  - X.C.X
- 軽微な変更やバグ修正
  - X.X.C

## ライセンス
このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## 著作権表示
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.