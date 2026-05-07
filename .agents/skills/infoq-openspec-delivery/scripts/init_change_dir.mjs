#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {normalizeForwardedArgs, resolveRepoRoot} from '../../../lib/skill_runtime.mjs';

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = resolveRepoRoot(scriptDir);
const args = normalizeForwardedArgs(process.argv.slice(2));

if (args.length !== 1) {
  console.error('Usage: node .agents/skills/infoq-openspec-delivery/scripts/init_change_dir.mjs <change-id>');
  process.exit(1);
}

const [changeId] = args;
const changeDir = path.join(repoRoot, 'openspec', 'changes', changeId);
const specDir = path.join(changeDir, 'specs');

fs.mkdirSync(specDir, {recursive: true});

function createIfMissing(targetPath, content) {
  if (fs.existsSync(targetPath)) {
    return;
  }
  fs.writeFileSync(targetPath, content, 'utf8');
}

createIfMissing(path.join(changeDir, 'proposal.md'), `# Proposal: ${changeId}

## Why

## What Changes

### Scope

### Non-Goals

## Acceptance Contract

- Functional scope:
- Non-goals:
- Exception handling and blockers:
- Required verification evidence:
- Rollback trigger or rollback conditions:

## Risks And Open Questions
`);

createIfMissing(path.join(changeDir, 'tasks.md'), `# Tasks: ${changeId}

## Backend

- [ ] Assess backend impact

## React

- [ ] Assess React impact

## Vue

- [ ] Assess Vue impact

## Verification

- [ ] Define main-flow verification
- [ ] Define targeted tests
- [ ] Define lint/build checks
- [ ] Record residual risks or blockers
`);

console.log(`Initialized ${path.relative(repoRoot, changeDir)}`);
