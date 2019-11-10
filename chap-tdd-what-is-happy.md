# テスト駆動開発

<!--
    ファイル名
        chap-tdd-what-is-happy.md
    その他のタイトル候補：
        テスト駆動開発へのいざない
        テスト駆動開発の実例紹介
    Dockerイメージ取得コマンド、開始コマンド、コンパイルコマンド：
        docker pull vvakame/review:3.2
        sudo cgroupfs-mount && sudo service docker start
        docker run -t --rm -v $(pwd):/book vvakame/review:3.2 /bin/bash -ci "cd /book && yarn && yarn build"
    記法のハック的メモ：
        [list:idname]にて{id=idname}を参照できる「リストn-m」けど、idnameは**小文字のみ**が有効で注意。ハイフンはOKだった。
    検討事項：
        「§お勧めプログラミングテクニック」に入れる？
        「自動テスティング」に入れるべき？（chap-tdd-testing.md）
 -->


「テスト駆動開発」は、平たく言うと「テストをしながら、開発すること」です。
これだけ聞けば
「つまりすべてのプログラミングは、テスト駆動開発では？
なぜなら、少しコーディングしては、
意図したように動いているかをテストして、少しコーディングしては、
意図したように動居居ているかをテストして、、、を繰り返して作っていくものでしょ？」
と思う方もいるでしょう。
ある意味では、その通りです。「テスト」を、いわゆる「品質担保のための評価」ではなく、「期待した動作をするか否かを検証するための評価」と位置付ける場合には、その通りです。一般に「検証するためのテスト」は「何度も繰り返し自動でまとめて実行されるのが都合が良い」ので、「テスト駆動開発」ではテスト自体をコーディングするケースが多いです。

「テスト駆動開発」の概念や進め方そのものは、
各種の良書[^tdd-textbook-recommend]や本書の他の章（例えば、章「自動テスティング」の節「ユニットテスト」や節「TDD」）に説明を譲るとして、
本節では「では、実際にはどのように進めるのか？」をいくつかのサンプルで説明いたします。
簡単なサンプルを通して、テスト駆動開発の **雰囲気**を知っていただれば嬉しく思います。


[^tdd-textbook-recommend]: テスト駆動開発（著、Kent Beck　翻訳、和田卓人）や、実践テスト駆動開発（著、Steve Freeman、Nat Pryce　翻訳、和智右桂、髙木正弘）など。


### いわゆるA+B*2するような開発

テスト駆動の最初の導入としてよく見かける例は次です。

引数A、Bをインプットとして、A+B*2を返す機能を作りたいとします。
Notテスト駆動開発で作成する場合は、次のようになるでしょう。

1. 「頭の中で、A+B*2を作ろう」と思い描く
2. A+B*2を実装する
3. 適当な引数で実行してみて、Debbuggerかprint分で結果を確認する
4. 結果が「A+B*2になっている」ことを頭の中で計算して検証する

これをテスト駆動開発すると、次になります。

1. 「A+B*2を返して欲しい」をテストコードとして表現する（[list:simple-test-code]）
2. A+B*2を実装する
3. テストを実行する（と、結果が「A+B*2になっている」ことが検証される）

```js {id="simple-test-code" caption="簡単な検証コードの例"}
describe('add( a, b )', ()=>{
    it('returns c as a+b*2.', () => {
        var INPUT_A = 5;
        var INPUT_B = 7;
        var OUTPUT_C = 5 + 7*2; // =12
        var add = target.add;
        
        var result = add( INPUT_A, INPUT_B );

        expect(result).to.be.equal( OUTPUT_C );
    });
})
```

このくらいだと、ありがたみは誤差の範囲です。
次へ進みましょう。

### 少しだけ複雑な機能をテスト駆動開発

「任意の名前と文字列による付加情報を1つの**文字列A**として格納する。そこから名前だけを取り出したい」場面があったと仮定します。
**文字列A**の仕様を次のようにざっくり設計したとします。

* 名前の文字数は99文字まで許容する
* 最初の2文字を用いて、十進数で名前の文字数を表現する
* 3文字目から名前の文字列を格納する
* 名前の文字列が終わると、付加情報の文字列を続けて格納する

この**文字列A**から、「名前を取り出す」機能を作ることを考えます。
ササっと頭の中で実装を設計できる人も居ると思いますが、順を追って開発します。
テスト駆動開発では先ずは「**文字列A**から名前を取り出せたか？」を検証する
テストコードを作ります。[list:name-and-info-test]のようになります。

```js {id="name-and-info-test" caption="フォーマットに基づいて文字列を取り出す機能を検証"}
describe('name_and_info.js', () => {
    describe('extractName()', ()=>{
        it('returns just name.', ()=>{
            var KEY  = '04nyanmyanfunyan';
            var KEY2 = '07johndoe__hogefugapiyo';

            var result = target.extractName(KEY);
            expect(result).to.be.equal('nyan');

            result = userKey.extractName(KEY2);
            expect(result).to.be.equal('johndoe');
        });
    });
});
```

これ[list:name-and-info-test]は、JavaScript（Node.js）でMochaというテストフレームワークを使った例ですが、
テストコードを見ることで、「どんなインプットに対して、どういうアウトプットを期待しているのか？」
を読み取ることが出来ると思います[^omit-border-test-etc]。
他の言語であっても、テストフレームワークが提供されている場合が多く、
このように「英文」っぽい表現で書くことが出来ます。

[^omit-border-test-etc]: あくまでサンプルなので、境界値テストとか難しいことはここではスルーです。

「名前を取り出す」機能の目指すところが見えたので、実装しましょう。
たとえば、[list:name-and-info-impl]のようになります。

```js {id="name-and-info-impl" caption="フォーマットに基づいて文字列を取り出す機能を実装"}
var extractName = function (packedStr) {
    const digitStr = packedStr.substring(0,2);
    const userNameLength = parseInt(digitStr);
    const userName = packedStr.substring(2, 2 + userNameLength)

    return userName;
};
```

実装したら「本当に、期待したように動くのか？」を確認しましょう。
通常であれば、この関数だけを呼び出す小さなプログラムを作って、実行結果をPrint文などで表示できるようにして
動作確認するところです。
しかし、テスト駆動開発では次のコマンドを実行するだけで、検証が完了します。

```sh
npm test
```

今回のMochaフレームワークを利用した例であれば、次のように実行結果が表示されます。

```sh 
  name_and_info.js
    extractName()
      √ returns just name.

  1 passing (33ms)
```

実装が不適切だった場合は、次のように「何がどう失敗したか？」も含めて実行結果が表示されます。

```sh
  name_and_info.js
    extractName()
      1) returns just name.


  1 failing

  1) name_and_info.js
       extractName()
         returns just name.:

      AssertionError: expected 'john-r' to equal 'john-richard-doe'
      + expected - actual

      -john-r
      +john-richard-doe
```

実行結果をPrint分で出力して確認する検証に比べると、ずっと簡単に動作検証が出来ました。
このテストによる検証は、以降いつでも簡単にコマンド一つで実行できるので、
他の個所を弄った後の「意図しないところを壊してないか？」の確認も容易で安心できます。
これがテスト駆動開発の「楽しさ」と「安心さ」です。[^tdd-is-easy-and-fun-by-good-framework]

[^tdd-is-easy-and-fun-by-good-framework]: テスト結果が分かり易いのは、テストフレームワークや検証ライブラリの機能のおかげです。したがって、その辺りが整備されていない言語や、利用できない環境の場合は、テスト駆動開発の快適さと安心さの程度は下がります。



### 外部I/O（データベースやHttp通信）を伴う機能設計こそTDDで開発しよう

データベースやHttp通信等を含めた外部I/Oを伴う機能設計、外部ストレージの保存フォーマットを考慮すべき機能設計の
例でのテスト駆動開発の進め方を見てみます。

本節では例として
「任意の文字列（URLなど）が与えられた時に、6文字の文字列に短縮して返す関数、元に戻す関数」
を考えます。
実装方法としては、次のようなものがパッと思いつくでしょうか？

 * 6文字へ圧縮するアルゴリズムを用いる
 * 自前のデータベースへ保存して、識別子を6文字とする
 * 何らかのクラウドストレージに保存して、その識別子を6文字とする

本節では、「自前のデータベースに保存して、その識別子を6文字とする」を採用して話を進めます。保存仕様としている文字列の数は999999個以下とします。

本関数の機能を先の節と同様に書きだすと、次のように出来ます。

 * encode( 元の文字列 ) を呼び出すと、6文字に短縮された文字列が返却される
 * decode( 短縮後の文字列 ) を呼び出すと、元の文字列が返却される

これの機能を検証するテストコードは、[list:encode-decode-test]のように書くことが出来ます。

```js {id="encode-decode-test" caption="文字列の短縮と復元の機能を検証するコード"}
describe('decode() after encode()', ()=>{
    it('returns original strings.', ()=>{
        var NORMARL_STR  = '04nyanmyanfunyan';
        var ShortenedStr = target.ShortenedStr; // 何をキーに利用するデータベースと紐づける必要があるのでは？
        
        var intermediateStr = ShortenedStr.encode( NORMARL_STR ); // 非同期にしなてくOK？
        var result = ShortenedStr.decode( intermediateStr );

        expect(result).to.be.equal(NORMARL_STR, "元の文字列に戻ること");
        expect(intermediateStr.length).to.be.equal(6, "短縮系は文字数６であること");
    });
});
```

実際にざっと書いてみると分かりますが、[list:encode-decode-test]のコード中の
コメントにあるように、次のような疑問が湧いてきます。

 * データベースへアクセスを、関数の外で定めるべきでは？そもそもどのデータベースを使うべきか？
 * この文字列の「短縮」「復元」は、利用するライブラリのの仕様に依存して、非同期にする必要があるのではないか？

したがって、「なんらかのデータベース」に何を用いるか決めないと、
実装しようとしている関数の仕様が定められないことが分かります。
本節では、「sqliteデータベースを用いる」と決めたとします（考え方は同様なので、節タイトルに記載したHttp通信の例は割愛します）。
Node.jsであればsqlite3ライブラリを利用しますので、I/Oは「非同期である」と決まります。
したがって、関数の戻り値はPromiseオブジェクトにすればよいでしょう。
また当然ですが、encode(), decode() 関数の実装は、保存先であるSQLデータベースのテーブルに依存しますので、
テーブル構成も決める必要があります。本節の例では、単純に次のカラムを持つものを採用します。

 * ID（重複しない事）
 * 作成日時
 * 元の文字列

ここまで決めれば、動作を検証するには次のようにすれば良いことが分かります。

 1. SQLiteデータベースに、テーブル「ID、作成日時、元の文字列」のカラムを作成する(※評価用の仮）
 1. 作成したSQLiteデータベースのインスタンス元に、メソッド「encode(), decode()」を持つインスタンスを生成する（※今回に実装する関数で検証対象）
 1. 任意の文字列を encode()して6文字になり、それをdecode()して元に戻ることを検証する

上記をテストコードで表現すると、[list:encode-decode-test-enough]のようになります。
なお、動作の前提となる外部環境（データベースのテーブル）の構築のためにbeforeEach()を利用したり、
非同期の成功失敗を楽に検証するためにshouldFulfilled()を利用してたり、していますが、本書での解説は省略します。
それぞれのメソッド名から「何を期待しているものか？」はなんとなく分かるかと思いますし、
この辺りのメソッド名は、利用するプログラミング言語、テストフレームワークによって変わりますので、
本書での解説の範囲を超えるためです。本書では「アプリケーション開発で、知っておくべきこと、知っておくと良いこと」を
記載するのが目的なので、本節では「（適切な）テストフレームワークを用いると、こんな風に検証用のテストコードを書ける」
というのを何となく感じていただれば、十分です。

```js {id="encode-decode-test-enough", caption="文字列の短縮と復元の機能を検証するコード２"}
describe('decode() after encode()', ()=>{
    var dbStub = null;
    beforeEach(()=>{
        // 【略】dbStubに、検証時の前提となるテーブルが作成されたデータベースのインスタンスを格納
    });
    afterEach(()=>{
        // 【略】検証用として作成したdbStubを削除（後始末）
    })
    it('returns original strings.', ()=>{
        var NORMARL_STR  = '04nyanmyanfunyan';
        var ShortenedStr = target.factory( dbStub );
        var intermediateStr = "";

        var promise = ShortenedStr.encode( NORMARL_STR );
        promise = promise.then((resultStr)=>{
            intermediateStr = resultStr;
            return ShortenedStr.decode( intermediateStr );
        });

        return shouldFulfilled(
            promise
        ).then((result)=>{
            expect(result).to.be.equal(NORMARL_STR, "元の文字列に戻ること");
            expect(intermediateStr.length).to.be.equal(6, "短縮系は文字数６であること");
        });
    });
});
```
<!-- // 省略前のサンプルコード
    var dbStub = null;
    beforeEach(()=>{
        return new Promise((resolve, reject)=>{
            var sqlite = sqlite3.verbose();
            var db = new sqlite.Database( ':memory:', (err)=>{
                if( !err ){
                    resolve( db );
                }else{
                    reject(err);
                }
            });
        }).then((result)=>{
            return new Promise((resolve,reject)=>{
                var db = result;
                db.run(
                    'CREATE TABLE shortened([id] [INTEGER] PRIMARY KEY AUTOINCREMENT NOT NULL, [created_at] [TEXT] NOT NULL, [original_text] [TEXT] NOT NULL )',
                    [],
                    (err)=>{
                        if(!err){
                            resolve(db);
                        }else{
                            reject(err);
                        }
                    }
                );
            });
        }).then((result)=>{
            dbStub = result;
        });
    });
    afterEach(()=>{
        if(dbStub!=null){
            return new Promise((resolve,reject)=>{
                var db = dbStub;
                db.close((err)=>{
                    if(!err){
                        resolve();
                    }else{
                        reject(err);
                    }
                });
            }).then(()=>{
                dbStub = null;
            });
        }else{
            return Promise.resolve();
        }
    })

-->


テストコードを書くことは、「どういう環境で、何を検証したいのか？」を書くことに等しいです。
上記の[list:encode-decode-test-enough]を書く中で疑問が湧いてきて書き直したように、
関数の実装前にテストコードを書くことで、
「何を前提として、どういう機能を作ろうとしているのか？」を明確にすることが出来ます。
「何を前提として」がテストコードから明確に分かりますので、いわゆる「部品の再利用」をし易い
設計にもできるでしょう。

本節のテストコードを実行すると、その被テスト関数の実装具合によって、次のように
実行結果は変わります。[^omit-detail-ipml-on-tdd]
「どういう機能を作ろうとしているのか？」を表現したテストに対して、
その実行結果を以って「どこまで期待した動作が出来たか？」が一目でわかることも、
テスト駆動開発の嬉しいところです。

テスト駆動開発の「雰囲気」の説明は以上となります。
この「テスト（検証）をしながら進める開発」に少しでも興味を抱いた方は、
ぜひプログラミング言語ごとの具体的なテスト駆動開発の解説本を手に取って、
「テスト駆動開発」を実際に体験して楽しんで頂けると嬉しいです。

[^omit-detail-ipml-on-tdd]: このあたりの実装と検証のサイクルを詳しく説明するとサンプルコードに用いたNode.jでの実装説明となります。本書の目的の範囲を超えるため、割愛します。


```sh
  1) shortened_str.js
  1 failing

  1) shortened_str.js
       decode() after encode()
         returns original strings.:

      短縮系は文字数６であること
      + expected - actual

      -16
      +6
```

```sh
  1) shortened_str.js
  1 failing

 1) shortened_str.js
       decode() after encode()
         returns original strings.:

      元の文字列に戻ること
      + expected - actual

      -000001
      +04nyanmyanfunyan
```

```sh
  shortened_str.js
    decode() after encode()
      √ returns original strings.

  1 passing (105ms)
```



