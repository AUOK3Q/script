CA_SUBJECT="/O=heaven/CN=ca.ingigo.com"
SUBJECT="/C=CN/ST=beijing/L=haidian/O=666/CN=www.indigo.org"
KEY_SIZE=2048 #此值不能使用1024
SERIAL=34
SERIAL2=35

CA_EXPIRE=202210
EXPIRE=365
FILE=indigo

#生成自签名的CA证书
openssl req  -x509 -newkey rsa:${KEY_SIZE} -subj $CA_SUBJECT -keyout cakey.pem -nodes -days $CA_EXPIRE -out cacert.pem
#生成私钥和证书申请
openssl req -newkey rsa:${KEY_SIZE} -nodes -keyout ${FILE}.key  -subj $SUBJECT -out ${FILE}.csr
#颁发证书
openssl x509 -req -in ${FILE}.csr  -CA cacert.pem  -CAkey cakey.pem  -set_serial $SERIAL  -days $EXPIRE -out ${FILE}.crt

chmod 600 *.key