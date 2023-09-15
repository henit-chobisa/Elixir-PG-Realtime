#!/bin/bash

psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'postgres';" 
psql --command "CREATE DATABASE postgres OWNER root;"
psql --command "ALTER SYSTEM SET wal_level = 'logical';"

pg_stop;
pg_start;