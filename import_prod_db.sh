#!/usr/bin/env bash

RUNNER=kubectl # change to oc if you want to use that
DB_POD=$($RUNNER get po | awk '/postgresql/ {print $1}')

$RUNNER exec -t $DB_POD -- \
    bash -c "/opt/rh/rh-postgresql10/root/usr/bin/pg_dump catalog_production --clean" | \
    sed 's/catalog_production/catalog_development/g' | \
    bin/rails dbconsole -p
