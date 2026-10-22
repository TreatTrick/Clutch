# Clutch website

Minimal, responsive product website built with Svelte 5, SvelteKit 3, TypeScript, Vite, and pnpm. English, Simplified Chinese, and Japanese are prerendered into independent HTML pages. No backend is required.

## Local development

Use Node.js 24 (or 22.12+) and pnpm 10.14.0:

```sh
cd website
pnpm install --frozen-lockfile
pnpm dev
```

The website is served under `/Clutch/`, matching the GitHub Pages base path.

## Check and build

```sh
pnpm check
pnpm test
pnpm build
pnpm preview
```

The deployable files are in `website/build/`. Restart the preview server after rebuilding. The asset preparation step copies existing project media from `../docs/assets/` to the ignored `static/media/` directory. `static/demo-poster.webp` is a still extracted from the existing GIF and enables a motion-free preview.

## Edit

- `src/lib/content.ts`: all three languages, release URL, canonical site URL.
- `src/lib/Landing.svelte`: shared page, language navigation, appearance selection, and demo controls.
- `src/app.css`: responsive layouts and appearance tokens.
- `vite.config.ts`: static adapter and `/Clutch` deployment base.
- `src/routes/sitemap.xml/+server.ts`: prerendered sitemap.

The first appearance follows the operating system. System/light/dark selection is stored locally; if storage is unavailable the current page still works. The demonstration starts paused for reduced-motion users and always has a pause/play control. Native language links and download links work without JavaScript.

## Dragon maid

The bottom-right companion reuses the app's transparent `Clutch/Mascot/MascotA.heic` and `MascotB.heic` frames, displayed at twice the original website height on desktop and mobile. Drag horizontally with mouse/touch or use the arrow keys, Home, and End when focused. Her normalized horizontal position persists across language changes and viewport sizes.

Within the page's top quarter (capped at 200 px), moving the mouse upward plays toward sadness and moving downward plays toward happiness. Everywhere below that zone she cheers up. Leaving through the top also plays toward sadness. This approximates exit intent; a webpage cannot detect the browser's actual tab-close button.

When happy, she continuously plays the final two seconds (48 frames) of happy tail-wagging frames back and forth at the original 24 fps. Either download link immediately starts a continuously looping jump clip for the current page session without intercepting the download. Sad playback still stops at its endpoint, and all animation pauses in hidden tabs. Reduced motion uses still poses and resumes the current animation when motion is enabled again. If animation loading fails, a separate transparent still remains visible.

Generated assets are committed in `static/mascot/`; normal `pnpm build` needs no Python. To regenerate after changing the app's HEIC resources, install `pillow-heif==1.8.1` and `Pillow==13.0.0` in a Python environment and run:

```sh
python scripts/extract-mascot.py
```

The generator preserves the shared canvas, frame order, transparency, and original 24 fps, and updates `src/lib/mascotFrames.ts` alongside the atlases.

## Deployment

`.github/workflows/website.yml` checks and builds on relevant pull requests. Pushes to `main`, or a manual workflow run, also publish `website/build/` to GitHub Pages. Select **GitHub Actions** as the Pages source in repository settings. No long-lived deployment secret is needed.

Public pages: `/Clutch/`, `/Clutch/zh/`, `/Clutch/ja/`. Submit `https://treattrick.github.io/Clutch/sitemap.xml` to Search Console after verifying site ownership. A project-level `robots.txt` does not control the host root; the sitemap and page metadata do not themselves guarantee indexing.

## Search Console

Use the URL-prefix property `https://treattrick.github.io/Clutch/` to cover all three languages. The Google ownership verification meta tag lives in `src/app.html` and is included in every prerendered page. Keep this tag after verification so ownership remains valid; it is a public verification token, not a secret.

Submit `sitemap.xml` in the property's Sitemaps report. The Performance report shows search queries, pages, impressions, clicks, CTR, and average position. New data can take several days to appear. Search Console does not measure download-button clicks or attribute them to search traffic; that requires separate website analytics.
