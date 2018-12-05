 # ooxif/nginx-secure-http

- Alpine Linux v3.8
- OpenSSL >= v1.1.1
- nginx v1.15.7
    - with http2
    - without mail
    - without stream

## Additional modules

- ngx_brotli v0.1.2
    - https://github.com/eustas/ngx_brotli
    - Brotli: a generic-purpose lossless compression algorithm
- ngx_headers_more v0.33
    - https://github.com/openresty/headers-more-nginx-module
    - useful for setting security-related response headers

## Caveat

- nginx's master process runs as `nginx` (not `root`).
    - nginx can not listen on ports < 1024.

## Usage (simple, static)

Put contents into `/etc/nginx/html`.

```sh
docker run \
  --rm \
  -v /path/to/your/contents:/etc/nginx/html \
  -p your-http-port:8080 \
  ooxif/nginx-secure-http
```

## Usage (complex, flexible)

Override `/etc/nginx/nginx.conf` with yours.
