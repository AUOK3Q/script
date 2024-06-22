#!/usr/bin/bash
yum install -y gcc gcc-c++ perl perl-IPC-Cmd pam pam-devel

mkdir -p /usr/local/{ssl,openssh,zlib}
./configure --prefix=/usr/local/zlib
if [ $? -eq 0 ];then
make && make install
echo '/usr/local/zlib/lib' >> /etc/ld.so.conf
./Configure --prefix=/usr/local/ssl --shared
make && make install
echo '/usr/local/ssl/lib64' >> /etc/ld.so.conf
./configure --prefix=/usr/local/openssh --with-zlib=/usr/local/zlib --with-ssl-dir=/usr/local/ssl
make && make install

config_bak(){
    mv /usr/bin/openssl /usr/bin/openssl.old
    mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    mv /usr/sbin/sshd /usr/sbin/sshd.bak
    mv /usr/bin/ssh /usr/bin/ssh.bak
    mv /usr/bin/ssh-keygen /usr/bin/ssh-keygen.bak
    mv /etc/ssh/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub.bak
}
update_config(){
    ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
    ln -s /usr/local/ssl/include/openssl /usr/include/openssl
    echo 'PermitRootLogin yes' >>/usr/local/openssh/etc/sshd_config 
    echo 'PubkeyAuthentication yes' >>/usr/local/openssh/etc/sshd_config
    echo 'PasswordAuthentication yes' >>/usr/local/openssh/etc/sshd_config
    cp /usr/local/openssh/etc/sshd_config /etc/ssh/sshd_config
    cp /usr/local/openssh/sbin/sshd /usr/sbin/sshd
    cp /usr/local/openssh/bin/ssh /usr/bin/ssh
    cp /usr/local/openssh/bin/ssh-keygen /usr/bin/ssh-keygen
    cp /usr/local/openssh/etc/ssh_host_ecdsa_key.pub /etc/ssh/ssh_host_ecdsa_key.pub
}
serv_config(){
    cp -p contrib/redhat/sshd.init /etc/init.d/sshd
    chmod +x /etc/init.d/sshd
    chkconfig --add sshd
    chkconfig sshd on
    systemctl restart sshd
}