type jq >/dev/null 2>&1 || { echo >&2 "jq is not installed.  Aborting."; exit 1; }
type oc >/dev/null 2>&1 || { echo >&2 "oc is not installed.  Aborting."; exit 1; }
type kubectl >/dev/null 2>&1 || { echo >&2 "kubectl is not installed.  Aborting."; exit 1; }
