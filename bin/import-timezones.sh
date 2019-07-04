#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
export TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH="${BASEDIR}/../data/timezones.geojson.zip"

if [[ ! -f "${TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH}" ]] ; then
  node ./bin/fetch_timezones_geojson.js
else
  echo "Timezones geojson already downloaded"
fi

cat ${TZ_MONGODB_TIMEZONES_GEOJSON_DEST_PATH} \
  | funzip \
  | node_modules/node-jq/bin/jq '.features | .[] | . * { properties: { timezone: .properties.tzid } }' \
  | mongoimport --uri ${MONGO_URL-mongodb://localhost:27017/test} -c ${COLLECTION_NAME-timezones}