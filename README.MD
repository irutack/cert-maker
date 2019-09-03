# オレオレ認証局作成 → 証明書作成
## abst
dockerで使い捨ての認証局と、それに署名されたサーバー証明書を作る

## setting
`/etc/ssl/openssl.cnf`を  
`/root/myCA/`にコピーしてきて以下のように修正した。  
```
# RANDFILE		= $ENV::HOME/.rnd
# RANDFILE	= $dir/private/.rand	# private random number file

[ CA_default ]
dir = /root/myCA
certificate	= $dir/ca.crt 	# The CA certificate
private_key	= $dir/private/ca.private.key # The private key

[ req ]
default_md = sha256

[ usr_cert ]
basicConstraints=CA:TRUE
nsCertType = client, email
subjectAltName          = @alt_names

[ v3_req ]
subjectAltName          = @alt_names

[ SAN ] # 新規追加
subjectAltName = @alt_names

[alt_names] # 新規追加
IP.1 = 192.168.1.1 # webサーバーのIPにする
# IP.2 = 192.168.2.15
DNS.1 = ssl.test # テスト用のDNS名。これで動く
# DNS.2 = www.tmp.jp
# DNS.3 = ccc.bbb.tmp.jp
```
RANDFILEは、.rnd ファイルがない、というエラーが出るのでコメントアウト。  
githubのリポジトリ見るとなくなってるので、ちゃんと最新版入れれば消えているはず...

## 実行
1. openssl.cnf を修正  
  `[ alt_names ]` の IP.1を稼働させるwebサーバのものに  
  IP.2など書けば複数指定もできる
1. makeCA.sh を修正(下記項目)
    + -subjオプションの引数
    + expectコマンド内でsendしているpass phrase
1. 生成  
    ```
    docker-compose up -d
    ```
1. 生成物  
  `files/out`以下に生成される
1. 片付け  
    ```
    docker-compose down
    ```

## 証明書インストール
myca.derをクライアント端末(のブラウザ)にインストールする

## サーバへの配備
生成された
  + server.crt
  + server.private.key  

を用いてwebサーバーを動かす