import fs from 'node:fs';
import path from 'node:path';
import {
    ensureDir,
    fetchText,
    isProcessAlive,
    resolveDocTmpPath,
    resolvePackageManager,
    runCommandChecked,
    spawnDetachedProcess,
    tailFile,
    terminateProcessTree,
    waitFor
} from './skill_runtime.mjs';

function readState(stateFile) {
  if (!fs.existsSync(stateFile)) {
    return null;
  }
  return JSON.parse(fs.readFileSync(stateFile, 'utf8'));
}

function writeState(stateFile, state) {
  ensureDir(path.dirname(stateFile));
  fs.writeFileSync(stateFile, `${JSON.stringify(state, null, 2)}\n`, 'utf8');
}

async function canFetch(url) {
  try {
    const {response} = await fetchText(url, {redirect: 'manual'});
    return response.status >= 200 && response.status < 500;
  } catch {
    return false;
  }
}

async function waitForUrl(url, waitSeconds) {
  return waitFor(() => canFetch(url), {
    attempts: waitSeconds,
    intervalMs: 1000
  });
}

async function stopRecordedProcess(label, pid) {
  if (!pid) {
    console.log(`[${label}] no pid recorded`);
    return;
  }
  if (!isProcessAlive(pid)) {
    console.log(`[${label}] already stopped (pid=${pid})`);
    return;
  }
  await terminateProcessTree(pid, {graceMs: 1000});
  console.log(`[${label}] stopped (pid=${pid})`);
}

export async function stopAdminDevStackState(config, options = {}) {
  const state = readState(config.stateFile);
  if (!state) {
    console.log(`[${config.label}] no state file found: ${config.stateFile}`);
    return;
  }

  await stopRecordedProcess(`${config.label} backend`, state.startedBackendPid || '');
  await stopRecordedProcess(`${config.label} ${config.frontendDisplayName}`, state.startedFrontendPid || '');

  if (options.removeState !== false) {
    fs.rmSync(config.stateFile, {force: true});
    console.log(`[${config.label}] removed state file: ${config.stateFile}`);
  }
}

function usage(config) {
  console.log(`Usage: node ${config.scriptPath} [options]

Options:
  --build-backend        Build backend jar before startup.
  --force-restart        Stop recorded processes before startup.
  --backend-only         Start backend only.
  --frontend-only        Start frontend only.
  --backend-port <port>  Backend HTTP port. Default: ${config.defaultBackendPort}.
  ${config.frontendPortFlag} <port>   ${config.frontendDisplayName} dev port. Default: ${config.defaultFrontendPort}.
  --frontend-host <host> Frontend host. Default: 127.0.0.1.
  --profile <name>       Spring profile. Default: dev.
  -h, --help             Show help.`);
}

function readValue(argv, index, flag) {
  const value = argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`Missing value for ${flag}.`);
  }
  return value;
}

function parseArgs(argv, config) {
  const options = {
    buildBackend: false,
    forceRestart: false,
    backendOnly: false,
    frontendOnly: false,
    backendPort: String(process.env.BACKEND_PORT || config.defaultBackendPort),
    frontendHost: String(process.env.FRONTEND_HOST || '127.0.0.1'),
    frontendPort: String(process.env[config.frontendPortEnv] || config.defaultFrontendPort),
    profile: String(process.env.PROFILE || 'dev'),
    waitSeconds: Number(process.env.WAIT_SECONDS || 90)
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    switch (arg) {
      case '--build-backend':
        options.buildBackend = true;
        break;
      case '--force-restart':
        options.forceRestart = true;
        break;
      case '--backend-only':
        options.backendOnly = true;
        break;
      case '--frontend-only':
        options.frontendOnly = true;
        break;
      case '--backend-port':
        options.backendPort = readValue(argv, index, arg);
        index += 1;
        break;
      case '--frontend-host':
        options.frontendHost = readValue(argv, index, arg);
        index += 1;
        break;
      case '--profile':
        options.profile = readValue(argv, index, arg);
        index += 1;
        break;
      case '-h':
      case '--help':
        usage(config);
        process.exit(0);
        break;
      default:
        if (arg === config.frontendPortFlag) {
          options.frontendPort = readValue(argv, index, arg);
          index += 1;
          break;
        }
        throw new Error(`Unknown option: ${arg}`);
    }
  }

  if (options.backendOnly && options.frontendOnly) {
    throw new Error('--backend-only and --frontend-only cannot be used together.');
  }

  return options;
}

export async function runAdminDevStack(config, argv) {
  const options = parseArgs(argv, config);
  const backendDir = path.join(config.repoRoot, 'infoq-scaffold-backend');
  const frontendDir = path.join(config.repoRoot, config.frontendDirName);
  const backendJar = path.join(backendDir, 'infoq-admin', 'target', 'infoq-admin.jar');
  const logDir = resolveDocTmpPath(config.repoRoot, config.stateSlug);
  const backendLog = path.join(logDir, `backend-${options.backendPort}.log`);
  const frontendLog = path.join(logDir, `${config.frontendLogPrefix}-${options.frontendPort}.log`);

  if (!fs.existsSync(backendDir) || !fs.existsSync(frontendDir)) {
    throw new Error(`Repository layout not found under ${config.repoRoot}`);
  }

  if (options.forceRestart) {
    await stopAdminDevStackState(config, {removeState: false});
  }

  let startedBackendPid = '';
  let startedFrontendPid = '';

  if (!options.frontendOnly) {
    const backendUrl = `http://127.0.0.1:${options.backendPort}/auth/code`;
    if (options.buildBackend || !fs.existsSync(backendJar)) {
      console.log(`[${config.label}] building backend jar...`);
      await runCommandChecked('mvn', ['-pl', 'infoq-admin', '-am', '-DskipTests', 'package'], {
        cwd: backendDir
      });
    }

    if (!fs.existsSync(backendJar)) {
      throw new Error(`[${config.label}] backend jar not found: ${backendJar}`);
    }

    if (await canFetch(backendUrl)) {
      if (options.forceRestart) {
        throw new Error(`[${config.label}] backend is still running on :${options.backendPort} after stopping recorded processes.`);
      }
      console.log(`[${config.label}] backend already running on :${options.backendPort}`);
    } else {
      console.log(`[${config.label}] starting backend on :${options.backendPort}`);
      const child = spawnDetachedProcess(
        'java',
        [
          '-jar',
          backendJar,
          `--spring.profiles.active=${options.profile}`,
          `--server.port=${options.backendPort}`
        ],
        {
          cwd: backendDir,
          env: process.env,
          logFile: backendLog
        }
      );
      startedBackendPid = String(child.pid || '');

      const ready = await waitForUrl(backendUrl, options.waitSeconds);
      if (!ready) {
        throw new Error(`[${config.label}] backend failed to become ready. log=${backendLog}\n${tailFile(backendLog, 120)}`);
      }
      console.log(`[${config.label}] backend ready: ${backendUrl} (pid=${startedBackendPid})`);
    }
  }

  if (!options.backendOnly) {
    const frontendUrl = `http://${options.frontendHost}:${options.frontendPort}/`;
    if (await canFetch(frontendUrl)) {
      if (options.forceRestart) {
        throw new Error(`[${config.label}] ${config.frontendDisplayName} is still running on :${options.frontendPort} after stopping recorded processes.`);
      }
      console.log(`[${config.label}] ${config.frontendDisplayName} already running on :${options.frontendPort}`);
    } else {
      const pkg = resolvePackageManager();
      console.log(`[${config.label}] starting ${config.frontendDisplayName} on ${options.frontendHost}:${options.frontendPort}`);
      const child = spawnDetachedProcess(
        pkg.command,
        ['run', 'dev', '--', '--host', options.frontendHost, '--port', String(options.frontendPort), '--open', 'false', '--strictPort'],
        {
          cwd: frontendDir,
          env: process.env,
          logFile: frontendLog
        }
      );
      startedFrontendPid = String(child.pid || '');

      const ready = await waitForUrl(frontendUrl, options.waitSeconds);
      if (!ready) {
        throw new Error(`[${config.label}] ${config.frontendDisplayName} failed to become ready. log=${frontendLog}\n${tailFile(frontendLog, 120)}`);
      }
      console.log(`[${config.label}] ${config.frontendDisplayName} ready: ${frontendUrl} (pid=${startedFrontendPid})`);
    }
  }

  writeState(config.stateFile, {
    startedAt: new Date().toISOString(),
    startedBackendPid,
    startedFrontendPid,
    backendPort: options.backendPort,
    frontendHost: options.frontendHost,
    frontendPort: options.frontendPort,
    backendLog,
    frontendLog
  });

  console.log(`[${config.label}] state file: ${config.stateFile}`);
  console.log(`[${config.label}] backend log: ${backendLog}`);
  if (!options.backendOnly) {
    console.log(`[${config.label}] frontend log: ${frontendLog}`);
  }
}
