#!/bin/sh -eu

chmod -R 755 /usr/share/nginx/html
cp -r /app/build/web/* /usr/share/nginx/html

nginx -g "daemon off;"