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

## Deployment

`.github/workflows/website.yml` checks and builds on relevant pull requests. Pushes to `main`, or a manual workflow run, also publish `website/build/` to GitHub Pages. Select **GitHub Actions** as the Pages source in repository settings. No long-lived deployment secret is needed.

Public pages: `/Clutch/`, `/Clutch/zh/`, `/Clutch/ja/`. Submit `https://treattrick.github.io/Clutch/sitemap.xml` to Search Console after verifying site ownership. A project-level `robots.txt` does not control the host root; the sitemap and page metadata do not themselves guarantee indexing.
