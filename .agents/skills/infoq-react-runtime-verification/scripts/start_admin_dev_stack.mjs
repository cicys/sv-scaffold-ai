#!/usr/bin/env node
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {runAdminDevStack} from '../../../lib/admin_dev_stack.mjs';
import {normalizeForwardedArgs, resolveDocTmpPath, resolveRepoRoot} from '../../../lib/skill_runtime.mjs';

const scriptPath = '.agents/skills/infoq-react-runtime-verification/scripts/start_admin_dev_stack.mjs';
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);

const config = {
  label: 'react-runtime',
  repoRoot,
  scriptPath,
  stateSlug: 'infoq-react-runtime-verification',
  stateFile: resolveDocTmpPath(repoRoot, 'infoq-react-runtime-verification', 'state.json'),
  frontendDirName: 'infoq-scaffold-frontend-react',
  frontendDisplayName: 'React admin',
  frontendLogPrefix: 'frontend-react',
  frontendPortFlag: '--react-port',
  frontendPortEnv: 'REACT_PORT',
  defaultBackendPort: 8080,
  defaultFrontendPort: 5174
};

runAdminDevStack(config, normalizeForwardedArgs(process.argv.slice(2))).catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
