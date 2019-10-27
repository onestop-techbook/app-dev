# デプロイツールのCapistranoの仕組み、ワークフロー、エラーについて

## Capistranoとは？

Capistranoとはローカルで制作したアプリケーションを、自動で本番環境にサーバにデプロイするツールのことです。アプリケーションは製作するだけではなく、それを本番環境に上げるのも一苦労です。手動でおこなえばミスも発生しやすくなりますし、また本番環境でアプリケーションが起動中にバージョンアップしたものをそのままアップしようとすれば、システムにも影響が出ます。それをなくし、コマンド一発でデプロイ及び更新を可能にするのが、このCapistranoです。

![fig1](fig1)

CapistranoはRubyで記述されており、同じくRubyで作られたRuby on Railsでもよく使われます。Rubyで記述されているものの、PHPのような他の言語で記述されたアプリケーションのデプロイでも使用できます。


## ワークフローについて

Capistranoを使用する流れは以下の通りです。
  1. ローカルでCapistranoのインストール
  2. 設定ファイルの作成
  3. 設定ファイルの編集
  4. コマンド「bundle exec cap production deploy」の実行
  5. デプロイ完了
  
  ## 実行環境及び前提条件
  - ローカル側のOS・・・ubuntu
  - サーバ側（デプロイ先）のOS・・・ubuntu
  - ローカル側、サーバ側ともにrbenv、rubyあり。
  - ローカルからサーバへのSSH接続及びローカルからGithubへのSSH接続済み。

![fig2)](fig2)

## 使用方法

### Capistranoのインストール
---------------------------
Ruby on Railsでアプリケーションを作っていて、Bundlerを使っている場合は、以下のようにGemfileに
`gem 'capistrano', '~> 3.0.1'`の記述を追加して

>ローカルでの実行
```sh
[hello_world] $ bundle install
```
を実行します。


>（ローカル）Gemfile
```sh
source 'https://rubygems.org'

gem 'rails',        '5.1.6'
gem 'puma',         '3.9.1'
gem 'sass-rails',   '5.0.6'
gem 'uglifier',     '3.2.0'
gem 'coffee-rails', '4.2.2'
gem 'jquery-rails', '4.3.1'
gem 'turbolinks',   '5.0.1'
gem 'jbuilder',     '2.6.4'
gem 'sqlite3',      '1.3.13'

group :development, :test do
  gem 'byebug', '9.0.6', platform: :mri
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
end

group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.1.5'
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'
  
end

group :production, :staging do
  gem 'unicorn'
end

# Windows環境ではtzinfo-dataというgemを含める
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```

ネットの記事のよっては`capistrano3-unicorn`というgemを使用しているものを多数見かけます。しかし、場合によってエラーが出ることがあるので記述はやめましょう。

