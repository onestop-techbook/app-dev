# ワンストップ本

## 概要説明
ワンストップ　アプリケーション開発

## この本の目的

何かしらアプリを開発している人は多いと思います。

* 個人開発のアプリ
* 会社での大きなアプリ開発
* ウェブアプリ・モバイルアプリ

などなど。

アプリケーションを作るために必要なノウハウを詰め込んだ本にしたいと思っています。

アプリケーション開発には、ソフトウェアエンジニアだけではなく、グラフィックデザイナーの人も、ウェブディレクター、企画者、営業、さまざまな立場の人が関わるものです。

これまでの登壇内容、思ったこと、こころがけていること、アンチパターン、失敗例、合同誌にしませんか？

テクニカルな話、エモい話、両方OKです。
* 簡単なアプリの作り方
* アプリ作りの失敗談
* アプリ作りをやり遂げるコツ
* 要件定義、目的、ニーズ
* 仕様、画面、テスト
* 公開にあたっての考えること
  - ライセンス、法律
* 個人開発、チーム開発、モブプロ
* 開発プロセス
  - ウォーターフォール
  - リーン開発
  - アジャイル
* 言語について
* 開発の規模やチームについて
* その他関係ありそうなこと全部

アプリを作るという話題における全てを詰め込んだ最高の一冊にしたいです。

それらに関するノウハウやテクニックを整理していただけませんか？
あるいは、自分の体験をまとめてみませんか？

文章に起こすことで整理される側面もあるでしょう。
他の人と共有しやすくなることもあるでしょう。
それを見て、行動を起こす人がいるかもしれません。

1ページからでも構いません。執筆者の仲間入りです。
5ページ書けますか？まとまった量で読み応えありますね。
10ページ書きますか？どんとこい。
そして、あなたの本を技術書典に参加する1万人（あるいはそれ以上）に届けませんか？

詳細なもくじは、こちらで編集中。
https://hackmd.io/KnQ710qLTHOlDlvE_ySIcw
書けそうなところから書いていってください。
追記、順番変更、その他大歓迎。

## 執筆・配布スケジュール
募集開始・環境構築　2019月8月10日  
章目次確定：9月15日  
本文初稿：9月30  
レビュー＆追記：10月30日  
入稿:11月20日
発行　技書博２(12月14日＠プラザマーム)

## 著者紹介兼あとがき
Contributers.re内に、テンプレートに従って記入ください。

## 執筆にあたってのお願い
CIでコンパイルが通ることを確認してください。エラーのまま放置はなるべくやめてください。

Confrictが発生した場合は、解決お願いします。

push -f等はやめましょう。（歴史を書き換えてはいけません。

相談事：
Issue立ててください。

雑談、ざっくばらんな相談については、Slackがあります。
参加方法は、親方まで。https://twitter.com/oyakata2438

## Re:VIEWの書き方

[Re:VIEWチートシート](https://gist.github.com/erukiti/c4e3189dda179a0f0b73299fb5787838) を作ってみたので、参考にしてみてください。

chap-easybook.md内に書き方チュートリアルがあるので、参考にしてみてください。

また、プレーンテキストやWordとかでの提出も可能です。編集部にてコンバートします。

## CI
https://app.wercker.com/oyakata2438/app-dev/runs
でPDFが書きだされます。
一番上のBuildをクリックすると展開されるので、
Output Artifactをクリックして、Download artifactをクリックすると、
tarで固めたpdfがダウンロードできます。

## インストール

細かい準備(TeX入れたり)は[『技術書をかこう！』](https://github.com/TechBooster/C89-FirstStepReVIEW-v2)に準じます。

### WindowsでReviewを使う方法

https://qiita.com/implicit_none/items/398c6e0bbedc8b160621
暗黙の型宣言さんが詳しく書いてくれてます。あるいは、技術同人誌を書こう‐アウトプットのススメ‐をご覧ください。

Windows10(Home/Pro問わず)であれば、WSL＋docker越しにRe:VIWEを扱う方法もあります。https://qiita.com/hoshimado/items/7592cee28c1bde545b78

※2019/11/04時点で、次の環境にて後述のdockerコマンドからコンパイル出来ることを確認済み。

<!-- (3.1指定は、2.x環境と共存のため) -->

* Microsoft Windows 10 Home Version 1903 
* Ubuntu 16.01
* Docker version 17.03.2-ce, build f5ec1e2
* Docker image : vvakame/review (tag:3.1)
* Docker image : vvakame/review (tag:3.2)


### Dockerを使う方法

Dockerを使うのが一番手軽です。

```sh
$ docker run -t --rm -v $(pwd):/book vvakame/review:3.1 /bin/bash -ci "cd /book && yarn && yarn build"
$ docker run -t --rm -v $(pwd):/book vvakame/review:3.2 /bin/bash -ci "cd /book && yarn && yarn build"

```

### Docker使わずビルド

```sh
cd articles ; review pdfmaker config.yml
```

### 権利

ベースには、[TechBooster/ReVIEW\-Template: TechBoosterで利用しているRe:VIEWのテンプレート（B5/A5/電子書籍）](https://github.com/TechBooster/ReVIEW-Template) を使っています。

  * 設定ファイル、テンプレートなど制作環境（techbooster-doujin.styなど）はMITライセンスです
    * 再配布などMITライセンスで定める範囲で権利者表記をおねがいします
