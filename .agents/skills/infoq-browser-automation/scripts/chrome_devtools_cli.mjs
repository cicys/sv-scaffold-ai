#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawn} from 'node:child_process';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, '..', '..', '..', '..');
const entryPath = path.join(scriptDir, 'node_modules', 'chrome-devtools-mcp', 'build', 'src', 'bin', 'chrome-devtools-mcp.js');
const localStoragePath = path.join(repoRoot, '.codex', 'tmp', 'chrome-devtools-mcp-localstorage');
const forwardedArgs = process.argv[2] === '--' ? process.argv.slice(3) : process.argv.slice(2);

if (!fs.existsSync(entryPath)) {
  console.error(
    "chrome-devtools-mcp is not installed. Run 'pnpm --dir .agents/skills/infoq-browser-automation/scripts install' first."
  );
  process.exit(1);
}

fs.mkdirSync(path.dirname(localStoragePath), { recursive: true });

const child = spawn(process.execPath, [`--localstorage-file=${localStoragePath}`, entryPath, ...forwardedArgs], {
  cwd: scriptDir,
  env: process.env,
  stdio: 'inherit'
});

child.on('error', (error) => {
  console.error(`Failed to launch chrome-devtools-mcp: ${error.message}`);
  process.exit(1);
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }
  process.exit(code ?? 1);
});
