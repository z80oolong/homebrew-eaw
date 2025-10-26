# z80oolong/eaw に含まれる Formula 一覧

## 概要

本文書では、[Homebrew for Linux][BREW] 向け Tap リポジトリ ```z80oolong/eaw``` に含まれる Formula 一覧を示します。

この Tap リポジトリは、東アジア圏の文字表示に関する問題（[East Asian Ambiguous Character][EAWA] 問題）を修正したテキストエディタや端末エミュレータ、メールクライアントなどを提供します。各 Formula の詳細については、```brew info <formula>``` コマンドをご覧ください。

## Formula 一覧

### z80oolong/eaw/nano

[East Asian Ambiguous Character][EAWA] 問題を修正した軽量な CUI テキストエディタ [nano][NANO] の最新安定版および最新の HEAD 版をインストールする Formula である ```z80oolong/eaw/nano-current``` への alias です。

### z80oolong/eaw/nano-current

[East Asian Ambiguous Character][EAWA] 問題を修正した軽量な CUI テキストエディタ [nano][NANO] の最新安定版および最新の HEAD 版をインストールする Formula です。

この Formula でインストールされた [nano][NANO] では、以下のオプションが新たに追加されます。

- **```utf8cjk```**: [EAWA] を全角文字幅で表示します。たとえば、[EAWA] を全角文字幅で表示する場合、設定ファイル ```~/.nanorc``` に以下を追加します。

  ```
  set utf8cjk
  ```

  または、```nano``` の起動時に以下のオプションを指定します。

  ```
  $ nano -8
  ```

- **```utf8emoji```**: UTF-8 で定義される絵文字を全角文字幅で表示します。たとえば、絵文字を全角文字幅で表示する場合、設定ファイル ```~/.nanorc``` に以下を追加します。

  ```
  set utf8emoji
  ```

  または、```nano``` の起動時に以下のオプションを指定します。

  ```
  $ nano -4
  ```

これらのオプションの初期値は、環境変数 ```LC_CTYPE``` の値が ```ja*```、```ko*```、```zh*``` の場合に有効、それ以外の場合は無効です。

なお、最新の HEAD 版のコミットをインストールするには、```--HEAD``` オプションを指定してください。

- **注意**:
    - **この Formula は ```homebrew/core/nano``` と競合するため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [nano][NANO] を使用するには、```brew link --force z80oolong/eaw/nano-current``` を実行してください。**

### z80oolong/eaw/nano@{version}

(注: ```{version}``` には [nano][NANO] の各バージョン番号が入ります。)

これは、[EAWA] 問題を修正した軽量な CUI テキストエディタ [nano][NANO] の安定版をインストールする Formula です。使用法は ```z80oolong/eaw/nano-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [nano][NANO] を使用するには、```brew link --force z80oolong/eaw/nano@{version}``` を実行してください。**

### z80oolong/eaw/nano@9999-dev

これは、```z80oolong/eaw/nano@9999-dev``` に組み込まれた差分ファイルの適用により、[EAWA] 問題を修正した軽量な CUI テキストエディタ [nano][NANO] の特定の HEAD 版をインストールする Formula です。

たとえば、```z80oolong/eaw/nano@9999-dev``` に組み込まれている差分ファイルが [nano][NANO] の HEAD 版のコミット xxxxxxxxx 向けに対応している場合、この Formula は [nano][NANO] の HEAD 版のコミット xxxxxxxxx をインストールします。

具体的なコミットについては、```brew info z80oolong/eaw/nano@9999-dev``` で確認できます。使用法は ```z80oolong/eaw/nano-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [nano][NANO] を使用するには、```brew link --force z80oolong/eaw/nano@9999-dev``` を実行してください。**
    - **この Formula は、```z80oolong/eaw/nano-current``` の HEAD 版で差分ファイル適用に不具合が発生する場合に暫定的に使用するものです。** 通常は ```z80oolong/eaw/nano-current``` をご使用ください。

### z80oolong/eaw/neomutt

[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [neomutt][MUTT] の最新安定版および最新の HEAD 版をインストールする Formula である ```z80oolong/eaw/neomutt-current``` への alias です。

### z80oolong/eaw/neomutt-current

[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [neomutt][MUTT] の最新安定版および最新の HEAD 版をインストールする Formula です。

この Formula でインストールされた [neomutt][MUTT] では、以下の変数が新たに追加されます。

- **```utf8_cjk```**: [EAWA] を全角文字幅で表示します。たとえば、[EAWA] を全角文字幅で表示する場合、設定ファイル ```~/.config/neomutt/neomuttrc``` に以下を追加します。

  ```
  set utf8_cjk=yes
  ```

- **```utf8_emoji```**: UTF-8 で定義される絵文字を全角文字幅で表示します。たとえば、絵文字を全角文字幅で表示する場合、設定ファイル ```~/.config/neomutt/neomuttrc``` に以下を追加します。

  ```
  set utf8_emoji=yes
  ```

なお、最新の HEAD 版のコミットをインストールするには、```--HEAD``` オプションを指定してください。

- **注意**:
    - **この Formula は ```homebrew/core/neomutt``` と競合するため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [neomutt][MUTT] を使用するには、```brew link --force z80oolong/eaw/neomutt-current``` を実行してください。**

### z80oolong/eaw/neomutt@{version}

(注: ```{version}``` には [neomutt][MUTT] の各バージョン番号が入ります。)

これは、[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [neomutt][MUTT] の安定版をインストールする Formula です。使用法は ```z80oolong/eaw/neomutt-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [neomutt][MUTT] を使用するには、```brew link --force z80oolong/eaw/neomutt@{version}``` を実行してください。**

### z80oolong/eaw/neomutt@9999-dev

これは、```z80oolong/eaw/neomutt@9999-dev``` に組み込まれた差分ファイルの適用により、[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [neomutt][MUTT] の特定の HEAD 版をインストールする Formula です。

たとえば、```z80oolong/eaw/neomutt@9999-dev``` に組み込まれている差分ファイルが [neomutt][MUTT] の HEAD 版のコミット xxxxxxxxx 向けに対応している場合、この Formula は [neomutt][MUTT] の HEAD 版のコミット xxxxxxxxx をインストールします。

具体的なコミットについては、```brew info z80oolong/eaw/neomutt@9999-dev``` で確認できます。使用法は ```z80oolong/eaw/neomutt-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [neomutt][MUTT] を使用するには、```brew link --force z80oolong/eaw/neomutt@9999-dev``` を実行してください。**
    - **この Formula は、```z80oolong/eaw/neomutt-current``` の HEAD 版で差分ファイル適用に不具合が発生する場合に暫定的に使用するものです。** 通常は ```z80oolong/eaw/neomutt-current``` をご使用ください。

### z80oolong/eaw/rxvt-unicode

[EAWA] 問題を修正した Unicode 対応端末エミュレータ [rxvt-unicode][RXVT] の最新安定版および最新の HEAD 版をインストールする Formula である ```z80oolong/eaw/rxvt-unicode-current``` への alias です。

### z80oolong/eaw/rxvt-unicode-current

[EAWA] 問題を修正した Unicode 対応端末エミュレータ [rxvt-unicode][RXVT] の最新安定版および最新の HEAD 版をインストールする Formula です。

この Formula でインストールされた ```urxvt``` では、以下の環境変数を参照します。

- **```URXVT_USE_UTF8_CJK```**: この環境変数に ```1``` を設定した場合、[EAWA] を全角文字幅で表示します。たとえば、[EAWA] を全角文字幅で表示する場合、以下のように ```urxvt``` を起動します。

  ```
  $ export URXVT_USE_UTF8_CJK=1
  $ urxvt
  # または
  $ env URXVT_USE_UTF8_CJK=1 urxvt
  ```

  [EAWA] を半角文字幅で表示する場合は、この環境変数に ```0``` を設定してください。

- **```URXVT_USE_UTF8_CJK_EMOJI```**: この環境変数に ```1``` を設定した場合、UTF-8 で定義される絵文字を全角文字幅で表示します。たとえば、絵文字を全角文字幅で表示する場合、以下のように ```urxvt``` を起動します。

  ```
  $ export URXVT_USE_UTF8_CJK_EMOJI=1
  $ urxvt
  # または
  $ env URXVT_USE_UTF8_CJK_EMOJI=1 urxvt
  ```

なお、最新の HEAD 版のコミットをインストールするには、```--HEAD``` オプションを指定してください。

- **注意**:
    - **この Formula は ```homebrew/core/rxvt-unicode``` と競合するため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [rxvt-unicode][RXVT] を使用するには、```brew link --force z80oolong/eaw/rxvt-unicode-current``` を実行してください。**

### z80oolong/eaw/rxvt-unicode@{version}

(注: ```{version}``` には [rxvt-unicode][RXVT] の各バージョン番号が入ります。)

これは、[EAWA] 問題を修正した Unicode 対応端末エミュレータ [rxvt-unicode][RXVT] の安定版をインストールする Formula です。使用法は ```z80oolong/eaw/rxvt-unicode-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [rxvt-unicode][RXVT] を使用するには、```brew link --force z80oolong/eaw/rxvt-unicode@{version}``` を実行してください。**

### z80oolong/eaw/rxvt-unicode@9999-dev

これは、```z80oolong/eaw/rxvt-unicode@9999-dev``` に組み込まれた差分ファイルの適用により、[EAWA] 問題を修正した Unicode 対応端末エミュレータ [rxvt-unicode][RXVT] の特定の HEAD 版をインストールする Formula です。

たとえば、```z80oolong/eaw/rxvt-unicode@9999-dev``` に組み込まれている差分ファイルが [rxvt-unicode][RXVT] の HEAD 版のコミット xxxxxxxxx 向けに対応している場合、この Formula は [rxvt-unicode][RXVT] の HEAD 版のコミット xxxxxxxxx をインストールします。

具体的なコミットについては、```brew info z80oolong/eaw/rxvt-unicode@9999-dev``` で確認できます。使用法は ```z80oolong/eaw/rxvt-unicode-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [rxvt-unicode][RXVT] を使用するには、```brew link --force z80oolong/eaw/rxvt-unicode@9999-dev``` を実行してください。**
    - **この Formula は、```z80oolong/eaw/rxvt-unicode-current``` の HEAD 版で差分ファイル適用に不具合が発生する場合に暫定的に使用するものです。** 通常は ```z80oolong/eaw/rxvt-unicode-current``` をご使用ください。

### z80oolong/eaw/mutt

[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [mutt][OMUT] の最新安定版および最新の HEAD 版をインストールする Formula である ```z80oolong/eaw/mutt-current``` への alias です。

### z80oolong/eaw/mutt-current

[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [mutt][OMUT] の最新安定版および最新の HEAD 版をインストールする Formula です。

この Formula でインストールされた [mutt][OMUT] では、以下の変数が新たに追加されます。

- **```utf8_cjk```**: [EAWA] を全角文字幅で表示します。たとえば、[EAWA] を全角文字幅で表示する場合、設定ファイル ```~/.muttrc```、```~/.mutt/muttrc```、または ```~/.config/mutt/muttrc``` に以下を追加します。

  ```
  set utf8_cjk=yes
  ```

- **```utf8_emoji```**: UTF-8 で定義される絵文字を全角文字幅で表示します。たとえば、絵文字を全角文字幅で表示する場合、設定ファイル ```~/.muttrc```、```~/.mutt/muttrc```、または ```~/.config/mutt/muttrc``` に以下を追加します。

  ```
  set utf8_emoji=yes
  ```

なお、最新の HEAD 版のコミットをインストールするには、```--HEAD``` オプションを指定してください。

- **注意**:
    - **この Formula は ```homebrew/core/mutt``` と競合するため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [mutt][OMUT] を使用するには、```brew link --force z80oolong/eaw/mutt-current``` を実行してください。**

### z80oolong/eaw/mutt@{version}

(注: ```{version}``` には [mutt][OMUT] の各バージョン番号が入ります。)

これは、[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [mutt][OMUT] の安定版をインストールする Formula です。使用法は ```z80oolong/eaw/mutt-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [mutt][OMUT] を使用するには、```brew link --force z80oolong/eaw/mutt@{version}``` を実行してください。**

### z80oolong/eaw/mutt@9999-dev

これは、```z80oolong/eaw/mutt@9999-dev``` に組み込まれた差分ファイルの適用により、[EAWA] 問題を修正した CLI ベースの多機能メールクライアント [mutt][OMUT] の特定の HEAD 版をインストールする Formula です。

たとえば、```z80oolong/eaw/mutt@9999-dev``` に組み込まれている差分ファイルが [mutt][OMUT] の HEAD 版のコミット xxxxxxxxx 向けに対応している場合、この Formula は [mutt][OMUT] の HEAD 版のコミット xxxxxxxxx をインストールします。

具体的なコミットについては、```brew info z80oolong/eaw/mutt@9999-dev``` で確認できます。使用法は ```z80oolong/eaw/mutt-current``` の記述をご覧ください。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた [mutt][OMUT] を使用するには、```brew link --force z80oolong/eaw/mutt@9999-dev``` を実行してください。**
    - **この Formula は、```z80oolong/eaw/mutt-current``` の HEAD 版で差分ファイル適用に不具合が発生する場合に暫定的に使用するものです。** 通常は ```z80oolong/eaw/mutt-current``` をご使用ください。

### z80oolong/eaw/ncurses-eaw@6.2

上述の Formula でインストールされる各種 CUI アプリケーションが依存する ncurses ライブラリをインストールする Formula です。このライブラリは、[EAWA] の文字幅を全角文字幅として扱う修正を加えています。

- **注意**:
    - **この Formula は versioned formula のため、keg-only でインストールされます。**
    - **この Formula によってインストールされた ncurses ライブラリを使用するには、```brew link --force z80oolong/eaw/ncurses-eaw@6.2``` を実行してください。**

<!-- 外部リンク一覧 -->

[BREW]: https://linuxbrew.sh/  
[EAWA]: http://www.unicode.org/reports/tr11/#Ambiguous  
[NANO]: https://www.nano-editor.org/  
[MUTT]: https://neomutt.org/  
[RXVT]: https://github.com/exg/rxvt-unicode  
[OMUT]: http://www.mutt.org/
