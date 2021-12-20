#!/bin/bash


echo $(openssl rand -base64 48) > passphrase.key
openssl genrsa -passout file:passphrase.key 4096 | openssl pkcs8 -passout file:passphrase.key -topk8 -inform PEM -out rsa_private_key.p8
openssl rsa -passin file:passphrase.key -in rsa_private_key.p8 -pubout -out rsa_pub_key.pub
sed -i ':a;N;$! ba;s/\n//g' rsa_pub_key.pub && sed -i 's/-----BEGIN PUBLIC KEY-----//g' rsa_pub_key.pub && sed -i 's/-----END PUBLIC KEY-----//g' rsa_pub_key.pub