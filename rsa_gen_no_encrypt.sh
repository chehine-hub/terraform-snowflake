#!/bin/bash

openssl genrsa 4096 | openssl pkcs8 -topk8 -inform PEM -out rsa_private_key.p8 -nocrypt
openssl rsa -in ./rsa_private_key.p8 -pubout -out rsa_pub_key.pub
sed -i ':a;N;$! ba;s/\n//g' rsa_pub_key.pub && sed -i 's/-----BEGIN PUBLIC KEY-----//g' rsa_pub_key.pub && sed -i 's/-----END PUBLIC KEY-----//g' rsa_pub_key.pub
