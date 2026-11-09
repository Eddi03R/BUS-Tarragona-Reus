// Test end-to-end del sito: apre la build web in Chromium, naviga la UI
// (Flutter web espone l'albero di accessibilità) e salva gli screenshot.
const { chromium } = require('playwright');
const fs = require('fs');

const URL = process.env.SITE_URL || 'http://localhost:8080';
const OUT = process.env.SHOTS_DIR || 'e2e-shots';
fs.mkdirSync(OUT, { recursive: true });

(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext({
    viewport: { width: 412, height: 915 },
    deviceScaleFactor: 2,
    locale: 'en-US',
  });
  const page = await ctx.newPage();
  const errors = [];
  page.on('pageerror', (e) => errors.push('pageerror: ' + e.message));
  page.on('console', (m) => {
    if (m.type() === 'error') errors.push('console: ' + m.text());
  });

  const step = async (name, fn) => {
    process.stdout.write(`- ${name} ... `);
    try { await fn(); console.log('ok'); }
    catch (e) {
      console.log('FALLITO');
      await page.screenshot({ path: `${OUT}/FAIL-${name.replace(/\W+/g, '_')}.png` });
      throw new Error(`${name}: ${e.message}`);
    }
  };

  await step('apertura sito', async () => {
    await page.goto(URL, { waitUntil: 'load' });
    await page.waitForSelector('flt-glass-pane', { state: 'attached', timeout: 60000 });
    // attiva l'albero di accessibilità di Flutter
    await page.evaluate(() => {
      const p = document.querySelector('flt-semantics-placeholder');
      if (p) p.click();
    });
    await page.getByText('ErasBus Tarragona').first().waitFor({ timeout: 60000 });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: `${OUT}/01-home.png` });
  });

  await step('home: Daylife/Nightlife presenti', async () => {
    await page.getByText('Daylife').first().waitFor({ timeout: 15000 });
  });

  await step('apri Impostazioni', async () => {
    await page.getByRole('button', { name: 'Settings' }).first().click();
    await page.getByText('Appearance').first().waitFor({ timeout: 15000 });
    await page.waitForTimeout(800);
    await page.screenshot({ path: `${OUT}/02-impostazioni.png` });
  });

  await step('menu Impostazioni: voci principali', async () => {
    for (const t of ['Language', 'Location', 'Privacy and statistics']) {
      await page.getByText(t).first().waitFor({ timeout: 10000 });
    }
  });

  await step('pagina Aspetto', async () => {
    await page.getByText('Appearance').first().click();
    await page.getByText('Light').first().waitFor({ timeout: 10000 });
    await page.waitForTimeout(800);
    await page.screenshot({ path: `${OUT}/03-aspetto.png` });
  });

  await step('tema Natale: attivazione', async () => {
    await page.getByText('Natale').first().click();
    await page.waitForTimeout(1200);
    await page.screenshot({ path: `${OUT}/04-natale-aspetto.png` });
  });

  await step('torna alla home con tema Natale', async () => {
    await page.goBack().catch(() => {});
    await page.keyboard.press('Escape');
    // back x2 tramite pulsante di navigazione se presente
    for (let i = 0; i < 2; i++) {
      const back = page.getByRole('button', { name: /back/i }).first();
      if (await back.count()) await back.click().catch(() => {});
      await page.waitForTimeout(500);
    }
    await page.screenshot({ path: `${OUT}/05-home-natale.png` });
  });

  await browser.close();

  // Ignora il rumore noto (font/CDN esterni); fallisce su errori JS veri.
  const real = errors.filter((e) =>
    e.startsWith('pageerror') ||
    /Uncaught|Exception|TypeError|RangeError/i.test(e));
  if (real.length) {
    console.log('\nErrori JavaScript rilevati:\n' + real.join('\n'));
    process.exit(1);
  }
  console.log('\nTutti i passi E2E superati.');
})().catch((e) => { console.error('\nE2E FALLITO:', e.message); process.exit(1); });
