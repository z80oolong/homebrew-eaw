# z80oolong/eaw に含まれる Formula 一覧

## 概要

本文書では、 [Linuxbrew][BREW] 向け Tap リポジトリ z80oolong/eaw に含まれる Formula 一覧を示します。各 Formula の詳細等については ```brew info <formula>``` コマンドも参照して下さい。

## Formula 一覧

### z80oolong/eaw/nano

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した軽量の CUI テキストエディタ [nano][NANO] のうち、最新の安定版及び HEAD 版を導入するための Formula です。

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
  なお、この設定は、 ```nano``` の起動時にオプション ```-0, --utf8emoji``` を指定しても同じ効果が得られます。

以上のオプションの初期値は、 locale に関する環境変数 ```LC_CTYPE``` の値が ```"ja*", "ko*", "zh*"``` の場合はオプションの設定が有効であり、それ以外の場合は無効となります。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

### z80oolong/eaw/neomutt

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] のうち、最新の安定版及び HEAD 版を導入するための Formula です。

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

以上の変数の初期値は、 locale に関する環境変数 ```LC_CTYPE``` の値が ```"ja*", "ko*", "zh*"``` の場合はオプションの設定が有効であり、それ以外の場合は無効となります。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

### z80oolong/eaw/ncurses-eaw@6.2

上述の Formula によって導入される各種 CUI アプリケーションに依存する ncurses ライブラリを導入するための Formula です。オリジナルの ncurses ライブラリに、 East Asian Ambiguous Character の文字幅を全角文字の幅として扱う修正を加えています。

**この Formula は、 versioned formula であるため、この Formula によって導入される ncurses は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/nano@4.9.2

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 4.9.2][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@4.9.2``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@4.9.3

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 4.9.3][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@4.9.3``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.0

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 5.0][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.0``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.1

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 5.1][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.1``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.2

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 5.2][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.2``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.3

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の旧安定版 [nano 5.3][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

なお、 [nano][NANO] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [nano][NANO] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.3``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200619

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200619][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200619``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200626

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200626][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200626``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200807

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200807][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200807``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200814

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200814][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200814``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200821

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200821][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200821``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200925

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の旧安定版 [neomutt 20200925][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

なお、 [neomutt][MUTT] において [East Asian Ambiguous Character][EAWA] の全角文字幅で表示するための修正を無効化する場合は、オプション ```--without-utf8-cjk``` を指定して下さい。そして、 [neomutt][MUTT] において、 UTF-8 において定義される絵文字を全角文字幅として表示するための修正を無効化するには、オプション ```--without-utf8-emoji``` を指定して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200925``` コマンドを実行する必要があります。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[TMUX]:https://tmux.github.io/
[EAWA]:http://www.unicode.org/reports/tr11/#Ambiguous
[NANO]:https://www.nano-editor.org/
[MUTT]:https://neomutt.org/
