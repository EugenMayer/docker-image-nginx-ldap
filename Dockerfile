FROM alpine:3.7 as nginx-build

MAINTAINER Eugen Mayer <eugen.mayer@kontextwork.de>

ENV NGINX_VERSION release-1.15.2

RUN echo "==> Installing dependencies..." \
 && apk update \
 && apk add --virtual build-deps \
    make gcc musl-dev openldap-dev \
    pcre-dev libressl-dev zlib-dev \
    linux-headers wget git \
    && mkdir /var/log/nginx \
	&& mkdir /etc/nginx \
	&& cd ~ \
	# using custom source to fix group matching with openldap and other group related fixes
	&& git clone https://github.com/EugenMayer/nginx-auth-ldap \
	&& git clone https://github.com/nginx/nginx.git \
	&& cd ~/nginx \
	&& git checkout tags/${NGINX_VERSION} \
	&& ./auto/configure \
		--add-module=/root/nginx-auth-ldap \
		--with-http_ssl_module \
		--with-debug \
		--conf-path=/etc/nginx/nginx.conf \ 
#		--sbin-path=/usr/sbin/nginx \ 
		--error-log-path=/var/log/nginx/error.log \ 
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
        --with-stream \
        --with-stream_ssl_module \
        --with-debug \
        --with-file-aio \
        --with-threads \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_v2_module \
        --with-http_auth_request_module \
	&& echo "==> Building Nginx..." \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install

FROM alpine:3.7

MAINTAINER Eugen Mayer <eugen.mayer@kontextwork.de>

ENV DOCKERIZE_VERSION v0.6.1

ARG NGINX_PREFIX="/usr/local/nginx"

COPY --from=nginx-build "${NGINX_PREFIX}/" "${NGINX_PREFIX}/"
COPY --from=nginx-build "/etc/nginx/" "/etc/nginx/"

RUN echo "==> Finishing..." \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& mkdir /etc/nginx/conf.d \
	&& rm -f /etc/nginx/*.default \
	&& mkdir /var/log/nginx \
        && touch /var/log/nginx/access.log /var/log/nginx/error.log \
	&& mkdir -p /usr/share/nginx/html \
	&& install -m644 ${NGINX_PREFIX}/html/index.html /usr/share/nginx/html/ \
	&& install -m644 ${NGINX_PREFIX}/html/50x.html /usr/share/nginx/html/ \
    && ln -sf ${NGINX_PREFIX}/sbin/nginx /usr/sbin/nginx \
	&& apk update \
	&& apk add --no-cache \
        libpcrecpp libpcre16 libpcre32 libressl libssl1.0 pcre libldap libgcc libstdc++ \
	&& rm -rf /var/cache/apk/* \
	&& wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
	&& tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz \
	&& rm -rf /tmp/dockerize.tar.gz

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR ${NGINX_PREFIX}/

ONBUILD RUN rm -rf html/*

EXPOSE 80 443

COPY run.sh /run.sh
CMD ["/run.sh"]
