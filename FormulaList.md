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
  なお、この設定は、 ```nano``` の起動時にオプション ```-4, --utf8emoji``` を指定しても同じ効果が得られます。

以上のオプションの初期値は、 locale に関する環境変数 ```LC_CTYPE``` の値が ```"ja*", "ko*", "zh*"``` の場合はオプションの設定が有効であり、それ以外の場合は無効となります。

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

### z80oolong/eaw/rxvt-unicode

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] のうち、最新の安定版及び HEAD 版を導入するための Formula です。

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

### z80oolong/eaw/mutt

Unicode の規格における東アジア圏の各種文字のうち、いわゆる "◎" や "★" 等の記号文字及び罫線文字等、 [East_Asian_Width 特性の値が A (Ambiguous) となる文字][EAWA] (以下、 [East Asian Ambiguous Character][EAWA]) が、日本語環境で文字幅を適切に扱うことが出来ずに表示が乱れる問題 （以下、 [East Asian Ambiguous Character][EAWA] 問題）を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] のうち、最新の安定版及び HEAD 版を導入するための Formula です。

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

### z80oolong/eaw/ncurses-eaw@6.2

上述の Formula によって導入される各種 CUI アプリケーションに依存する ncurses ライブラリを導入するための Formula です。オリジナルの ncurses ライブラリに、 East Asian Ambiguous Character の文字幅を全角文字の幅として扱う修正を加えています。

**この Formula は、 versioned formula であるため、この Formula によって導入される ncurses は、 keg only で導入されることに留意して下さい。**

### z80oolong/eaw/nano@4.9.2

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 4.9.2][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@4.9.2``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@4.9.3

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 4.9.3][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@4.9.3``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.0

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.0][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.0``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.1

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.1][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.1``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.2

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.2][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.2``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.3

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.3][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.3``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.4

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.4][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.4``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.5

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.5][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.5``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.6

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.6][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.6``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.6.1

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.6.1][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.6.1``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.7

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.7][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.7``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.8

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.8][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.8``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@5.9

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 5.9][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@5.9``` コマンドを実行する必要があります。

### z80oolong/eaw/nano@6.0

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した軽量の CUI テキストエディタ [nano][NANO] の安定版 [nano 6.0][NANO] を導入します。

この Formula で導入した [nano][NANO] の使用法については、前述の z80oolong/eaw/nano の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [nano][NANO] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [nano][NANO] を使用するには、 ```brew link --force z80oolong/eaw/nano@6.0``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200619

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200619][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200619``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200626

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200626][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200626``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200807

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200807][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200807``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200814

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200814][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200814``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200821

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200821][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200821``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20200925

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20200925][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20200925``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20201120

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20201120][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20201120``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20201127

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20201127][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20201127``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20210205

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20210205][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20210205``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20210205

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20210205][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20210205``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20211015

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20211015][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20211015``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20211022

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20211022][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20211022``` コマンドを実行する必要があります。

### z80oolong/eaw/neomutt@20211029

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [neomutt][MUTT] の安定版 [neomutt 20211029][MUTT] を導入します。

この Formula で導入した [neomutt][MUTT] の使用法については、前述の z80oolong/eaw/neomutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [neomutt][MUTT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [neomutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/neomutt@20211029``` コマンドを実行する必要があります。

### z80oolong/eaw/rxvt-unicode@9.22

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] の安定版 [rxvt-unicode 9.22][RXVT] を導入します。

この Formula で導入した [rxvt-unicode][RXVT] の使用法については、前述の z80oolong/eaw/rxvt-unicode の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [rxvt-unicode][RXVT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [rxvt-unicode][RXVT] を使用するには、 ```brew link --force z80oolong/eaw/rxvt-unicode@9.22``` コマンドを実行する必要があります。

### z80oolong/eaw/rxvt-unicode@9.25

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] の安定版 [rxvt-unicode 9.25][RXVT] を導入します。

この Formula で導入した [rxvt-unicode][RXVT] の使用法については、前述の z80oolong/eaw/rxvt-unicode の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [rxvt-unicode][RXVT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [rxvt-unicode][RXVT] を使用するには、 ```brew link --force z80oolong/eaw/rxvt-unicode@9.25``` コマンドを実行する必要があります。

### z80oolong/eaw/rxvt-unicode@9.26

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した Unicode 対応端末エミュレータである [rxvt-unicode][RXVT] の安定版 [rxvt-unicode 9.26][RXVT] を導入します。

この Formula で導入した [rxvt-unicode][RXVT] の使用法については、前述の z80oolong/eaw/rxvt-unicode の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [rxvt-unicode][RXVT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [rxvt-unicode][RXVT] を使用するには、 ```brew link --force z80oolong/eaw/rxvt-unicode@9.26``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.0.7

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.0.7][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.0.7``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.1.0

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.1.0][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.1.0``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.1.1

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.1.1][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.1.1``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.1.2

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.1.2][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.1.2``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.1.3

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.1.3][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.1.3``` コマンドを実行する必要があります。

### z80oolong/eaw/mutt@2.1.4

この Formula は、 [East Asian Ambiguous Character][EAWA] 問題を修正した CLI に基づく多機能メールクライアントである [mutt][OMUT] の安定版 [mutt 2.1.4][MUTT] を導入します。

この Formula で導入した [mutt][OMUT] の使用法については、前述の z80oolong/eaw/mutt の Formula についての記述を参照して下さい。

**この Formula は、 versioned formula であるため、この Formula によって導入される [mutt][OMUT] は、 keg only で導入されることに留意して下さい。**

この Formula によって導入される [mutt][MUTT] を使用するには、 ```brew link --force z80oolong/eaw/mutt@2.1.4``` コマンドを実行する必要があります。

<!-- 外部リンク一覧 -->

[BREW]:https://linuxbrew.sh/
[TMUX]:https://tmux.github.io/
[EAWA]:http://www.unicode.org/reports/tr11/#Ambiguous
[NANO]:https://www.nano-editor.org/
[MUTT]:https://rxvt-unicode.org/
[RXVT]:https://github.com/exg/rxvt-unicode
[OMUT]:http://www.mutt.org/
