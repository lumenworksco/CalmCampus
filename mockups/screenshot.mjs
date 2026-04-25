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

// Icon container selectors to auto-correct
const ICON_SELECTORS = '.signal-icon,.stat-icon,.ach-icon-wrap,.ai-icon,.gear-btn,.checkin-emoji';

// Measure per-class ink-center vs container-center offset, then inject
// corrective padding so the PNG renders with 0 offset at 3× DPR.
async function autoCenterEmoji(page) {
  const offsets = await page.evaluate((sel) => {
    const seen = new Set();
    const results = [];
    for (const el of document.querySelectorAll(sel)) {
      const cls = el.className.trim().split(/\s+/)[0];
      if (seen.has(cls)) continue;          // one sample per class is enough
      if (!el.childNodes[0]) continue;
      const r  = el.getBoundingClientRect();
      const rng = document.createRange();
      rng.selectNode(el.childNodes[0]);
      const tr = rng.getBoundingClientRect();
      const offsetY =
        Math.round((tr.top + tr.height / 2 - r.top - r.height / 2) * 100) / 100;
      if (Math.abs(offsetY) > 0.05) {
        results.push({ cls, offsetY });
        seen.add(cls);
      }
    }
    return results;
  }, ICON_SELECTORS);

  if (offsets.length === 0) return;

  // Build corrective CSS: counter-shift with padding on the low side
  // padding-top N  → shifts ink DOWN by N/2  (use when offsetY < 0, ink above center)
  // padding-bottom N → shifts ink UP   by N/2  (use when offsetY > 0, ink below center)
  const lines = offsets.map(({ cls, offsetY }) => {
    const correction = Math.round(Math.abs(offsetY) * 2);   // pixels of padding needed
    const side = offsetY > 0 ? 'bottom' : 'top';
    return `.${cls}{padding-${side}:${correction}px!important;box-sizing:border-box!important}`;
  });

  await page.evaluate((css) => {
    const s = document.createElement('style');
    s.textContent = css;
    document.head.appendChild(s);
  }, lines.join('\n'));

  console.log('  auto-centered:', offsets.map(o =>
    `${o.cls}(${o.offsetY > 0 ? '↓' : '↑'}${Math.abs(o.offsetY)}px)`).join(' '));
}

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

for (const { url, out } of screens) {
  const page = await browser.newPage();
  await page.setViewport({ width: W, height: H, deviceScaleFactor: 3 });
  await page.goto(url, { waitUntil: 'networkidle0' });

  await autoCenterEmoji(page);

  const element = await page.$('.screen');
  await element.screenshot({
    path: path.join(__dirname, out),
    type: 'png',
  });

  await page.close();
  console.log(`✓  ${out}`);
}

await browser.close();
