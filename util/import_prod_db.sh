#!/usr/bin/env bash
set -x

RUNNER=kubectl # change to oc if you want to use that
SQL_FILE=/tmp/pg_dump.sql

oc project catalog-ci
DB_POD=$($RUNNER get po | awk '/postgres/ {print $1}')

$RUNNER exec -t $DB_POD -- \
    bash -c "/opt/rh/rh-postgresql10/root/usr/bin/pg_dump catalog_production --clean" | \
    sed 's/catalog_production/catalog_development/g' > $SQL_FILE

oc project $PROJECT
DB_POD=$($RUNNER get po | awk '/postgresql/ {print $1}')

echo $DB_POD

cat $SQL_FILE | $RUNNER exec -it $DB_POD bash -- \
    -c "psql catalog_development -f -"

rm $SQL_FILE
