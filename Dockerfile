FROM centos:centos7
COPY Centos-altarch-7.repo /etc/yum.repos.d/CentOS-Base.repo
COPY epel.repo  /etc/yum.repos.d/epel.repo
COPY resolv /etc/resolv.conf

RUN yum install -y wget libpcre3-dev build-essential libssl-dev zlib1g-dev    && \
    rm -rf /var/lib/yum/lists/*

RUN yum install gcc  pcre pcre-devel zlib zlib-devel openssl openssl-devel -y && rm -rf /var/lib/yum/lists/*
WORKDIR /opt

RUN wget http://nginx.org/download/nginx-1.21.6.tar.gz && \
    tar -zxvf nginx-1.*.tar.gz && \
    cd nginx-1.* && \
    ./configure --prefix=/opt/nginx --user=nginx --group=nginx --with-http_ssl_module --with-ipv6 --with-threads --with-stream --with-stream_ssl_module && \
    make && make install && \
    cd .. && rm -rf nginx-1.*

# nginx user
RUN groupadd nginx &&   useradd --system --no-create-home --shell /bin/false -g nginx nginx

# config dirs
RUN mkdir /opt/nginx/http.conf.d && mkdir /opt/nginx/stream.conf.d

ADD nginx.conf /opt/nginx/conf/nginx.conf
ADD zero_downtime_reload.sh /opt/nginx/sbin/zero_downtime_reload.sh

WORKDIR /

EXPOSE 80 443

CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
