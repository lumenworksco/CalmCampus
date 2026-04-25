import puppeteer from 'puppeteer';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const W = 294;
const H = 637;

const screens = [
  { url: 'http://localhost:3399/screen_home.html',     out: 'home.png' },
  { url: 'http://localhost:3399/screen_insights.html', out: 'insights.png' },
  { url: 'http://localhost:3399/screen_profile.html',  out: 'profile.png' },
];

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

for (const { url, out } of screens) {
  const page = await browser.newPage();
  await page.setViewport({ width: W, height: H, deviceScaleFactor: 3 });
  await page.goto(url, { waitUntil: 'networkidle0' });

  // Clip exactly to the .screen element (294×637 at CSS pixels)
  const element = await page.$('.screen');
  await element.screenshot({
    path: path.join(__dirname, out),
    type: 'png',
  });

  await page.close();
  console.log(`✓  ${out}`);
}

await browser.close();
