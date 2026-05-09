#!/usr/bin/env node
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {runWeappSmoke} from '../../../lib/weapp_smoke.mjs';
import {normalizeForwardedArgs, resolveRepoRoot} from '../../../lib/skill_runtime.mjs';

const scriptPath = '.codex/skills/infoq-react-runtime-verification/scripts/run_weapp_smoke.mjs';
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);

runWeappSmoke(
  {
    label: 'weapp-smoke',
    repoRoot,
    scriptPath,
    stateSlug: 'infoq-react-runtime-verification',
    workspaceDirName: 'infoq-scaffold-frontend-weapp-react'
  },
  normalizeForwardedArgs(process.argv.slice(2))
).catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
