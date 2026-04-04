const { spawnSync } = require('node:child_process');
const path = require('node:path');

const scripts = [
  'ingest-livingcost-city-data.js',
  'ingest-numbeo-city-snapshots.js',
];

for (const script of scripts) {
  const scriptPath = path.resolve(__dirname, script);
  const result = spawnSync(process.execPath, [scriptPath], {
    stdio: 'inherit',
  });
  if (result.status !== 0) {
    process.exitCode = result.status ?? 1;
    break;
  }
}
