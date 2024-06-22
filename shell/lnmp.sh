#!/bin/bash
#LNMP环境部署

SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;34m"
SETCOLOR_NORMAL="echo -e \\033[1;39m"

#测试yum源是否可用
test_yum {
    yum clean all &>/dec/null
    num=$(yum repolist -e 0 | awk '/repolist/{print $2}' | sed '/s,//')
    if [ $num -le 0 ];then
        $SETCOLOR_FAILURE
        echo -n "[ERROR]:没有yum源!"
        $SETCOLOR_NORMAL
        exit
    fi
}

#安装依赖包
install_deps() {
    yum -y install gcc pcre-devel openssl-devel cmake ncurses-devel
    yum -y install gcc0c++ bison bison-devel
    yum -y install libxml2 libxml2-devel curl curl-devel libjpeg libjpeg-devel
    yum -y install freetype gd gd-devel
    yum -y install freetype-devel libxslt libxslt-devel bzip2 bzip2-devel
    yum -y install libpng libpng-devel 
}

#源码安装配置
install_nginx() {
    if ! id nginx &>/dev/null;then
       useradd -s /sbin/nologin nginx
    fi
    tar -xvf nginx-x.x
    cd nginx
    ./configure --prefix=/usr/local/nginx \
    --user=nginx --group=nginx \
    --with-http_stub_status_module \
    --with-stream \
    --with-http_realip_module \
    --with-http_ssl_module \
    --with-http_autoindex_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    $SETCOLOR_WARNING
    echo -n "正在编译nginx,请耐心等候..."
    @SETCOLOR_NORMAL
    make &>/dev/null && make install &>/dev/null
    cd ..
    ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

}

#手动写service文件，方便使用systemd管理
conf_nginx_systemd() {
cat > /usr/lib/systemd/system/nginx.service  <<- EOF
    [unit]
    Description=nginx
    After=syslog.target network.target

    [service]
    Type=forking
    PIDFile=/usr/local/nginx/logs/nginx.pid
    ExecStartPre=/usr/sbin/nginx -t
    ExecStart=/usr/local/nginx/sbin/nginx
    ExecReload=/usr/sbin/nginx -s reload
    ExecStop=/bin/kill -s QUIT $MAINPID

    [install]
    WantedBy=multi-user.target
EOF
}

#源码安装mysql8.0
install_mysql8() {
    if ! id mysql &>/dev/null ;then
        useradd -s /sbin/nologin mysql
    fi
    tar -xf mysql
    cd mysql
    $SETCOLOR_WARNING
    echo -n "请确保有2G的可用内存"
    echo -n "编译过程稍久,请耐心等待..."
    $SETCOLOR_NORMAL
    sleep 5
    cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8_general_cl \
    -DENABLED_LOCAL_INFILE=ON -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_FEDRATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DWITH_BOOST=./boost \
    -DSYSCONFDIR=/etc/ -DMYSQL_UNIX_ADDR=/tmp/mysql.sock

    make -j 5
    make install
    chown -R mysql.mysql /usr/local/mysql/
    mkdir /var/log/mariadb
    touch /var/log/mariadb/mariadb.log
    chown -R mysql.mysql /var/log/mariadb
    mkdir -p /var/lib/mysql/data/
    chown -R mysql.mysql /var/lib/mysql/
    ln -s /usr/local/mysql/bin/* /bin/
    cat > /etc/ld.so.conf.d/mysql.conf <<- EOF
        /usr/local/mysql/lib
EOF
    cd ..
}

init_mysql8() {
#创建MySQL配置文件（socket、数据库目录、参数优化）
cat > /etc/my.cnf <<- EOF
    [client]
    port = 3306
    socket = /tmp/mysql.sock

    [mysqld]
    port = 3306
    socket = /tmp/mysql.sock
    datadir = /var/lib/mysql/data
    skip-external-locking
    key_buffer_size = 16M
    max_allowed_packet = 1M
    table_open_cache = 64
    sort_buffer_size = 512K
    net_buffer_length = 16K
    read_buffer_size = 256K
    read_rnd_buffer_size = 512K
    myisam_sort_buffer_size = 8M
    thread_cache_size = 8
    tmp_table_size = 16M
    performance_schema_max_table_instance = 500
    back_log = 3000
    binlog_cache_size = 2048KB
    binlog_checksum = CRC32
    binlog_order_commits = ON
    binlog_rows_query_log_events = OFF
    binlog_row_image = full
    binlog_stmt_cache_size = 32768
    block_encryption_mode = "aes-128-ecb"
    bulk_insert_buffer_size = 4194304
    character_set_filesystem = binary
    character_set_server = utf8mb4
    default_time_zone = SYSTEM
    default_week_format = 0
    delayed_insert_limit = 100
    delayed_insert_timeout = 100
    delayed_queue_size = 1000
    delay_key_write = ON
    disconnect_on_expired_password = ON
    range_alloc_block_size = 4096
    range_optimizer_max_mem_size = 8388608
    table_difinition_cache = 512
    table_open_cache = 2000
    table_open_cache_instances = 1
    thread_cache_size = 100
    thread_stack = 262144
    explicit_defaults_for_tmestamp = true
    #skip-networking
    max_connections = 10000
    max_connect_errors = 100
    open_files_limit - 65535
    log-bin = mysql-bin
    binlog_format = mixed
    server-id = 1
    binlog_expire_logs_seconds = 864000
    early-plugin-load = ""

    default_storage_engine = InnoDB
    innodb_file_per_table = 1
    innodb_data_home_dir = /var/lib/mysql/data
    

}
