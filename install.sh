#!/bin/bash -x

shadowsocks_passwd=woshimima
shadowsocks_port=9876
shadowsocks_local_port=1087
shadowsocks_encrypt_method=aes-256-cfb

script_dir=/sandbox
local_ip=0.0.0.0

yum update -y
yum upgrade -y

yum install -y git kernel-devel autoconf libtool pcre-devel asciidoc xmlto zlib-devel openssl-devel vim net-tools

#local_ip=`ifconfig eth0 | awk '/inet / {print $2}'`

[ -d $script_dir ] || mkdir -p $script_dir
cd $script_dir

git clone https://github.com/shadowsocks/shadowsocks-libev.git

cd shadowsocks-libev
./configure

if [ $? -gt 0 ] ; then
    echo "shadowsocks configure failed!"
    exit 2
fi

make && make install

if [ ! $? -eq 0 ] ; then
    echo "shadowsocks install failed!"
    echo "If you want to delete the installation package, find it in $script_dir/shadowsocks-libev"
    exit 3
fi

cat > start <<EOF
#!/bin/bash
nohup ss-server -u -s $local_ip -p $shadowsocks_port -l $shadowsocks_local_port -k $shadowsocks_passwd -m $shadowsocks_encrypt_method >${script_dir}/sslog_${shadowsocks_port}.log 2>&1 &
iptables -P INPUT ACCEPT
iptables -F
EOF

chmod +x start
./start &
