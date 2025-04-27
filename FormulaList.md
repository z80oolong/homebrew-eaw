# z80oolong/eaw に含まれる Formula 一覧

## 概要

本文書では、 [Homebrew for Linux][BREW] 向け Tap リポジトリ z80oolong/eaw に含まれる Formula 一覧を示します。各 Formula の詳細等については ```brew info <formula>``` コマンドも参照して下さい。

## Formula 一覧

### z80oolong/eaw/nano

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した軽量の CUI テキストエディタ [nano][NANO] のうち、github 上の HEAD 版を導入するための Formula である ```z80oolong/eaw/nano-head``` への alias です。

### z80oolong/eaw/nano-head

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した軽量の CUI テキストエディタ [nano][NANO] のうち、github 上の HEAD 版を導入するための Formula です。

この Formula によって導入された [nano][NANO] では、以下の２つのオプションが新たに拡張されます。

- ```utf8cjk``` … [East Asian Ambiguous Character][EAWA] を全角文字幅として表示します。例えば、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] を全角文字幅として表示する場合は、次のように設定ファイル ```~/.nanorc``` に以下の設定を追加します。
  ```
  ...
  set utf8cjk                   # EAW 文字の幅を２にする。
  ...
  ```
  なお、この設定は、 ```nano``` の起動時にオプション ```-8, --utf8cjk``` を指定しても同じ効果が得られます。
- ```utf8emoji``` … UTF-8 において定義される絵文字を全角文字幅として表示します。例えば、 [nano][NANO] において UTF-8 において定義される絵文字を全角文字幅として表示する場合は、次のように設定ファイル ```~/.nanorc``` に以下の設定を追加します。
  ```
  ...
  set utf8emoji                 # 絵文字の幅を２にする。
  ...
  ```
  なお、この設定は、 ```nano``` の起動時にオプション ```-4, --utf8emoji``` を指定しても同じ効果が得られます。

以上のオプションの初期値は、 locale に関する環境変数 ```LC_CTYPE``` の値が ```"ja*", "ko*", "zh*"``` の場合はオプションの設定が有効であり、それ以外の場合は無効となります。

なお、この Formula において、通常は [East Asian Ambiguous Character][EAWA] の全角文字幅表示に対応した [nano][NANO] において、 East Asian Ambiguous Character の全角文字幅表示に対応した直近の HEAD 版の commit の [nano][nano] が導入されます。

github 上の HEAD 版の最新の commit の [nano][NANO] を導入する場合は、オプション ```--HEAD``` を指定して下さい。

**この Formula は、 ```homebrew/core/nano``` と競合するため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/neomutt

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] のうち、github 上の HEAD 版を導入するための Formula である ```z80oolong/eaw/neomutt-head``` への alias です。

### z80oolong/eaw/neomutt-head

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] のうち、github 上の HEAD 版を導入するための Formula です。

この Formula によって導入された [neomutt][MUTT] では、以下の２つの変数が新たに拡張されます。

- ```utf8_cjk``` … [East Asian Ambiguous Character][EAWA] を全角文字幅として表示します。例えば、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] を全角文字幅として表示する場合は、次のように設定ファイル ```.config/neomutt/neomuttrc``` に以下の設定を追加します。
  ```
  ...
  set utf8_cjk   = yes                   # EAW 文字の幅を２にする。
  ...
  ```
- ```utf8_emoji``` … UTF-8 において定義される絵文字を全角文字幅として表示します。例えば、 [neomutt][MUTT] において UTF-8 において定義される絵文字を全角文字幅として表示する場合は、次のように設定ファイル ```.config/neomutt/neomuttrc``` に以下の設定を追加します。
  ```
  ...
  set utf8_emoji = yes                   # 絵文字の幅を２にする。
  ...
  ```

なお、この Formula において、通常は [East Asian Ambiguous Character][EAWA] の全角文字幅表示に対応した [neomutt][MUTT] において、 East Asian Ambiguous Character の全角文字幅表示に対応した直近の HEAD 版の commit の [neomutt][MUTT] が導入されます。

github 上の HEAD 版の最新の commit の [neomutt][MUTT] を導入する場合は、オプション ```--HEAD``` を指定して下さい。

**この Formula は、 ```homebrew/core/neomutt``` と競合するため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/rxvt-unicode

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] のうち、のうち、github 上の HEAD 版を導入するための Formula である ```z80oolong/eaw/rxvt-unicode-head``` への alias です。

### z80oolong/eaw/rxvt-unicode-head

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] のうち、のうち、github 上の HEAD 版を導入するための Formula です。

この Formula によって導入された ```urxvt``` では、以下の環境変数にて設定を行います。

- ```URXVT_USE_UTF8_CJK``` … この環境変数に "1" を設定した場合、[East Asian Ambiguous Character][EAWA] を全角文字幅として表示します。例えば、 ```urxvt``` において [East Asian Ambiguous Character][EAWA] を全角文字幅として表示する場合は、次のようにして ```urxvt``` を起動します。
  ```
  ...
  $ export URXVT_USE_UTF8_CJK=1              # EAW 文字の幅を２にする。
  $ urxvt                                    # urxvt を起動する。
  ...
  $ env URXVT_USE_UTF8_CJK=1 urxvt           # env を用いて urxvt を起動する。
  ...
  ```
  なお、```urxvt``` において [East Asian Ambiguous Character][EAWA] を半角文字幅として表示する場合は、この環境変数に "0" を設定して下さい。
- ```URXVT_USE_UTF8_CJK_EMOJI``` … この環境変数に "1" を設定した場合、 UTF-8 において定義される絵文字を全角文字幅として表示します。例えば、 ```urxvt``` において UTF-8 において定義される絵文字を全角文字幅として表示する場合は、次のようにして ```urxvt``` を起動します。
  ```
  ...
  $ export URXVT_USE_UTF8_CJK_EMOJI=1              # 絵文字の幅を２にする。
  $ urxvt                                          # urxvt を起動する。
  ...
  $ env URXVT_USE_UTF8_CJK_EMOJI=1 urxvt           # env を用いて urxvt を起動する。
  ...
  ```
なお、この Formula において、通常は [East Asian Ambiguous Character][EAWA] の全角文字幅表示に対応した [rxvt-unicode][RXVT] において、 East Asian Ambiguous Character の全角文字幅表示に対応した直近の HEAD 版の commit の [rxvt-unicode][RXVT] が導入されます。

github 上の HEAD 版の最新の commit の [rxvt-unicode][RXVT] を導入する場合は、オプション ```--HEAD``` を指定して下さい。

**この Formula は、 ```homebrew/core/rxvt-unicode``` と競合するため、この Formula によって導入される [rxvt-unicode][RXVT] は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/mutt

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] のうち、 github 上の HEAD 版を導入するための Formula である ```z80oolong/eaw/mutt-head``` への alias です。

### z80oolong/eaw/mutt-head

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] のうち、 github 上の HEAD 版を導入するための Formula です。

この Formula によって導入された [mutt][OMUT] では、以下の２つの変数が新たに拡張されます。

- ```utf8_cjk``` … [East Asian Ambiguous Character][EAWA] を全角文字幅として表示します。例えば、 [mutt][OMUT] において [East Asian Ambiguous Character][EAWA] を全角文字幅として表示する場合は、次のように設定ファイル ```.muttrc```, ```.mutt/muttrc``` 若しくは ```.config/mutt/muttrc``` に以下の設定を追加します。
  ```
  ...
  set utf8_cjk   = yes                   # EAW 文字の幅を２にする。
  ...
  ```
- ```utf8_emoji``` … UTF-8 において定義される絵文字を全角文字幅として表示します。例えば、 [mutt][OMUT] において UTF-8 において定義される絵文字を全角文字幅として表示する場合は、次のように設定ファイル ```.muttrc```, ```.mutt/muttrc``` 若しくは ```.config/mutt/muttrc``` に以下の設定を追加します。
  ```
  ...
  set utf8_emoji = yes                   # 絵文字の幅を２にする。
  ...
  ```

なお、この Formula において、通常は [East Asian Ambiguous Character][EAWA] の全角文字幅表示に対応した [mutt][OMUT] において、 East Asian Ambiguous Character の全角文字幅表示に対応した直近の HEAD 版の commit の [mutt][OMUT] が導入されます。

github 上の HEAD 版の最新の commit の [mutt][OMUT] を導入する場合は、オプション ```--HEAD``` を指定して下さい。

**この Formula は、 ```homebrew/core/mutt``` と競合するため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/ncurses-eaw@6.2

上述の Formula によって導入される各種 CUI アプリケーションが依存する ncurses ライブラリを導入するための Formula です。オリジナルの ncurses ライブラリに、 East Asian Ambiguous Character の文字幅を全角文字の幅として扱う修正を加えています。

**この Formula は、 versioned formula であるため、この Formula によって導入される ncurses は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/nano@{version}

(注：上記 ```{version}``` には、 [nano][NANO] の各バージョン番号が入ります。以下同様。)

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano {version}][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@{version}``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@{version}

(注：上記 ```{version}``` には、 [neomutt][MUTT] 各バージョン番号が入ります。以下同様。)

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt {version}][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@{version}``` コマンドを実行する必要があります。

### z80oolong/eaw/rxvt-unicode@{version}

(注：上記 ```{version}``` には、 [rxvt-unicode][RXVT] の各バージョン番号が入ります。以下同様。)

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] の安定版 [rxvt-unicode {version}][RXVT] を導入します。

この Formula で導入した [rxvt-unicode][RXVT] の使用法については、前述の z80oolong/eaw/rxvt-unicode の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [rxvt-unicode][RXVT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [rxvt-unicode][RXVT] を使用するには、 ```brew link --force z80oolong/eaw/rxvt-unicode@{version}``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@{version}

(注：上記 ```{version}``` には、 [mutt][OMUT] の各バージョン番号が入ります。以下同様。)

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt {version}][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@{version}``` コマンドを実行する必要があります。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[TMUX]:https://tmux.github.io/
[EAWA]:http://www.unicode.org/reports/tr11/#Ambiguous
[NANO]:https://www.nano-editor.org/
[MUTT]:https://rxvt-unicode.org/
[RXVT]:https://github.com/exg/rxvt-unicode
[OMUT]:http://www.mutt.org/
