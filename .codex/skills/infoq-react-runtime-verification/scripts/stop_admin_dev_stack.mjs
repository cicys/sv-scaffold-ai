#!/usr/bin/env node
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {stopAdminDevStackState} from '../../../lib/admin_dev_stack.mjs';
import {resolveDocTmpPath, resolveRepoRoot} from '../../../lib/skill_runtime.mjs';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);

const config = {
  label: 'react-runtime',
  frontendDisplayName: 'React admin',
  stateFile: resolveDocTmpPath(repoRoot, 'infoq-react-runtime-verification', 'state.json')
};

stopAdminDevStackState(config).catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
