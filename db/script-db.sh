#!/bin/bash

echo date > /tmp/postgres-script-file.log
sleep 10

while [ ! -f "/tmp/create.sql" ]
do
  echo date >> /tmp/postgres-script-file.log
  sleep .1
done

psql -U postgres -d WORKSHOP -f /tmp/create.sql -a -b -e
