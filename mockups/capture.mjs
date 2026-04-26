// Capture .screen element from each mockup and save to website/assets/screens/
import { chromium } from 'playwright';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));

const screens = [
  { file: 'screen_home.html',     out: 'home.png' },
  { file: 'screen_insights.html', out: 'insights.png' },
  { file: 'screen_profile.html',  out: 'profile.png' },
];

const browser = await chromium.launch();
const page    = await browser.newPage();
await page.setViewportSize({ width: 800, height: 900 });

for (const { file, out } of screens) {
  const url  = `file://${resolve(__dir, file)}`;
  const dest = resolve(__dir, `../website/assets/screens/${out}`);

  await page.goto(url, { waitUntil: 'networkidle' });
  await page.waitForTimeout(300); // let fonts + images settle

  const el = page.locator('.screen');
  await el.screenshot({ path: dest, scale: 'device' });
  console.log(`✅ ${out}`);
}

await browser.close();
