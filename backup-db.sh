#!/bin/bash
FILE=db-`date +%s`.sql
pg_dump snaptinerary > $FILE
scp $FILE timmy@10.120.162.22:/var/www/snaptinerary/backup/
