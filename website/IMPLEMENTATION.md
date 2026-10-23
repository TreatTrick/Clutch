# MouseSpell Website Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build and deploy the approved minimal MouseSpell website with three locales and system/light/dark themes.

**Architecture:** SvelteKit prerenders three independent HTML routes; Vite builds and pnpm locks dependencies. The website lives in website/ and reuses assets from docs/assets through a preparation script. A GitHub Pages workflow publishes website/build.

**Tech Stack:** Svelte 5, SvelteKit 3, TypeScript, Vite 8, pnpm 10, adapter-static, GitHub Pages.

## Tasks

1. Create shared localized content, one landing page component, semantic responsive CSS, and explicit root/zh/ja routes. Include the six existing actions, real demo, setup, release download, permissions, and privacy facts. Follow the existing icon colors and system font identity.
2. Add system/light/dark selection with persistence and immediate head initialization; update app screenshots by theme. Add explicit demo play/pause and respect reduced motion. Keep content and download links usable without JS.
3. Add localized metadata, HTML language, canonical/hreflang, sitemap, SoftwareApplication data, and a static 404 page.
4. Run pnpm check and pnpm build. Inspect all language/theme combinations and mobile overflow in the browser; verify theme persistence, navigation, pause/play, and download destinations. Save representative screenshots.
5. Add a frozen-lockfile Pages workflow and README website links. Upload reviewed changes, configure Pages, verify deployment and public routes, update repository homepage, and retain a local build.

## Validation commands

From website/: pnpm install; pnpm check; pnpm build; pnpm preview --host 127.0.0.1.
From repository root: git diff --check.

## Acceptance

The public website serves three prerendered localized pages, supports manual and system appearances, works at narrow widths, exposes the existing release and source code, and uses the requested toolchain in the requested subdirectory. Deployment must be confirmed by GitHub and an actual successful page response.
