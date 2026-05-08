#!/usr/bin/env node
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {normalizeForwardedArgs, relayChildExit, spawnPythonScript} from '../../../lib/skill_runtime.mjs';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const entryPath = path.join(scriptDir, 'quick_validate.py');
const forwardedArgs = normalizeForwardedArgs(process.argv.slice(2));

const child = spawnPythonScript(entryPath, forwardedArgs, {
  env: process.env,
  stdio: 'inherit'
});

relayChildExit(child);
