#!/usr/bin/env bash

RUNNER=kubectl

# copy the catalog-db secret into the current namespace
$RUNNER -n catalog-ci get secret catalog-db -o json --export 2>/dev/null | \
    jq 'del(.metadata.selfLink,.metadata.annotations)' | \
    $RUNNER create -f - 
