#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {
    fetchJson,
    normalizeForwardedArgs,
    resolveDocTmpPath,
    resolveRepoRoot,
    waitFor
} from '../../../lib/skill_runtime.mjs';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);
const backendDir = path.join(repoRoot, 'infoq-scaffold-backend');
const jarPath = path.join(backendDir, 'infoq-admin', 'target', 'infoq-admin.jar');
const loginCheckPath = path.join(scriptDir, 'login_check.mjs');
const args = normalizeForwardedArgs(process.argv.slice(2));

const config = {
  baseUrl: 'http://127.0.0.1:8080',
  tempPort: '18081',
  profile: 'local',
  waitSeconds: 90,
  clientId: 'e5cd7e4891bf95d1d19206ce24a7b32e',
  username: '',
  password: '',
  loginCandidates: 'admin:admin123,dept:666666,owner:666666,admin:123456',
  rsaPublicKey: 'MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAKoR8mX0rGKLqzcWmOzbfj64K8ZIgOdHnzkXSOVOZbFu/TJhZ7rFAN+eaGkl3C4buccQd/EjEsj9ir7ijT7h96MCAwEAAQ=='
};

let autoTemp = true;
let buildBackend = false;
let keepServer = false;
let printToken = false;
let targetBaseUrl = config.baseUrl;
let tempPid = '';
let tempLog = '';

function usage() {
  console.log(`Usage: node .codex/skills/infoq-login-success-check/scripts/verify_login.mjs [options]

Options:
  --base-url <url>          Base URL of running backend (default: http://127.0.0.1:8080).
  --temp-port <port>        Temp backend port when auto-starting (default: 18081).
  --profile <name>          Spring profile for temp backend (default: local).
  --build                   Build backend jar before temp startup.
  --no-auto-temp            Disable auto temp backend when captcha is enabled.
  --keep-server             Keep temp backend alive after checks.
  --username <name>         Preferred login username.
  --password <pwd>          Preferred login password.
  --login-candidates <csv>  Fallback list, e.g. "admin:admin123,dept:666666".
  --print-token             Print TOKEN=<jwt> when login succeeds.
  -h, --help                Show help.`);
}

function readValue(argv, index, flag) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`Missing value for ${flag}.`);
  }
  return value;
}

for (let index = 0; index < args.length; index += 1) {
  const arg = args[index];
  switch (arg) {
    case '--base-url':
      config.baseUrl = readValue(args, index, arg);
      index += 1;
      break;
    case '--temp-port':
      config.tempPort = readValue(args, index, arg);
      index += 1;
      break;
    case '--profile':
      config.profile = readValue(args, index, arg);
      index += 1;
      break;
    case '--build':
      buildBackend = true;
      break;
    case '--no-auto-temp':
      autoTemp = false;
      break;
    case '--keep-server':
      keepServer = true;
      break;
    case '--username':
      config.username = readValue(args, index, arg);
      index += 1;
      break;
    case '--password':
      config.password = readValue(args, index, arg);
      index += 1;
      break;
    case '--login-candidates':
      config.loginCandidates = readValue(args, index, arg);
      index += 1;
      break;
    case '--print-token':
      printToken = true;
      break;
    case '-h':
    case '--help':
      usage();
      process.exit(0);
      break;
    default:
      console.error(`Unknown option: ${arg}`);
      usage();
      process.exit(1);
  }
}

async function canReachAuthCode(baseUrl) {
  try {
    const {response} = await fetchJson(`${baseUrl}/auth/code`);
    return response.ok;
  } catch {
    return false;
  }
}

async function loadAuthCode(baseUrl) {
  try {
    return await fetchJson(`${baseUrl}/auth/code`);
  } catch {
    return null;
  }
}

function cleanup() {
  if (tempPid && !keepServer) {
    try {
      process.kill(Number(tempPid));
    } catch {
      // Ignore cleanup failures for dead processes.
    }
  }
}

process.on('exit', cleanup);
process.on('SIGINT', () => {
  cleanup();
  process.exit(130);
});
process.on('SIGTERM', () => {
  cleanup();
  process.exit(143);
});

function runCommand(command, commandArgs, options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, commandArgs, {
      cwd: options.cwd,
      env: options.env ?? process.env,
      stdio: options.stdio ?? 'inherit',
      detached: options.detached ?? false
    });

    child.on('error', reject);
    child.on('exit', (code, signal) => {
      if (signal) {
        reject(new Error(`${command} exited via signal ${signal}`));
        return;
      }
      if (code !== 0) {
        reject(new Error(`${command} exited with code ${code}`));
        return;
      }
      resolve(child);
    });

    if (options.detached) {
      child.unref();
    }
  });
}

async function startTempBackend() {
  const tempBase = `http://127.0.0.1:${config.tempPort}`;

  if (buildBackend || !fs.existsSync(jarPath)) {
    console.log('[login-check] building backend jar...');
    await runCommand('mvn', ['-pl', 'infoq-admin', '-am', '-DskipTests', 'package'], {
      cwd: backendDir
    });
  }

  if (!fs.existsSync(jarPath)) {
    throw new Error(`[login-check] backend jar not found: ${jarPath}`);
  }

  if (await canReachAuthCode(tempBase)) {
    console.log(`[login-check] reuse temp backend on ${tempBase}`);
    targetBaseUrl = tempBase;
    return;
  }

  tempLog = resolveDocTmpPath(repoRoot, `infoq-login-check-${config.tempPort}-${Date.now()}.log`);
  const logFd = fs.openSync(tempLog, 'a');

  console.log(`[login-check] starting temp backend on ${tempBase} with captcha disabled`);
  const child = spawn(
    'java',
    [
      '-jar',
      jarPath,
      `--spring.profiles.active=${config.profile}`,
      `--server.port=${config.tempPort}`,
      '--captcha.enable=false'
    ],
    {
      cwd: backendDir,
      env: process.env,
      detached: true,
      stdio: ['ignore', logFd, logFd]
    }
  );
  child.unref();
  fs.closeSync(logFd);
  tempPid = String(child.pid);

  const ready = await waitFor(() => canReachAuthCode(tempBase), {
    attempts: config.waitSeconds,
    intervalMs: 1000
  });

  if (!ready) {
    let logTail = '';
    if (fs.existsSync(tempLog)) {
      const content = fs.readFileSync(tempLog, 'utf8');
      logTail = content.split(/\r?\n/).slice(-200).join('\n');
    }
    throw new Error(`[login-check] temp backend failed to become ready. log=${tempLog}\n${logTail}`);
  }

  targetBaseUrl = tempBase;
  console.log(`[login-check] temp backend ready: ${targetBaseUrl}`);
}

async function determineTargetBaseUrl() {
  const authCode = await loadAuthCode(config.baseUrl);
  if (authCode?.response?.ok) {
    const captchaEnabled = authCode.body?.data?.captchaEnabled === true;
    if (captchaEnabled) {
      if (!autoTemp) {
        throw new Error(`[login-check] captcha enabled on ${config.baseUrl}; use auto temp backend or disable captcha`);
      }
      console.log(`[login-check] captcha enabled on ${config.baseUrl}; switching to temp backend`);
      await startTempBackend();
      return;
    }

    targetBaseUrl = config.baseUrl;
    console.log(`[login-check] using existing backend: ${targetBaseUrl}`);
    return;
  }

  if (!autoTemp) {
    throw new Error(`[login-check] ${config.baseUrl} unreachable and auto temp backend disabled`);
  }

  console.log(`[login-check] ${config.baseUrl} unreachable; starting temp backend`);
  await startTempBackend();
}

async function runLoginCheck() {
  const env = {
    ...process.env,
    BASE_URL: targetBaseUrl,
    CLIENT_ID: config.clientId,
    USERNAME: config.username,
    PASSWORD: config.password,
    LOGIN_CANDIDATES: config.loginCandidates,
    RSA_PUBLIC_KEY: config.rsaPublicKey,
    PRINT_TOKEN: printToken ? '1' : ''
  };

  await runCommand(process.execPath, [loginCheckPath], {
    cwd: scriptDir,
    env
  });
}

async function main() {
  await determineTargetBaseUrl();
  await runLoginCheck();

  if (keepServer && tempPid) {
    console.log(`[login-check] keep-server enabled: pid=${tempPid}, log=${tempLog}`);
  }
}

main().catch((error) => {
  console.error(error.message || error);
  process.exit(1);
});
