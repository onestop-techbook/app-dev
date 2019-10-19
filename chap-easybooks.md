# easybooksの書き方

**※この章は、実際の本では削除されます。**

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

### リスト

* ほげ
* ふが

```md {caption="リストの書き方"}
* ほげ
* ふが
```

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
