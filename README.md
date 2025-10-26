# z80oolong/eaw -- CLI アプリケーションにおける East Asian Ambiguous Character を全角文字幅で表示するための Formula 群

## 概要

[Homebrew for Linux][BREW] は、Linux ディストリビューション向けのソースコードベースのパッケージ管理システムであり、ソフトウェアのビルドおよびインストールを簡素化します。

この [Homebrew for Linux][BREW] 向け Tap リポジトリ ```z80oolong/eaw``` は、Unicode の規格における東アジア圏の文字のうち、"◎" や "★" などの記号文字や罫線文字など、[East Asian Width 特性が A (Ambiguous)][EAWA] である文字（以下、[East Asian Ambiguous Character][EAWA]）が、日本語環境で適切な文字幅として扱われず表示が乱れる問題を修正した CLI アプリケーションをインストールするための Formula 群を提供します。

現時点で対応しているアプリケーションは以下の通りです：

- 軽量な CLI テキストエディタ [nano][NANO]
- CLI ベースの多機能メールクライアント [neomutt][MUTT]
- Unicode 対応の端末エミュレータ [rxvt-unicode][RXVT]
- CLI ベースの多機能メールクライアント [mutt][OMUT]

対応するアプリケーションおよび Formula の詳細は、本リポジトリに同梱の ```FormulaList.md``` を参照してください。

## 使用方法

[Homebrew for Linux][BREW] を以下の参考資料に基づいてインストールします：

- [thermes 氏][THER] の Qiita 投稿 "[Linuxbrew のススメ][THBR]"
- [Homebrew for Linux 公式ページ][BREW]

本リポジトリの Formula を以下のようにインストールします：

```
  brew tap z80oolong/eaw
  brew install <formula>
```

または、一時的な方法として、以下のように URL を直接指定してインストール可能です：

```
  brew install https://raw.githubusercontent.com/z80oolong/homebrew-eaw/master/Formula/<formula>.rb
```

利用可能な Formula の一覧および詳細は、本リポジトリに同梱の ```FormulaList.md``` を参照してください。

## 詳細情報

本リポジトリおよび [Homebrew for Linux][BREW] の使用方法の詳細は、以下のコマンドやリソースを参照してください：

- ```brew help``` コマンド
- ```man brew``` コマンド
- [Homebrew for Linux 公式ページ][BREW]

## 謝辞

本リポジトリの差分ファイル作成にあたり、[Markus Kuhn 氏][DRMK] が提供する [East Asian Ambiguous Character][EAWA] の扱いを考慮した [```wcwidth.c``` 実装][WCWD]を参照しました。[Markus Kuhn 氏][DRMK] に心より感謝いたします。

また、[nano][NANO]、[neomutt][MUTT]、[rxvt-unicode][RXVT]、[mutt][OMUT] の開発者および開発コミュニティ各位に心より感謝いたします。

## 使用条件

本リポジトリは、[Homebrew for Linux][BREW] の Tap リポジトリとして、[Homebrew for Linux 開発コミュニティ][BREW] および [Z.OOL.][ZOOL] が著作権を有します。本リポジトリは、[BSD 2-Clause License][BSD2] に基づいて配布されます。詳細は本リポジトリに同梱の ```LICENSE``` を参照してください。

<!-- 外部リンク一覧 -->

[BREW]: https://linuxbrew.sh/
[EAWA]: http://www.unicode.org/reports/tr11/#Ambiguous
[NANO]: https://www.nano-editor.org/
[MUTT]: https://neomutt.org/
[RXVT]: https://github.com/exg/rxvt-unicode
[OMUT]: http://www.mutt.org/
[THER]: https://qiita.com/thermes
[THBR]: https://qiita.com/thermes/items/926b478ff6e3758ecfea
[WCWD]: http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
[DRMK]: http://www.cl.cam.ac.uk/~mgk25/
[BSD2]: https://opensource.org/licenses/BSD-2-Clause
[ZOOL]: http://zool.jpn.org/
