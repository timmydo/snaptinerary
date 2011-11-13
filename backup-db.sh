#!/bin/bash
pg_dump snaptinerary > db-`date +%s`.sql
