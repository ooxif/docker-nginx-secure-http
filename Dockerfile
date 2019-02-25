FROM alpine:3.9

ENV NGX_VERSION=1.15.8 \
	NGX_BROTLI_REPO=https://github.com/eustas/ngx_brotli.git \
	NGX_BROTLI_COMMIT_REF=v0.1.2 \
	NGX_HEADERS_MORE_VERSION=0.33

RUN GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/dev/stderr \
		--http-log-path=/dev/stdout \
		--pid-path=/var/cache/nginx/nginx.pid \
		--lock-path=/var/cache/nginx/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-compat \
		--with-file-aio \
		--with-http_auth_request_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_realip_module \
		--with-http_slice_module \
		--with-http_ssl_module \
		--with-http_stub_status_module \
		--with-http_v2_module \
		--with-threads \
		--add-module=/usr/src/ngx_brotli \
		--add-module=/usr/src/headers-more-nginx-module-$NGX_HEADERS_MORE_VERSION \
	" \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	\
	# Bring in tzdata so users could set the timezones through the environment
	# variables.
	&& apk add tzdata \
	\
	# Add build deps.
	&& apk add --virtual .build-deps \
		autoconf \
		automake \
		curl \
		cmake \
		g++ \
		gcc \
		git \
		gnupg \
		libc-dev \
		libtool \
		linux-headers \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
	\
	&& mkdir -p /usr/src \
	&& cd /usr/src \
	\
	# Prepare ngx_brotli.
	&& git clone --recursive $NGX_BROTLI_REPO \
	&& cd ngx_brotli \
	&& git checkout $NGX_BROTLI_COMMIT_REF \
	&& cd .. \
	\
	# Prepare ngx_headers_more.
	&& curl \
		-fSL https://github.com/openresty/headers-more-nginx-module/archive/v$NGX_HEADERS_MORE_VERSION.tar.gz \
		-o ngx_headers_more.tar.gz \
	&& tar -zxf ngx_headers_more.tar.gz \
	\
	# Build nginx.
	&& curl -fSL https://nginx.org/download/nginx-$NGX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL https://nginx.org/download/nginx-$NGX_VERSION.tar.gz.asc  -o nginx.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	&& rm -rf "$GNUPGHOME" nginx.tar.gz.asc \
	&& tar -zxf nginx.tar.gz \
	&& cd nginx-$NGX_VERSION \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& strip /usr/sbin/nginx \
	\
	# Add run-deps.
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --virtual .run-deps $runDeps \
	\
	# Clean build-deps.
	&& cd /etc/nginx \
	&& apk del .build-deps \
	&& rm -rf /var/cache/apk/* /usr/src /etc/nginx/*.default \
	\
	&& chown nginx:nginx /var/cache/nginx

COPY nginx.conf /etc/nginx/

RUN chmod 644 /etc/nginx/nginx.conf && chown -R root:root /etc/nginx

STOPSIGNAL SIGTERM

USER nginx
WORKDIR /etc/nginx

CMD ["nginx"]
