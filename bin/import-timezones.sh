#!/usr/bin/env bash

REALPATH="$(readlink "$0" || echo "")"
BASEDIR="$(pwd)/$(dirname "$(dirname "$(dirname "$0")/${REALPATH}")")/"
timezones_geojson_dest_path="${TIMEZONES_GEOJSON-${BASEDIR}/data/timezones.geojson.zip}"
export MONGO_URL="${MONGO_URL-mongodb://localhost:27017/test}"

if [[ ! -f "${timezones_geojson_dest_path}" ]] ; then
  node "${BASEDIR}/bin/fetch_timezones_geojson.js" --timezones-geojson-dest-path "${timezones_geojson_dest_path}"
else
  echo "Timezones geojson already downloaded"
fi

cat ${timezones_geojson_dest_path} \
  | funzip \
  | node_modules/node-jq/bin/jq '.features | .[] | . * { properties: { timezone: .properties.tzid } }' \
  | mongoimport --uri "${MONGO_URL}" -c "${COLLECTION_NAME-timezones}"