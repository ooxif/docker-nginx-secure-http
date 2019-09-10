 # ooxif/nginx-secure-http

- Alpine Linux v3.10.2
    - OpenSSL >= v1.1.1 (supports TLS v1.3)
- nginx v1.17.3
    - with http2
    - without mail
    - without stream

## Additional modules

- ngx_brotli (master 2019-09-10)
    - https://github.com/google/ngx_brotli/tree/e505dce68acc190cc5a1e780a3b0275e39f160ca
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
