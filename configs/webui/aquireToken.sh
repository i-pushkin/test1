#!/bin/bash

API_NAME=oz-api-nginx
API_PORT="8880"
API_LOGIN="admin@host.local"
API_PASS=Aa12345aA!

echo Checking API
until [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://$API_NAME:$API_PORT/api/version)" = "200" ]]; do echo 'API is not accessible, one more time'; sleep 1; done ;
echo API Accessible
cat << EOF > /var/www/html/preseed.env
# PRESEED USER
PRESEED_ADMIN_NAME=admin
PRESEED_ADMIN_LOGIN=admin
PRESEED_ADMIN_EMAIL=admin@admin.local
PRESEED_ADMIN_PASSW=Aa12345aA!

# PRESEED OZSERVER
PRESEED_OZSERVER_NAME=$API_NAME
PRESEED_OZSERVER_URL=http://$API_NAME:$API_PORT
PRESEED_OZSERVER_LOGIN=$API_LOGIN
PRESEED_OZSERVER_PASSW=$API_PASS
EOF
echo Preseed created
curl -s -k -X POST http://$API_NAME:$API_PORT/api/authorize/auth -d "{ \"credentials\": { \"email\": \"$API_LOGIN\", \"password\": \"$API_PASS\" }}" \
| awk '{gsub(/"|",|^/, "",  $8); print "PRESEED_OZSERVER_TOKEN=" $8;}' >> /var/www/html/preseed.env
echo Done
chown www-data:www-data /var/www/html/preseed.env
entry