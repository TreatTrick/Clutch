# Website Mascot Loops Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Double the website dragon maid's height, loop her happy tail frames back and forth, and keep jumping after a download before redeploying GitHub Pages.

**Architecture:** Reuse the existing atlases and 24 fps canvas player. Advance happy playback through the last second of mood frames with reflected endpoints; wrap the jump cursor indefinitely. Preserve sadness, dragging, hidden-tab pausing, reduced motion, and image fallback.

**Tech Stack:** Svelte 5, TypeScript, Node test runner, pnpm, GitHub Pages.

## Authorized design

The user's requested sizing and repeat behavior define the design. Use `clamp(300px, 46vh, 420px)` on desktop and `clamp(230px, 38vh, 290px)` on mobile. Happy playback runs from mood frame 97 through 120 and back, keeping the original frame rate and carrying fractional overshoot across reversals. Sad playback still reaches frame zero. A download starts the jump clip at frame zero and wraps it forever within the current page session. Hidden tabs pause animation; restoring motion preferences resumes it.

Use a managed worktree so existing uncommitted analytics changes remain untouched and are excluded from deployment. The current user request already authorizes implementation and publishing.

## Task 1: Playback regression coverage

Create `website/tests/mascot.test.mjs`. Test both happy endpoints, fractional frame overshoot, entering happiness from sadness, reversing toward sadness, and repeated jump cycles. Run `node --experimental-strip-types --test tests/mascot.test.mjs` and confirm the missing playback function fails before implementing it.

## Task 2: Implement and integrate

Create `website/src/lib/mascotPlayback.ts` with the small frame-advance function. Modify `website/src/lib/Mascot.svelte` to use it, keep happy animation scheduled, preserve celebration when reduced motion changes, and double both responsive height declarations. Update `website/README.md` with looping behavior. Add `pnpm test` and run it in `.github/workflows/website.yml` before the Svelte check.

## Task 3: Verify and publish

Run `pnpm test`, `pnpm check`, `pnpm build`, and `git diff --check` in the isolated worktree. Review the final diff, commit only this change, and fast-forward remote `main` using a normal push. Confirm the matching GitHub Actions build and deploy jobs succeed and all three public routes respond successfully. The previous approved mascot plan records the user's preference to verify interactions on Pages, so do not start another browser QA session.
