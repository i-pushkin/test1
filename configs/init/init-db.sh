#!/bin/bash

#VARS:
PG_HOST=oz-api-pg
PG_PORT="5432"
PG_USER=gateway_user
PG_DBNAME=gateway
PG_PASS="Aa12345aA!"

sleep 5;
for ((i=1;i<10;i++)) 
do
  #Chech PG ready
  echo -e '\x1dclose\x0d' | timeout 5 telnet $PG_HOST $PG_PORT
  if [[ $? == 0 ]]; then
    #Check DB exists
    CHECKDB=$(PGPASSWORD=$PG_PASS psql -h$PG_HOST -p$PG_PORT -U$PG_USER -d$PG_DBNAME -lqt | cut -d \| -f 1 | grep -c -w $PG_DBNAME)
    if [[ $CHECKDB == 0 ]]; then
      echo 'DB is not exist. Failing';
      break;
    else
      echo 'DB exists.';
    fi;
    #Check DB empty
    PGTEST1=$(PGPASSWORD=$PG_PASS psql -h$PG_HOST -p$PG_PORT -U$PG_USER -d$PG_DBNAME -c "SELECT 'public.lamb_execution_time_metric'::regclass;" | grep -c row);
    PGTEST2=$(PGPASSWORD=$PG_PASS psql -h$PG_HOST -p$PG_PORT -U$PG_USER -d$PG_DBNAME -c "SELECT 'public.gw_folder'::regclass;" | grep -c row);
    if [[ ($PGTEST1 != 1) || ($PGTEST2 != 1) ]]; then
      echo 'DB is empty. Creating tables.'
      cd /opt/gateway/ || exit 1;
      # shellcheck source=/dev/null
      source env/bin/activate;
      python manage.py alchemy_create api lamb.execution_time;
    else
      echo 'DB checked. Creating indexes.';
      #Here i must create indexes
      exit 0;
    fi;

  else
    sleep 5;
    if [[ $i -ge 8 ]]; then
      exit 1;
    fi
  fi

done