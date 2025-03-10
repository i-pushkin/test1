#!/bin/bash

#VARS:
PG_HOST=oz-o2n-pg
PG_PORT="5432"
PG_USER=o2n_user
PG_DBNAME=o2n
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
    PGTEST1=$(PGPASSWORD=$PG_PASS psql -h$PG_HOST -p$PG_PORT -U$PG_USER -d$PG_DBNAME -c "SELECT 'public.o2n_signature'::regclass;" | grep -c row);
    if [[ ($PGTEST1 != 1) ]]; then
      echo 'DB is empty. Creating tables.'
      cd /opt/oz/o2n || exit 1;
      python -m scripts.init_db_tables;
    else
      echo 'DB checked.';
      exit 0;
    fi;

  else
    sleep 5;
    if [[ $i -ge 8 ]]; then
      exit 1;
    fi
  fi

done