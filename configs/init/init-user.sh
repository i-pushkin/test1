#!/bin/bash

#VARS:
PG_HOST=oz-api-pg
PG_PORT="5432"
API_NAME=oz-api
API_PORT="8000"
API_LOGIN="admin@host.local"
API_PASS=Aa12345aA!

sleep 5
for ((i=1;i<10;i++)) 
do
  #Chech PG ready
  echo -e '\x1dclose\x0d' | timeout 5 telnet $PG_HOST $PG_PORT
  if [[ $? == 0 ]]; then
    echo 'Test if login exist';
    
    RESP=$(curl -s -k -X POST $API_NAME:$API_PORT/api/authorize/auth -d "{ \"credentials\": { \"email\": \"$API_LOGIN\", \"password\": \"$API_PASS\" }}");
    if [[ $RESP == "" ]]; then 
      echo "Error connecting API. Failing.";
      break;
    fi;
    ERR=$(echo "$RESP" | awk '{gsub(/"|",|^/, "",  $8); print $1;}');
    if [[ $ERR == "{\"error_code\":" ]]; then 
      echo 'User does not exist. Creating'; 
      cd /opt/gateway/ || exit 1;
      # shellcheck source=/dev/null
      source env/bin/activate;
      python manage.py oz_create_admin --email $API_LOGIN --password $API_PASS;
      break;
    else
      TOKEN=$(echo $RESP | grep -Po -e "\"access_token\": \"\K[0-9a-z]*");
      if [[ $TOKEN == "" ]]; then
        echo "No access token in API answer. Failing."; 
        exit 1;
      else
        echo 'User valid. Pass';
        exit 0;
      fi;
    fi;

  else

    if [[ $i -ge 8 ]]; then
      exit 1;
    fi
  fi
sleep 5;
done