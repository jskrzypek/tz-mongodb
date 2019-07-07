'use strict';

const path = require('path');
const Octokit = require('@octokit/rest');
const wget = require('wget-improved');
const fs = require('fs-extra');
const _ = require('lodash');
const argv = require('yargs')
  .env('TZ_MONGODB')
  .env('tz_mongodb')
  .env('npm_package_config')
  .option('oceans', {
    default: false,
    boolean: true,
    describe: 'Include ocean timezone boundaries in the fetched geojson.',
    alias: [
      'INCLUDE_OCEAN_TIMEZONES',
      'include_ocean_timezones',
      'include-ocean-timezones',
      'includeOceanTimezones'
    ]
  })
  .option('tag', {
    string: true,
    describe: 'Fetch the assets from a specific release (defaults to the latest release).',
    alias: [
      'TIMEZONES_RELEASE_TAG',
      'timezones_release_tag',
      'timezones-release-tag',
      'timezonesReleaseTag',
      'tag'
    ]
  })
  .option('dest', {
    string: true,
    describe: 'The destination for the combined timezones json file.',
    alias: [
      'TIMEZONES_GEOJSON_DEST_PATH',
      'timezones_geojson_dest_path',
      'timezones-geojson-dest-path',
      'timezonesGeojsonDestPath'
    ]
  })
  .option('githubToken', {
    string: true
  })
  .argv;
const owner = 'evansiroky';
const repo = 'timezone-boundary-builder';

const octokit = new Octokit({
  auth: argv.githubToken,
  log: {
    debug: () => {},
    info: () => {},
    warn: console.warn,
    error: console.error
  }
})

const ASSET_NAME = argv.oceans ? 'timezones-with-oceans.geojson.zip' : 'timezones.geojson.zip';

const ASSET_DEST = path.join(__dirname, '..', argv.dest);

async function fetchReleaseAssets(tag) {

  let assets;
  if (!tag) {
    ({ data: { assets } } = await octokit.repos.getLatestRelease({ owner, repo }));
  } else {
    ({ data: { assets } } = await octokit.repos.getReleaseByTag({ owner, repo, tag }));
  }
  return assets;
}

async function download(source, dest, {
  onProgress = console.log.bind(console, 'onProgress'),
  onStart = console.log.bind(console, 'onStart'),
  onEnd = console.log.bind(console, 'onEnd'),
  onError = console.log.bind(console, 'onError'),
  ...options
} = { gunzip: true }) {
  await fs.ensureDir(ASSET_DEST_DIR);
  await new Promise((resolve, reject) => {
    console.log(source, '->', dest);
    wget.download(source, dest, options)
      .on('progress', onProgress)
      .on('start', onStart)
      .on('error', onError)
      .on('end', onEnd)
      .on('error', reject)
      .on('end', resolve);
  });
}

async function fetchGeoJson() {
  try {
    const assets = await fetchReleaseAssets(argv.tag);
    const { browser_download_url } = _.find(assets, ['name', ASSET_NAME]);
    await download(browser_download_url, ASSET_DEST);
  } catch (err) {
    console.error(`
Error: Something failed! Try downloading the geojson assets manually from
https://github.com/evansiroky/timezone-boundary-builder/releases, then unzip
into and place the contained json file at './data/timezones.combined.json'.
`);
    throw err;
  }
}

fetchGeoJson();