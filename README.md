# tz-mongodb

Parse a release from [timezone-boundary-builder](https://github.com/evansiroky/timezone-boundary-builder) through [jq](https://stedolan.github.io/jq/) and import it as a mongodb collection.

## Usage

```
npm install tz-mongodb

./node_modules/.bin/import-timezones.sh
```

Accepts these env vars:
 + `MONGO_URL` - a mongodb uri
 + `COLLECTION_NAME` - the collection to import to, defalts to `timezones`
