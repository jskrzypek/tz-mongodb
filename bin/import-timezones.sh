#!/usr/bin/env bash

BASEDIR="$(dirname $(dirname "$(pwd)/$(readlink "$0" || echo "$0")"))/"
export TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH="${TIMEZONES_GEOJSON-${BASEDIR}/data/timezones.geojson.zip}"
export MONGO_URL="${MONGO_URL-mongodb://localhost:27017/test}"

if [[ ! -f "${TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH}" ]] ; then
  node "${BASEDIR}/bin/fetch_timezones_geojson.js"
else
  echo "Timezones geojson already downloaded"
fi

echo "${MONGO_URL}"

cat ${TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH} \
  | funzip \
  | node_modules/node-jq/bin/jq '.features | .[] | . * { properties: { timezone: .properties.tzid } }' \
  | mongoimport --uri "${MONGO_URL}" -c "${COLLECTION_NAME-timezones}"