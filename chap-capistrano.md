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

以下実行コマンドを併記して説明を進めますが、ローカルでの実行は

```sh
[local] $ bundle install
```

サーバでの実行は、

```sh
[server] $ bundle install
```

という形で記載します。

### 使用方法

#### Capistranoのインストール

Ruby on Railsでアプリケーションを作っていて、Bundlerを使っている場合は、以下のようにGemfileに
`gem 'capistrano', '~> 3.0.1'`の記述を追加して、ローカルで実行します。
```sh
[local] $ bundle install
```

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


```sh
[local] $ bundle exec cap install
```

すると次のようなファイルが生成されます。

![fig-folder](ファイル構成)

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

「シンボリックリンク」という言葉が見られます。
シンボリックリンクとは、簡単に言うとWindowsにおけるショートカットのようなもので、あるフォルダやファイルのリンクを保持しています。

Capistranoを通じたデプロイの流れの中では、git pushを行っています。
しかし、**セキュリティー的にIDやパスワードなどをそのままgitにプッシュしてしまうと危険**です。

そこでシンボリックリンクを用いて、gitにあげるファイルには`password: [この値を参照]`と記述しておいて、シンボリックで指定した箇所に、その値を直接書き込みます。これで同じものを参照しているようにしています。

こうすることで、gitに重要データのファイルを上げることなく、且つプログラムも正常に動かすことができます。

例えば
`set :linked_files, fetch(:linked_files,[]).push('config/settings.yml')`
だと、
**「ここの値を参照」と書いた箇所と、config/settings.ymlに書かれている値は同一**と設定をしていることになります。

今回はこの環境変数の置き場所を、「.push('config/settings.yml')」と指定しているので、`shared/config/settings.yml`というファイルを生成し、そこに環境変数を記載する必要があります。

まずはローカルでsecret_key_base用の乱数を生成します。

```sh
[local]$: rake secret
jr934ugr89vwredvu9iqfj394vj9edfjcvnxii90wefjc9weiodjsc9oi09fiodjvcijdsjcwejdsciojdsxcjdkkdsv
//表示されるkeyをコピーする
```

そしてデプロイ先サーバーに、ローカルで生成したsecret_key_base（jr93...）を登録します。乱数は各ローカルによって異なります。

デプロイ先サーバーでの実行
```sh
[server|~] $: cd /var/www/rails/hello_world
[server|hello_world] $: mkdir shared
[server|hello_world] $: cd shared
[server|shared] $: mkdir config
[server|cd shared] $: cd config
[server|cd config] $: vi settings.yml
```
新規作成するsettings.ymlには、下記のように記述しましょう。

(デプロイ先サーバー)shared/config/settings.yml
```sh
production:
  secret_key_base: jr934ugr89vwredvu9iqfj394vj9edfjcvnxii90wefjc9weiodjsc9o i09fiodjvcijdsjcwejdsciojdsxcjdkkdsv 
(#ここに先ほど生成した乱数を貼り付け)
```
以上で環境変数の登録は完了です。

#### unicorn.rb
ここではunicornの動作メソッドやpidファイルについて設定します。ちなみにunicornとはHTTPサーバの一種です。unix環境でrailsアプリケーションを動かすために使われます。
nginxと一緒に使われるのが一般的です。nginxとの併用でサーバのダウンタイムなしでデプロイできるようになります。

(ローカル)lib/capistrano/tasks/unicorn.rb
```sh
#unicornのpidファイル、設定ファイルのディレクトリを指定
namespace :unicorn do
  task :environment do
    set :unicorn_pid,    "#{current_path}/tmp/pids/unicorn.pid"
    set :unicorn_config, "#{current_path}/config/unicorn/production.rb"
  end

#unicornをスタートさせるメソッド
  def start_unicorn
    within current_path do
      execute :bundle, :exec, :unicorn, "-c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
    end
  end

#unicornを停止させるメソッド
  def stop_unicorn
    execute :kill, "-s QUIT $(< #{fetch(:unicorn_pid)})"
  end

#unicornを再起動するメソッド
  def reload_unicorn
    execute :kill, "-s USR2 $(< #{fetch(:unicorn_pid)})"
  end

#unicronを強制終了するメソッド
  def force_stop_unicorn
    execute :kill, "$(< #{fetch(:unicorn_pid)})"
  end

#unicornをスタートさせるtask
  desc "Start unicorn server"
  task start: :environment do
    on roles(:app) do
      start_unicorn
    end
  end

#unicornを停止させるtask
  desc "Stop unicorn server gracefully"
  task stop: :environment do
    on roles(:app) do
      stop_unicorn
    end
  end

#既にunicornが起動している場合再起動を、まだの場合起動を行うtask
  desc "Restart unicorn server gracefully"
  task restart: :environment do
    on roles(:app) do
      if test("[ -f #{fetch(:unicorn_pid)} ]")
        reload_unicorn
      else
        start_unicorn
      end
    end
  end

#unicornを強制終了させるtask 
  desc "Stop unicorn server immediately"
  task force_stop: :environment do
    on roles(:app) do
      force_stop_unicorn
    end
  end
end
```
unicornは起動する際に、PID(アプリケーションのプロセスID。29642など)を生成します。

そしてこの生成されたPIDは、
`#{current_path}/tmp/pids/unicorn.pid`（ディレクトリはデプロイ先サーバー）に自動で記述されます。ここに番号が書かれているか否かで、OSはunicornが起動しているかを判断します。

このPIDがunicorn.pidファイルに残っている状態で、unicornを起動させてデプロイしようとすると、OSが「起動している状態」だと判断するためエラーが出ます。私の場合、unicorn.pidを残したままでcapistranoでデプロイしようとすると`No such process`、`kill stdout:`、 `Nothing written`、`kill stderr: kill`というエラーが見られました（ちなみにunicorn.pidを削除するとこれらのエラーは消えました）。

unicornでは次のようなことを行います。

1. 既に起動しているPIDをpid_oldbinという名前に変更し
2. 新しいPIDを立ち上げて
3. 新しいPIDと古いpidを一瞬同時に動かした後
4. 古いPID(pid_oldbin)を停止させる（kill） 


これによりアプリケーションが停止するタイミングが無くなります。稼働を止めず、再起動ができようになります(`ホットデプロイ`)。これはunicornの重要な特徴と言えるでしょう。


#### config/unicorn/production.rb

unicornの設定ファイルです。デプロイ先サーバーのディレクトリとファイル名を自分のケースに合わせて設定します。

(ローカル)config/unicorn/production.rb
```sh
#ワーカーの数。後述
  $worker  = 2
  
#何秒経過すればワーカーを削除するのかを決める
  $timeout = 30
  
#自分のアプリケーション名、currentがつくことに注意。
  $app_dir = "/var/www/rails/hello_world/current"
  
#リクエストを受け取るポート番号を指定。後述
  $listen  = File.expand_path 'tmp/sockets/.unicorn.sock', $app_dir
  
#PIDの管理ファイルディレクトリ
  $pid     = File.expand_path 'tmp/pids/unicorn.pid', $app_dir
  
#エラーログを吐き出すファイルのディレクトリ
  $std_log = File.expand_path 'log/unicorn.log', $app_dir

# 上記で設定したものが適応されるよう定義
  worker_processes  $worker
  working_directory $app_dir
  stderr_path $std_log
  stdout_path $std_log
  timeout $timeout
  listen  $listen
  pid $pid

#ホットデプロイをするかしないかを設定
  preload_app true

#fork前に行うことを定義。後述
  before_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
    old_pid = "#{server.config[:pid]}.oldbin"
    if old_pid != server.pid
      begin
        Process.kill "QUIT", File.read(old_pid).to_i
      rescue Errno::ENOENT, Errno::ESRCH
      end
    end
  end

#fork後に行うことを定義。後述
  after_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  end
```
ソースコードを見ていると、`worker`、`before_fork`という文字が見られます。これらは何を意味するのでしょうか。

実はunicornでは`worker`、`fork`そして`master`という考え方があります。
一つのmasterが複数のworkerを制御しています。このmasterが各々のworkerに特定の処理を実行するよう命令しています。

```sh
 $worker  = 2
```

ここではworkerの数を決めています。またworker数が多いと、消費するメモリー数も大きくなるため特定の時間が経過すれば、削除するように指定します。以下がそのタイミングを指定している個所です。


```sh
 $timeout = 30
```

forkとは、masterがworkerを生み出すプロセスのことを指します。
よってbefore_fork、after_forkとは、workerが生成される前後で実行するタスクの定義になります。

## 本番サーバーへのデプロイ

一通りファイルへの設定が完了したら、次は本番環境にデプロイしましょう。デプロイ前にローカルのターミナルに移りデプロイするアプリケーションのホームディレクトリまで移動しておきます。
その後、次のコマンドを実行します。

ローカルでの実行
```sh
[local] $ bundle exec cap production deploy
```
すると、「mkdir」「git」「bundle install」「unicorn restart」…といったコマンドが次々と実行されます。

デプロイが成功すると、次のような画像が見えるはずです。

![fig3](fig3)
![fig4](fig4)

ちなみにいったんデプロイしたアプリケーションをローカルで編集し、再度デプロイし直す時も
ローカルでの実行
```sh
[local] $ bundle exec cap production deploy
```
を実行します。

## capistranoに関係するエラーとその解決策

これらのエラーが出ることがあり、エラーの原因や対応策について説明します。

* ssh::connectiontimeout  
* linked file /var/www/rails/hello_world/shared/config/`settings.yml` does no…

* The deploy has failed with an error: Don't know how to build task 'unicorn:restart' (See the list of available tasks with cap --tasks)

* No such prosess

* Gem::LoadError: Specified 'sqlite3' for database adapter, but the gem is not loaded. Add `gem 'sqlite3'` to your Gemfile (and ensure its version is at the minimum required by ActiveRecord).

 
#### ssh::connectiontimeout
このエラーはローカルとデプロイ先サーバーとの間のSSHが確立できていない時に発生します。ローカルで`ssh-keygen`を使って秘密鍵と公開鍵を生成し、公開鍵をデプロイ先サーバーも登録しておきましょう。

#### linked file /var/www/rails/hello_world/shared/config/settings.yml does no…

表示されたデプロイ先サーバーのディレクトリ
（/var/www/rails/hello_world/shared/config）に、`settings.yml`がなかったことで発生しています。そのためデプロイ前に指定のディレクトリにsettings.ymlを作成しておきましょう。

#### The deploy has failed with an error: Don’t know how to build task ‘unicorn:restart’ (See the list of available tasks with cap --tasks)

 
 このエラーはunicorn.rbが読み込まれないことによって、unicorn:restartというタスクが実行されないので、発生してます。Capfileの下に「Dir.glob…」という箇所があり、taskファイルの拡張子が正しいか注意を払う必要があります。私の場合は「.rb」なので次のように設定しました。
 
 ```sh
 Dir.glob('lib/capistrano/tasks/*.rb').each { |r| import r }
 ```
 ネットの記事によっては「.rb」ではなく、「`.rake`」や「`.cap`」になっているケースもあります。次のような記述です。
 ```sh
 Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
 ```
 ```sh
 Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
 ```
 
 それぞれの設定に合わせて、編集するようにしましょう。

#### No such prosess
このエラーは、capistranoが削除しようとしたプロセスIDが実行後既に消去されたか、またはシステム内で別のプロセスIDに置き換えられた時に発生します。解決策としては、デプロイ先サーバーの`/var/www/rails/hello_world/current/tmp/pids`にある`unicorn.pid`を削除しましょう。unicorn.pidには「24368」のようなプロセスIDが記載されています。これを削除後にもう一度デプロイしましょう。

#### Gem::LoadError: Specified ‘sqlite3’ for database adapter, but the gem is not loaded. Add gem 'sqlite3' to your Gemfile (and ensure its version is at the minimum required by ActiveRecord).

これはsqlite3がインストールされていないことにより発生しています。`Gemfile`に`gem 'sqlite3'`の記述を追加したら、

ローカルでの実行
```sh
[local] $ bundle install
```
を実行します。ただし、場合によってはこれでも同じエラーが消えない場合があります。その時は本番環境であるデプロイ先サーバーでもsqlite3をインストールしましょう。私の場合、デプロイ先サーバーのOSはubuntuでしたので次のコマンドを実行しました。本番環境にもsqlite3をインストールするとエラーは消えました。

デプロイ先サーバーでの実行
```sh
[server|~] $:sudo apt-get install sqlite3 libsqlite3-dev
```
sqlite3に関わらず、ローカルと本番環境の両方に必要なソフトウェアやライブラリがインストールされているかは重要な注意点です。

## 参考URL

「入門 Capistrano 3 ~ 全ての手作業を生まれる前に消し去りたい」

https://labs.gree.jp/blog/2013/12/10084/


「(Capistrano編)世界一丁寧なAWS解説。EC2を利用して、RailsアプリをAWSにあげるまで」

https://qiita.com/naoki_mochizuki/items/657aca7531b8948d267b

「A remote server automation and deployment tool written in Ruby.」

https://capistranorb.com/

