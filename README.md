 # ooxif/nginx-secure-http

- Alpine Linux v3.11.6
    - OpenSSL >= v1.1.1 (supports TLS v1.3)
- nginx v1.18.0
    - with http2
    - without mail
    - without stream

## Additional modules

- ngx_brotli (master 2020-04-23)
    - https://github.com/google/ngx_brotli/tree/25f86f0bac1101b6512135eac5f93c49c63609e3
    - Brotli: a generic-purpose lossless compression algorithm
- ngx_headers_more v0.33
    - https://github.com/openresty/headers-more-nginx-module
    - useful for setting security-related response headers

## Caveat

- nginx's master process runs as `nginx` (not `root`).
    - nginx cannot listen on ports < 1024.

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
