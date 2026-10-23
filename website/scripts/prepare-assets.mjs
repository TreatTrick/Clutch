import { copyFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

// 复用原项目中的媒体文件，避免维护两份截图和演示。
const source = new URL('../../docs/assets/', import.meta.url);
const destination = new URL('../static/media/', import.meta.url);
await mkdir(destination, { recursive: true });
const files = [
  'icon.png', 'desktop-switching-demo.gif', 'settings.png',
  'settings-dark.png'
];
for (const file of files) {
  await copyFile(new URL(file, source), new URL(file, destination));
}
console.log(`Prepared ${files.length} MouseSpell assets in ${fileURLToPath(destination)}`);
