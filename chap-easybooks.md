# easybooksの書き方

この章は、実際の本では削除されます。


Re:VIEWフォーマット（`*.re`）およびMarkdown（`*.md`）で書かれた原稿を
まとめてコンパイルするプログラムです。

ちなみに、Re:VIEWで記述できることの多くをMarkdownでも書けますが、未対応のものも一部あります。必要があれば言ってくれれば機能追加などします。

折りたたみ関連はいまんところ、対応してません！！！！誰かTeX強いひと、対応して！

## 動作条件

* RubyおよびRe:VIEWをインストールしていること
* TeXをインストールしていること
* Node.js

Docker使うのが一番簡単だと思います。

## Markdownの書き方

基本的なMarkdownの書き方は変わりません。

### セクションとか

```md {caption="セクションの書き方"}
### セクションとか

#### [column] コラム
#### [/column] コラム閉じる

## [notoc] ToCに出力しない（前書きとか）
```

### 箇条書きリスト

* ほげ
* ふが
  * ぴよ

```md {caption="箇条書きリストの書き方"}
* ほげ
* ふが
  * ぴよ
```

1. ほげ
2. ふが

```md {caption="番号付き箇条書きリストの書き方"}
1. ほげ
2. ふが
```

Re:VIEWの仕様上の制限のため、箇条書きリストの子項目としてコードブロックや画像などを含めたり、番号付きの箇条書きリストを入れ子にしたりはできません。
（ただし、実験的な機能として[複雑な箇条書きの入れ子に対応する](https://review-knowledge-ja.readthedocs.io/ja/latest/reviewext/nest.html)の記法での出力には対応しています。機能を使いたい場合は`review-ext.rb`を用意して下さい。）

### 表

|ひょう|ひょー|
|------|------|
|hoge|ほげ|
|fuga|ふが|

```md {caption="Markdownなら表も簡単です"}
|ひょう|ひょー|
|------|------|
|hoge|ほげ|
|fuga|ふが|
```

### コード

```sh
$ yarn add easybooks
```

````md {caption="言語にshを指定するとRe:VIEWでいうcmdに変換されます"}
```sh
$ yarn add easybooks
```
````

```js {caption="JavaScriptなコード"}
console.log('hoge')
```

````md {caption="captionの指定もできます"}
```js {caption="JavaScriptなコード"}
console.log('hoge')
```
````

```ts {id="typescript" caption="TypeScriptなコード"}
console.log('hoge')
```

本文からの参照は[list:typescript]で。

````md {caption="IDも指定できます"}
```ts {id="typescript" caption="TypeScriptなコード"}
console.log('hoge')
```

本文からの参照は[list:typescript]で。
````

既定では行番号付きのリストになります。行番号を出力したくない場合は、`num=false` を指定してください。

````md {caption="行番号なしのリストにもできます"}
```text {num=false}
ほげ
ふが
```
````

IDを指定しない場合は自動採番されます。

### 脚注

```md {caption="脚注の書き方"}
ほげほげします[^hoge]。

[^hoge]: hogeはほげです。
```

ほげほげします[^hoge]。

[^hoge]: hogeはほげです。

### 画像

```md
![いちご](strawberries-4330211_640)
```

![いちご](strawberries-4330211_640)

* https://pixabay.com/ja/photos/%E3%82%A4%E3%83%81%E3%82%B4-%E3%83%95%E3%83%AB%E3%83%BC%E3%83%84-%E9%A3%9F%E5%93%81-%E9%A3%9F%E3%81%B9%E3%82%8B-4330211/

※現時点では、Re:VIEWでの画像の置き方に依存した書き方が必要ですが、そのうち、Markdown側でも問題無いように記述できるようにします。


### コメント

````md {caption="コメント"}
<!--
コメント！
-->
````

<!--
コメント！
-->

本来のMarkdownにはHTMLのタグを記述できますが、現時点で対応しているのはコメント表記のみです。

### 右揃え、中央揃え

````md {caption="右揃え"}
<div class="flushright">ほげ</div>
````

<div class="flushright">ほげ</div>

