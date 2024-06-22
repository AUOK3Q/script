#/bin/bash

clamdir=/usr/local/clamav


claminstall(){

    if [ ! -d $vlamdir ]; then
        mkdir -p $clamdir
        mkdir $clamav/{logs,update,socket}
        touch $clamdir/logs/{clamd.log,fresclam.log}
    elif id "clamav" >/dev/null; then
        chown -R clamav:clamav $clamdir
    else
        groupadd clamav
        useradd -g clamav clamav -s /sbin/nologin
        chown -R clamav:clamav $clamdir
        rpm -ivh --prefix=$clamdir ~/clamav-1.0.1.linux.x86_64.rpm
        cp $clamdir/etc/clamd.conf.sample $clamdir/etc/clamd.conf
        cp $clamdir/etc/freshclam.conf.sample $clamdir/etc/freshclam.conf
        sed -i "/Example/ s/^/#/g" $clamdir/etc/clamd.conf
        sed -i "/Example/ s/^/#/g" $clamdir/etc/freshclam.conf

        cat>> $clamav/etc/freshclam.conf<<EOF
        DatabaseDirectory /usr/local/clamav/update
        UpdateLogFile /usr/local/clamav/logs/freshclam.log
        PidFile /usr/local/clamav/update/freshclam.pid
EOF
        cat>> $clamav/etc/clamd.conf <<EOF
        LogFile /usr/local/clamav/logs/clamd.log
        PidFile /usr/local/clamav/update/clamd.pid
        DatabaseDirectory /usr/local/clamav/update
        LocalSocket /usr/local/clamav/socket/clamd.socket
EOF
        ln -s $clamdir/bin/clamscan /usr/bin/clamscan
        ln -s $clamdir/bin/freshclam /usr/bin/freshclam
    fi
}
chkrtinstall(){
    yum -y install gcc gcc-c++ make >/dev/null
    tar zxf chkrootkit.tar.gz >/dev/null
    cd chkrootkit-*
    make sense
    cd ..
    cp -r chkrootkit-* /usr/local/chkrootkit
    rm -r chkrootkit-*
    
}