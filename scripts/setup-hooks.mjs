import { access, mkdir, copyFile, cp } from 'node:fs/promises';
import { constants } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const projectRoot = join(__dirname, '..');
const sourceHooksDir = join(projectRoot, '.cursor/hooks');
const sourceHooksConfig = join(projectRoot, '.cursor/hooks.json');

const homeDir = process.env.HOME;
if (!homeDir) {
  console.error('Unable to determine home directory (missing HOME env var).');
  process.exit(1);
}

const targetCursorDir = join(homeDir, '.cursor');
const targetHooksDir = join(targetCursorDir, 'hooks');
const targetHooksConfig = join(targetCursorDir, 'hooks.json');

async function fileExists(path) {
  try {
    await access(path, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

async function main() {
  try {
    if (await fileExists(targetHooksConfig)) {
      console.log(`Existing hooks configuration detected at ${targetHooksConfig}.`);
      console.log('Opening existing configuration in Cursor instead of copying.');
      spawn('cursor', [targetCursorDir], { stdio: 'inherit' });
      return;
    }

    await mkdir(targetHooksDir, { recursive: true });
    await copyFile(sourceHooksConfig, targetHooksConfig);
    await cp(sourceHooksDir, targetHooksDir, { recursive: true });
    console.log(`Copied hooks configuration to ${targetCursorDir}`);
    console.log('Opening new configuration in Cursor.');
    spawn('cursor', [targetCursorDir], { stdio: 'inherit' });
  } catch (error) {
    console.error('Failed to copy Cursor hooks:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

main();

