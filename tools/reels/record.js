// Uso: node record.js <it|en> <cartella-output>   (SITE_URL = sito da registrare, default http://localhost:8099)
// Registra il percorso "ultimo bus per la discoteca" dal sito (in locale) e salva i tempi dei passaggi.
const { chromium } = require('playwright');
const fs = require('fs');
const [lang, outDir] = [process.argv[2], process.argv[3]];
fs.mkdirSync(outDir, { recursive: true });
(async () => {
  const b = await chromium.launch();
  const ctx = await b.newContext({
    viewport: { width: 540, height: 960 }, deviceScaleFactor: 2,
    locale: lang === 'it' ? 'it-IT' : 'en-US',
    geolocation: { latitude: 41.1187, longitude: 1.2454 }, permissions: ['geolocation'],
  });
  await ctx.addInitScript((l) => {
    localStorage.setItem('flutter.location_enabled', 'true');
    localStorage.setItem('flutter.analytics_choice', 'false');
    localStorage.setItem('flutter.app_locale', JSON.stringify(l));
  }, lang);
  const p = await ctx.newPage();
  const frames = [];
  let running = true;
  const t0 = Date.now();
  const marks = {};
  const mark = (n) => { marks[n] = (Date.now() - t0) / 1000; };
  await p.clock.install({ time: new Date('2026-11-14T22:40:00') });
  await p.goto(process.env.SITE_URL || 'http://localhost:8099', { waitUntil: 'load' });
  await p.clock.resume();
  await p.waitForTimeout(7000);
  let loop = (async () => {
    while (running) {
      const ts = Date.now() / 1000;
      const buf = await p.screenshot({ type: 'jpeg', quality: 90 });
      const name = `frame_${String(frames.length).padStart(5, '0')}.jpg`;
      fs.writeFileSync(`${outDir}/${name}`, buf);
      frames.push({ name, t: ts });
    }
  })();
  await p.waitForTimeout(1000);
  mark('ready');
  await p.waitForTimeout(2400);
  mark('nightTap'); await p.mouse.click(322, 128); await p.waitForTimeout(1900);
  mark('pickerOpen'); await p.mouse.click(270, 542); await p.waitForTimeout(2000);
  mark('pickTropical'); await p.mouse.click(150, 421); await p.waitForTimeout(1600);
  mark('go'); await p.mouse.click(270, 347); await p.waitForTimeout(3200);
  mark('openTrip'); await p.mouse.click(270, 430); await p.waitForTimeout(2300);
  mark('scroll');
  for (let i = 0; i < 12; i++) { await p.mouse.wheel(0, 60); await p.waitForTimeout(110); }
  await p.waitForTimeout(1400);
  mark('end');
  running = false; await loop;
  fs.writeFileSync(outDir + '/marks.json', JSON.stringify({ marks, frames, t0: t0 / 1000 }, null, 1));
  await ctx.close();
  await b.close();
})();
