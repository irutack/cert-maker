#!/bin/bash

rm -rf /root/myCA
rm -rf /root/out
mkdir /root/myCA
cd /root/myCA

mkdir -p ./certs
mkdir -p ./crl
mkdir -p ./newcerts
mkdir -p ./private
touch ./index.txt
touch ./index.txt.attr
touch ./serial
echo "01" > ./serial

# chmod 700 ./private

# 自己署名済みCA証明書とその秘密鍵の生成
expect -c "
spawn openssl req \\
              -new \\
              -x509 \\
              -days 3650 \\
              -newkey rsa:2048 \\
              -out ./ca.crt \\
              -keyout ./private/ca.private.key \\
              -config ../openssl.cnf \\
              -subj \"/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Company-01/OU=InfoTech/CN=My-CA\"

expect \"PEM pass\"
send \"password\n\"
expect \"PEM pass\"
send \"password\n\"
expect \":~#\"
exit 0
"

# 認証したいサーバの証明書要求(csr)ファイルと、サーバの秘密鍵生成
openssl req \
        -new \
        -nodes \
        -keyout ./private/server.private.key \
        -out ./server.csr \
        -config ../openssl.cnf \
        -subj "/C=JP/ST=Tokyo/L=Chiyoda-ku/O=Company-01/OU=InfoTech/CN=My-Server"

# CAでサーバの証明書に署名
# sendするパスワードは、CAの生成時に指定したもの
expect -c "
spawn openssl ca \\
        -days 3650 \\
        -config ../openssl.cnf \\
        -out ./server.crt \\
        -infiles ./server.csr

expect \"Enter pass phrase \"
send \"password\n\"
expect \"Sign the certificate? \"
send \"y\n\"
expect \"requests certified, commit? \"
send \"y\n\"
expect \":~#\"
exit 0
"

# CA証明書を配布できる形に変更
openssl x509 \
        -inform pem \
        -outform der \
        -in ca.crt \
        -out myca.der \

cd /root
mkdir /root/out
cd /root/out
cp /root/myCA/myca.der ./
cp /root/myCA/server.crt ./
cp /root/myCA/private/server.private.key ./secret.key