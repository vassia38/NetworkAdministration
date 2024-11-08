#!/bin/bash
cwd=$(pwd)

apt install -y build-essential libpcre3-dev wget libssl-dev libgeoip-dev libssl-dev zlib1g-dev libxslt1-dev libgd-dev

wget https://nginx.org/download/nginx-1.24.0.tar.gz && tar -xvf nginx-1.24.0.tar.gz

cp -r ./nginx-1.24.0 /usr/local/src/nginx-1.24.0 && cd /usr/local/src/nginx-1.24.0/

#./configure --prefix=/usr --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log \
# --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid \
# --modules-path=/usr/lib/nginx/modules --with-http_ssl_module --with-http_v2_module --with-threads \
# --with-http_stub_status_module --with-http_addition_module --with-http_gunzip_module \
# --with-http_gzip_static_module --with-pcre

./configure --prefix=/usr --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
 --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock \
 --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body \
 --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy \
 --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-compat \
 --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module \
 --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads \
 --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module \
 --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic \
 --with-stream_ssl_module --with-mail=dynamic --with-http_geoip_module
make
make install

cp $cwd/nginx.conf /etc/nginx/
cp $cwd/nginx.service /etc/systemd/system/
cp -r $cwd/html/ /usr/

sudo systemctl start nginx.service
