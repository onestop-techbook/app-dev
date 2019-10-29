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
  
### 実行環境及び前提条件
* ローカル側のOS・・・ubuntu
* サーバ側（デプロイ先）のOS・・・ubuntu
* ローカル側、サーバ側ともにrbenv、rubyあり。
* ローカルからサーバへのSSH接続及びローカルからGithubへのSSH接続済み。

![fig2](fig2)

### 使用方法

#### Capistranoのインストール

Ruby on Railsでアプリケーションを作っていて、Bundlerを使っている場合は、以下のようにGemfileに
`gem 'capistrano', '~> 3.0.1'`の記述を追加して、

ローカルでの実行
```sh
$ bundle install
```
を実行します。

（ローカル）Gemfile
```sh {caption="Gemfileの指定"}
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

その後、次のコマンドを実行してcapistranoをアプリケーションにインストールします。

ローカルでの実行
```sh
$ bundle exec cap install
```

すると次のようなファイルが生成されます。
アプリケーションのホームディレクトリ
├─  Capfile
├─  config
│ ├─  deploy
│ │ ├─production.rb
│ │ └─staging.rb
│ └─deploy.rb
└─  lib
    └─capistrano
        └─tasks

ではそれぞれのファイルについて見ていきましょう。

### 各ファイルの説明
#### Capfile

Capfileはcapistrano全体の設定ファイルです。
(ローカル)Capfile
```sh
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv' 
require 'capistrano/bundler'
require 'capistrano/rails/assets' 
require 'capistrano/rails/migrations' 

# require 'capistrano3/unicorn'
# require 'capistrano/rvm'
# require 'capistrano/chruby'
# require 'capistrano/passenger'

# taskを記述したファイルを読み込むよう設定。　場所と拡張子を指定。拡張子に注意。
Dir.glob('lib/capistrano/tasks/*.rb').each { |r| import r }
```
`require`で必要な機能が書かれたファイル類を読み込んでいます。
`capistrano/setup`では主に次のことを行っています。

* SCMやデプロイ先などアプリケーション固有の変数を初期化
* config/deploy.rbの読み込み
* config/deploy/*.rbの読み込み
* SCM固有のコマンド定義を読み込み
* SSH設定を読み込み

`capistrano/deploy`では主に次のことを行っています。

* デプロイ先のディレクトリなどを準備する
* 初回のみgit cloneする
* 毎回git remote updateが行われる

#### ステージング環境.rb（production.rbとstaging.rb）
config/deploy配下に`production.rb`と`staging.rb`の２種類のファイルがあります。これらはデプロイする環境別の設定を記述するファイルであり、前者は本番環境を、後者はステージング環境を意味しています。主に次のことを設定しています。

* サーバーホスト名（デプロイ先サーバのIPアドレス）
* サーバーへのログインユーザー名
* サーバロール(※後述)
* SSH設定
* その他、そのサーバに紐づく任意の設定

ちなみに私は、本番環境のサーバーのデプロイするために次のような設定にしました。

（ローカル）config/deploy/production.rb

```sh
//デプロイ先サーバーのIPアドレス
server '3.115.145.192',
    //ログインユーザ名
    user: 'yoshikawa',
    //サーバのロール（役割）
    roles: %w{web app},
    ssh_options:{
      user: 'yoshikawa',
      //秘密鍵の位置。ローカルにある
      keys: '~/.ssh/id_rsa',
      forward_agent: true,
      auth_methods: %w{publickey},
    }
```

ロールとは、「役割」を意味します。
`roles: %w{web app}`だと、これを記述したアプリケーションはwebサーバーとアプリケーションサーバーの二つの役割を持っていることを意味します。また、DBサーバーの機能もあるなら、`roles: %w{web app db}`とする必要があります。


#### config/deploy.rb
production環境、stading環境に共通する設定を記述します。

* アプリケーション名
* gitのレポジトリ
* 利用するSCM
* タスク
* それぞれのタスクで実行するコマンド
 
アプリケーション名やレポジトリ名などの設定値は
`set :名前, 値`で設定します。


（ローカル）config/deploy.rb
```sh
# config valid for current version and patch releases of Capistrano
lock "~> 3.11.1"

#application to be deployed
set :application, "hello_world"

#git repository to be cloned
set :repo_url, "git@github.com:astrophysik928/hello_world.git"

# deployするブランチ。デフォルトはmasterなのでなくても可。
set :branch, 'master'

# deploy先のディレクトリ。 各自の状況に応じて変更してください。
set :deploy_to, '/var/www/rails/hello_world'

# シンボリックリンクをはるファイル。(※後述)
set :linked_files, fetch(:linked_files, []).push('config/settings.yml')

# シンボリックリンクをはるフォルダ。(※後述)
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# 保持するバージョンの個数(※後述)
set :keep_releases, 5

# デプロイ先サーバのrubyのバージョン
set :rbenv_ruby, '2.6.3'

#出力するログのレベル。
set :log_level, :debug

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'Create database'
  task :db_create do
    on roles(:db) do |host|
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end

  desc 'Run seed'
  task :seed do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed'
        end
      end
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
```



