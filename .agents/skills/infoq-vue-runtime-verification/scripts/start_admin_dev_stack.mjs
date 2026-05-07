#!/usr/bin/env node
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {runAdminDevStack} from '../../../lib/admin_dev_stack.mjs';
import {normalizeForwardedArgs, resolveDocTmpPath, resolveRepoRoot} from '../../../lib/skill_runtime.mjs';

const scriptPath = '.agents/skills/infoq-vue-runtime-verification/scripts/start_admin_dev_stack.mjs';
const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);

const config = {
  label: 'vue-runtime',
  repoRoot,
  scriptPath,
  stateSlug: 'infoq-vue-runtime-verification',
  stateFile: resolveDocTmpPath(repoRoot, 'infoq-vue-runtime-verification', 'state.json'),
  frontendDirName: 'infoq-scaffold-frontend-vue',
  frontendDisplayName: 'Vue admin',
  frontendLogPrefix: 'frontend-vue',
  frontendPortFlag: '--vue-port',
  frontendPortEnv: 'VUE_PORT',
  defaultBackendPort: 8080,
  defaultFrontendPort: 5173
};

runAdminDevStack(config, normalizeForwardedArgs(process.argv.slice(2))).catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
