#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawn} from 'node:child_process';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const binName = process.platform === 'win32' ? 'chrome-devtools-mcp.cmd' : 'chrome-devtools-mcp';
const binPath = path.join(scriptDir, 'node_modules', '.bin', binName);

if (!fs.existsSync(binPath)) {
  console.error(
    "chrome-devtools-mcp is not installed. Run 'pnpm --dir .agents/skills/infoq-browser-automation/scripts install' first."
  );
  process.exit(1);
}

const child = spawn(binPath, process.argv.slice(2), {
  cwd: scriptDir,
  env: process.env,
  stdio: 'inherit',
  shell: process.platform === 'win32'
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
